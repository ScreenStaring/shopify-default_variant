# frozen_string_literal: true

require_relative "lib/shopify/default_variant"

Gem::Specification.new do |spec|
  spec.name = "shopify-default_variant"
  spec.version = Shopify::DefaultVariant::VERSION
  spec.authors = ["sshaw"]
  spec.email = ["skye.shaw@gmail.com"]

  spec.summary = "Determine if the given Shopify product only has a default variant, or if the given variant is the default variant"
  spec.description = "Determine if the given Shopify product only has a default variant, or if the given variant is the default variant. Works with ShopifyAPI, a GraphQL response hash with Symbol or String keys, POROs or plain Hashes"
  spec.homepage = "https://github.com/ScreenStaring/shopify-default_variant"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.4"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "shopify_api-graphql-tiny", "~> 0.1.1"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "webmock"
end
