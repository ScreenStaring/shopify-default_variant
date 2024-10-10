# Shopify::DefaultVariant

[![CI](https://github.com/ScreenStaring/shopify-default_variant/actions/workflows/ci.yml/badge.svg)](https://github.com/ScreenStaring/shopify-default_variant/actions/workflows/ci.yml)

Determine if the given Shopify product only has a default variant, or if the given variant is the default variant.

Works with a variety of objects:

- ShopifyAPI gem response objects
- GraphQL response `Hash` with `String` or `Symbol` keys
- Plain Ol' Ruby Object (PORO)
- Plain `Hash` with `String` or `Symbol` keys

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem "shopify-default_variant"
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install shopify-default_variant
```

## Usage

```rb
Shopify::DefaultVariant.match?(object)
```

Where `object` can be a product or a variant in any of the aforementioned forms.

More examples:

```rb
require "shopify-default_variant"
require "shopify_api"  # Just an example, *not* a recommendation 😉

product = ShopifyAPI::Product.find(id: id)
Shopify::DefaultVariant.match?(product)
Shopify::DefaultVariant.match?(product.variants)
Shopify::DefaultVariant.match?(product.variants.sample)

require "shopify_api-graphql-tiny"

gql = ShopifyAPI::GraphQL::Tiny.new("shop", "token")
data = gql.execute(YOUR_QUERY)
# Be sure to remove the data key and query's name key (whatever it may be) from the response hash
Shopify::DefaultVariant.match?(data.dig("data", "queryName"))

# Or use a Object or Hash that resembles one of the well-known forms
Shopify::DefaultVariant.match?(my_custom_object)
```

## Testing

The GraphQL tests require a Shopify store and access token. You can set this by
copying `.env.template` to `.env.test` and adding the appropriate values.
VCR is used to record these requests.

---

Made by [ScreenStaring](http://screenstaring.com)
