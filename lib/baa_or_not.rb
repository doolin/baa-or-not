# frozen_string_literal: true

require_relative "baa_or_not/version"
require_relative "baa_or_not/web"

# Determines whether a Business Associate Agreement is required
# under HIPAA for a given set of circumstances.
module BaaOrNot
  REVISION = if File.exist?(File.expand_path("../REVISION", __dir__))
               File.read(File.expand_path("../REVISION", __dir__)).strip
             elsif system("git rev-parse --short HEAD >/dev/null 2>&1")
               `git rev-parse --short HEAD`.strip
             end
end
