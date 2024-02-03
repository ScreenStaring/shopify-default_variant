# frozen_string_literal: true

require "shopify/default_variant"
require "shopify_api/graphql/tiny"
require "vcr"

require "dotenv/load" unless ENV["CI"]

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!

  # We're using this for GraphQL
  c.default_cassette_options[:match_requests_on] = [:body]
  c.filter_sensitive_data("<X-Shopify-Access-Token>") { ENV.fetch("SHOPIFY_TOKEN") }
  c.filter_sensitive_data("<Host>") { ENV.fetch("SHOPIFY_DOMAIN") }
end
