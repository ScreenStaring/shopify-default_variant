# frozen_string_literal: true

require "spec_helper"

Product = Struct.new(:variants)
Variant = Struct.new(:title, :option1, :option2)

GQL_CREATE=<<-GQL
  mutation productCreate($input: ProductInput!) {
    productCreate(input: $input) {
      product {
        id
      }
      userErrors {
        field
        message
      }
    }
  }
GQL

GQL_DELETE=<<-GQL
  mutation productDelete($input: ProductDeleteInput!) {
    productDelete(input: $input) {
      userErrors {
        field
        message
      }
    }
  }
GQL

RSpec.describe Shopify::DefaultVariant do
  describe ".match?" do
    context "given a product PORO" do
      it "returns false when it does not respond_to?(:variants)" do
        no_variants = Struct.new(:whatever).new("Foo")
        expect(described_class.match?(no_variants)).to be false
      end

      it "returns true when it has a 1 variant with a title matching the default title" do
        product = Product.new([ Variant.new("Foo") ])
        expect(described_class.match?(product)).to be false

        product.variants[0].title = "Default Title"
        expect(described_class.match?(product)).to be true
      end

      it "returns false when it has a variant method that is not an Array of Hashes" do
        product = Product.new("VVVV")
        expect(described_class.match?(product)).to be false

        product.variants = [ 123 ]
        expect(described_class.match?(hash)).to be false
      end

      it "returns true when it has 1 variant with a title matching the default title and options matching the default options" do
        product = Product.new([ Variant.new("Default Title", "Foo") ])
        expect(described_class.match?(product)).to be false

        product.variants[0].option1 = "Default Title"
        expect(described_class.match?(product)).to be true

        product.variants[0].option2 = "Some Thangz"
        expect(described_class.match?(product)).to be false

        product.variants[0].option2 = nil
        expect(described_class.match?(product)).to be true
      end

      it "returns true when it has 1 variant with a title matching the default title and options matching the default options but contains more than 1 variant" do
        product = Product.new([
          Variant.new("Default Title", "Default Title"),
          Variant.new("Some Other Title")
        ])

        expect(described_class.match?(product)).to be false
      end

      it "returns false when it only has a variant with a title matching the default title but also contains other variants" do
        product = Product.new([
          Variant.new("Default Title"),
          Variant.new("Some Other Title")
        ])

        expect(described_class.match?(product)).to be false
      end
    end

    context "given a variant PORO" do
      it "returns false if it does not respond to title" do
        no_title = Struct.new(:whatever).new("Foo")
        expect(described_class.match?(no_title)).to be false
      end

      it "returns true when it only has a title matching the default title" do
        variant = Variant.new("Foo")
        expect(described_class.match?(variant)).to be false

        variant.title = "Default Title"
        expect(described_class.match?(variant)).to be true
      end

      it "returns true when it only has a title matching the default title and does not respond_to?(:option1)" do
        no_option = Struct.new(:title).new("Foo")
        expect(described_class.match?(no_option)).to be false

        no_option.title = "Default Title"
        expect(described_class.match?(no_option)).to be true
      end

      it "returns true when it has a title matching the default title and options matching the default options" do
        variant = Variant.new("Default Title", "Foo")
        expect(described_class.match?(variant)).to be false

        variant.option1 = "Default Title"
        expect(described_class.match?(variant)).to be true

        variant.option2 = "Some Thangz"
        expect(described_class.match?(variant)).to be false

        variant.option2 = nil
        expect(described_class.match?(variant)).to be true
      end
    end

    context "given a product Hash" do
      context "with Symbol keys" do
        it "returns true when it has a 1 variant with a title key matching the default title" do
          hash = { :variants => [ :title => "Foo" ] }
          expect(described_class.match?(hash)).to be false

          hash[:variants][0][:title] = "Default Title"
          expect(described_class.match?(hash)).to be true
        end

        it "returns false when it has a variant key that is not an Array of Hashes" do
          hash = { :variants => "VVVV" }
          expect(described_class.match?(hash)).to be false

          hash[:variants] = [ 123 ]
          expect(described_class.match?(hash)).to be false
        end

        it "returns true when it has 1 variant with a title key matching the default title and option keys matching the default options" do
          hash = { :variants => [ :title => "Default Title", :option1 => "Foo" ] }
          expect(described_class.match?(hash)).to be false

          hash[:variants][0][:option1] = "Default Title"
          expect(described_class.match?(hash)).to be true

          hash[:variants][0][:option2] = "Some Thangz"
          expect(described_class.match?(hash)).to be false

          hash[:variants][0][:option2] = nil
          expect(described_class.match?(hash)).to be true

          hash[:variants][0][:option2] = []
          expect(described_class.match?(hash)).to be false
        end

        it "returns true when it has 1 variant with a title key matching the default title and option keys matching the default options but contains more than 1 variant" do
          hash = {
            :variants => [
              { :title => "Default Title", :option1 => "Default Title", :option2 => nil },
              { :title => "Some Other Title" }
            ]
          }

          expect(described_class.match?(hash)).to be false
        end

        it "returns false when it has a 1 variant with a title key matching the default title but also contains other variants" do
          hash = {
            :variants => [
              { :title => "Default Title" },
              { :title => "Some Other Title" }
            ]
          }

          expect(described_class.match?(hash)).to be false
        end
      end

      context "with String keys" do
        it "returns true when it has a 1 variant with a title key matching the default title" do
          hash = { "variants" => [ "title" => "Foo" ] }
          expect(described_class.match?(hash)).to be false

          hash["variants"][0]["title"] = "Default Title"
          expect(described_class.match?(hash)).to be true
        end

        it "returns false when it has a variant key that is not an Array of Hashes" do
          hash = { "variants" => "VVVV" }
          expect(described_class.match?(hash)).to be false

          hash["variants"] = [ 123 ]
          expect(described_class.match?(hash)).to be false
        end

        it "returns true when it has 1 variant with a title key matching the default title and option keys matching the default options" do
          hash = { "variants" => [ :title => "Default Title", "option1" => "Foo" ] }
          expect(described_class.match?(hash)).to be false

          hash["variants"][0]["option1"] = "Default Title"
          expect(described_class.match?(hash)).to be true

          hash["variants"][0]["option2"] = "Some Thangz"
          expect(described_class.match?(hash)).to be false

          hash["variants"][0]["option2"] = nil
          expect(described_class.match?(hash)).to be true
        end

        it "returns true when it has 1 variant with a title key matching the default title and option keys matching the default options but contains more than 1 variant" do
          hash = {
            "variants" => [
              { "title" => "Default Title", "option1" => "Default Title", "option2" => nil },
              { "title" => "Some Other Title" }
            ]
          }

          hash = { "variants" => [ "title" => "Default Title", "option1" => "Foo" ] }
          expect(described_class.match?(hash)).to be false

          hash["variants"][0]["option1"] = "Default Title"
          expect(described_class.match?(hash)).to be true

          hash["variants"][0]["option2"] = "Some Thangz"
          expect(described_class.match?(hash)).to be false

          hash["variants"][0]["option2"] = nil
          expect(described_class.match?(hash)).to be true
        end

        it "returns false when it has a 1 variant with a title key matching the default title but also contains other variants" do
          hash = {
            "variants" => [
              { "title" => "Default Title" },
              { "title" => "Some Other Title" }
            ]
          }

          expect(described_class.match?(hash)).to be false
        end
      end
    end

    context "given a variant Hash" do
      context "with Symbol keys" do
        it "returns true when it only has a title key matching the default title" do
          hash = { :title => "Foo", :whatever => "Bar" }
          expect(described_class.match?(hash)).to be false

          hash[:title] = "Default Title"
          expect(described_class.match?(hash)).to be true
        end

        it "returns true when it has a title key matching the default title and option keys matching the default options" do
          hash = { :title => "Default Title", :option1 => "Foo" }
          expect(described_class.match?(hash)).to be false

          hash[:option1] = "Default Title"
          expect(described_class.match?(hash)).to be true

          hash[:option2] = "Some Thangz"
          expect(described_class.match?(hash)).to be false

          hash[:option2] = nil
          expect(described_class.match?(hash)).to be true
        end
      end

      context "with String keys" do
        it "returns true when it only has a symbol title key matching the default title" do
          hash = { "title" => "Foo", "whatever" => "Bar" }
          expect(described_class.match?(hash)).to be false

          hash["title"] = "Default Title"
          expect(described_class.match?(hash)).to be true
        end

        it "returns true when it has a title key matching the default title and option keys matching the default options" do
          hash = { "title" => "Default Title", "option1" => "Foo" }
          expect(described_class.match?(hash)).to be false

          hash["option1"] = "Default Title"
          expect(described_class.match?(hash)).to be true

          hash["option2"] = "Some Thangz"
          expect(described_class.match?(hash)).to be false

          hash["option2"] = nil
          expect(described_class.match?(hash)).to be true

          hash["option2"] = "Default Title"
          expect(described_class.match?(hash)).to be false
        end
      end
    end

    context "given a GraphQL response hash", :vcr do
      before do
        @gql = ShopifyAPI::GraphQL::Tiny.new(
          ENV.fetch("SHOPIFY_DOMAIN"),
          ENV.fetch("SHOPIFY_TOKEN")
        )

        result = @gql.execute(
          GQL_CREATE,
          :input => {
            :title => "Shopify::DefaultVariant Test Product Without Variants",
          }
        )

        # FIXME: we want to do this once and use the same for each test. May have to wrap with VCR.use_cassette
        @without_variants = result.dig("data", "productCreate", "product", "id")
        raise result.inspect unless @without_variants

        result = @gql.execute(
          GQL_CREATE,
          :input => {
            :title => "Shopify::DefaultVariant Test Product With Variants",
            :options => %w[Color],
            :variants => [
              :title => "Variant 1",
              :options => %w[Red]
            ]
          }
        )

        @with_variants = result.dig("data", "productCreate", "product", "id")
        raise result.inspect unless @with_variants
      end

      after do
        @gql.execute(
          GQL_DELETE,
          :input => { :id => @without_variants }
        )

        @gql.execute(
          GQL_DELETE,
          :input => { :id => @with_variants }
        )
      end

      context "given a product with a default variant" do
        it "returns true when hasOnlyDefaultVariant is true" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@without_variants") {
                hasOnlyDefaultVariant
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be true
        end

        it "returns true when its variants only contain the default variant's selectedOptions" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@without_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      selectedOptions {
                        name
                        value
                      }
                    }
                  }
                }
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be true
        end

        it "returns true when its variants only contain the default variant's title" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@without_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      title
                    }
                  }
                }
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be true
        end

        it "returns true when its variants only contain the default variant's title and selectedOptions" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@without_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      title
                      selectedOptions {
                        name
                        value
                      }
                    }
                  }
                }
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be true
        end

        it "returns true when it contains the variant count and its variants only contain a default variant" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@without_variants") {
                totalVariants
                variants(first: 10) {
                  edges {
                    node {
                      title
                    }
                  }
                }
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be true
        end
      end

      context "given a product without a default variant" do
        it "returns false when hasOnlyDefaultVariant is false" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@with_variants") {
                hasOnlyDefaultVariant
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be false
        end

        it "returns false when its variants only contain the variant's selectedOptions" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@with_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      selectedOptions {
                        name
                        value
                      }
                    }
                  }
                }
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be false
        end

        it "returns false when its variants do not contain a default variant title" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@with_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      title
                    }
                  }
                }
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be false
        end

        it "returns false when it contains the variant count and its variants do not contain a default variant" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@with_variants") {
                totalVariants
                variants(first: 10) {
                  edges {
                    node {
                      title
                    }
                  }
                }
              }
            }
          GQL

          expect(described_class.match?(result.dig("data", "product"))).to be false
        end
      end

      context "given a default variant" do
        # TODO: more tests here
        it "returns true when its variants contain a default variant title" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@without_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      title
                    }
                  }
                }
              }
            }
          GQL

          variant = result.dig("data", "product", "variants", "edges", 0, "node")
          expect(described_class.match?(variant)).to be true
        end

        it "returns true when its variants contain a default variant title and the default variant's selectedOptions" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@without_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      title
                      selectedOptions {
                        name
                        value
                      }
                    }
                  }
                }
              }
            }
          GQL

          variant = result.dig("data", "product", "variants", "edges", 0, "node")
          expect(described_class.match?(variant)).to be true
        end
      end

      context "given a variant that is not a default" do
        it "returns false when its variants contain a default variant title" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@with_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      title
                    }
                  }
                }
              }
            }
          GQL

          variant = result.dig("data", "product", "variants", "edges", 0, "node")
          expect(described_class.match?(variant)).to be false
        end

        it "returns false when its variants contain a default variant title and the default variant's selectedOptions" do
          result = @gql.execute(<<-GQL)
            query {
              product(id: "#@with_variants") {
                variants(first: 10) {
                  edges {
                    node {
                      title
                      selectedOptions {
                        name
                        value
                      }
                    }
                  }
                }
              }
            }
          GQL

          variant = result.dig("data", "product", "variants", "edges", 0, "node")
          expect(described_class.match?(variant)).to be false
        end
      end
    end
  end
end
