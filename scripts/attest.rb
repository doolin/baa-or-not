#!/usr/bin/env ruby
# frozen_string_literal: true

# CI/CD Attestation: zip artifacts, SHA-256, Solana memo.
#
# Environment variables:
#   GITHUB_SHA          — commit hash
#   SOLANA_KEYPAIR_PATH — path to 64-byte JSON array keypair
#   SOLANA_NETWORK      — devnet or mainnet-beta (default: devnet)
#   S3_COMPLIANCE_BUCKET — S3 bucket (empty = skip upload)
#   AWS_REGION          — AWS region (default: us-west-1)

require "digest"
require "json"
require "net/http"
require "base64"
require "uri"
require "time"
require "ed25519"

# Base58 alphabet used by Solana for blockhash encoding.
BASE58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

# Memo program public key (32 bytes).
MEMO_PROGRAM = [
  5, 74, 83, 80, 248, 93, 200, 130,
  214, 20, 165, 86, 114, 120, 138, 41,
  109, 223, 30, 171, 171, 208, 166, 6,
  120, 136, 73, 50, 244, 238, 246, 71
].pack("C*").freeze

ARTIFACTS = %w[
  rspec-results.txt
  rubocop-results.txt
  brakeman-results.txt
  bundle-audit-results.txt
  libyear-results.txt
].freeze

def commit_sha
  @commit_sha ||= ENV.fetch("GITHUB_SHA") { `git rev-parse HEAD`.strip }
end

def base58_to_int(str)
  str.each_char.reduce(0) { |n, c| (n * 58) + BASE58.index(c) }
end

def int_to_bytes(num)
  hex = num.to_s(16)
  hex = "0#{hex}" if hex.length.odd?
  [hex].pack("H*")
end

def base58_decode(str)
  zeros = str.chars.take_while { |c| c == "1" }.length
  (("\x00" * zeros) + int_to_bytes(base58_to_int(str))).b
end

def compact_u16(val)
  out = []
  while val.positive?
    byte = val & 0x7F
    val >>= 7
    byte |= 0x80 if val.positive?
    out << byte
  end
  out.empty? ? "\x00" : out.pack("C*")
end

def zip_artifacts
  present = ARTIFACTS.select { |f| File.exist?(f) }
  abort "No CI artifact files found" if present.empty?

  system("zip", "-qj", "ci-artifacts.zip", *present) ||
    abort("zip failed")
  present
end

def build_http(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = 5
  http.read_timeout = 10
  http
end

def rpc_post(url, method, params = [])
  uri = URI(url)
  body = { jsonrpc: "2.0", id: 1, method: method, params: params }
  req = Net::HTTP::Post.new(uri)
  req["Content-Type"] = "application/json"
  req.body = body.to_json
  JSON.parse(build_http(uri).request(req).body)
end

def load_keypair(path)
  bytes = JSON.parse(File.read(path))
  key = Ed25519::SigningKey.new(bytes[0, 32].pack("C*"))
  [key, key.verify_key]
end

def fetch_blockhash(url)
  resp = rpc_post(url, "getLatestBlockhash")
  bh = resp.dig("result", "value", "blockhash")
  abort "Failed to fetch blockhash" unless bh
  base58_decode(bh)
end

def build_instruction(memo_data)
  [
    [1].pack("C"),
    compact_u16(1),
    [0].pack("C"),
    compact_u16(memo_data.bytesize),
    memo_data,
  ].join
end

def message_header
  [1, 0, 1].pack("CCC")
end

def build_message(pubkey, blockhash, memo)
  [
    message_header,
    compact_u16(2),
    pubkey, MEMO_PROGRAM, blockhash,
    compact_u16(1),
    build_instruction(memo)
  ].join
end

def sign_and_encode(signing_key, message)
  sig = signing_key.sign(message)
  tx = [compact_u16(1), sig, message].join
  Base64.strict_encode64(tx)
end

def solana_url(network)
  return "https://api.mainnet-beta.solana.com" if network == "mainnet-beta"

  "https://api.devnet.solana.com"
end

def build_and_sign(payload, keypair_path, network)
  signing_key, verify_key = load_keypair(keypair_path)
  url = solana_url(network)
  blockhash = fetch_blockhash(url)
  msg = build_message(verify_key.to_bytes, blockhash, payload.to_json)
  [url, sign_and_encode(signing_key, msg)]
end

def submit_memo(payload, keypair_path, network)
  url, encoded = build_and_sign(payload, keypair_path, network)
  result = rpc_post(url, "sendTransaction", [encoded, { encoding: "base64" }])
  abort "Solana RPC error: #{result['error']}" if result["error"]
  result["result"]
end

def s3_upload(bucket, prefix, files)
  region = ENV.fetch("AWS_REGION", "us-west-1")
  files.each do |f|
    next unless File.exist?(f)

    dest = "s3://#{bucket}/#{prefix}/#{f}"
    system("aws", "s3", "cp", f, dest, "--region", region) ||
      warn("Failed to upload #{f}")
  end
end

# -------------------------------------------------------------------
# Main
# -------------------------------------------------------------------
short = commit_sha[0, 7]
puts "==> Attesting build #{short}..."

included = zip_artifacts
checksum = Digest::SHA256.file("ci-artifacts.zip").hexdigest
puts "SHA-256: #{checksum}"

t = Time.now.utc
prefix = format(
  "baa-or-not/ci/%<y>04d/%<m>02d/%<d>02d/%<hms>s-%<sha>s",
  y: t.year, m: t.month, d: t.day,
  hms: t.strftime("%H%M%S"), sha: short
)

keypair_path = ENV.fetch("SOLANA_KEYPAIR_PATH", nil)
network = ENV.fetch("SOLANA_NETWORK", "devnet")
signature = nil

if keypair_path && File.exist?(keypair_path)
  memo = {
    s3_key: "#{prefix}/ci-artifacts.zip",
    artifact_checksum: "sha256:#{checksum}",
    commit: commit_sha,
    timestamp: t.iso8601,
  }
  begin
    signature = submit_memo(memo, keypair_path, network)
    puts "Solana memo: #{signature}"
  rescue StandardError => e
    warn "Solana memo failed (non-fatal): #{e.message}"
  end
else
  puts "Skipping Solana memo (no keypair)"
end

bucket = ENV.fetch("S3_COMPLIANCE_BUCKET", nil)
if bucket && !bucket.empty?
  s3_upload(bucket, prefix, [*included, "ci-artifacts.zip"])
else
  puts "Skipping S3 upload (no bucket)"
end

puts "==> Attestation complete."
return unless signature

cluster = network == "mainnet-beta" ? "" : "?cluster=#{network}"
puts "Verify: https://explorer.solana.com/tx/#{signature}#{cluster}"
