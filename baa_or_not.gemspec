# frozen_string_literal: true

require_relative "lib/baa_or_not/version"

Gem::Specification.new do |spec|
  spec.name = "baa_or_not"
  spec.version = BaaOrNot::VERSION
  spec.authors = ["Dave Doolin"]
  spec.summary = "BAA decision tool"
  spec.description = "Determine whether a Business Associate Agreement is required under HIPAA."
  spec.homepage = "https://github.com/doolin/baa-or-not"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("{lib}/**/*") + %w[README.md config.ru config.rb app.rb]
  spec.require_paths = ["lib"]

  spec.add_dependency "lamby", "~> 5.0"
  spec.add_dependency "puma", "~> 7.0"
  spec.add_dependency "sinatra", "~> 4.0"
end
