# frozen_string_literal: true

module Shopify
  module DefaultVariant
    VERSION = "0.0.2"
    TITLE = "Default Title"

    class Object
      def initialize(object)
        @object = object
      end

      def match?
        # TODO: arity???
        if @object.respond_to?(:variants)
          variants = @object.variants
          return variants.size == 1 && default_variant?(variants[0])
        end

        default_variant?(@object)
      end

      private

      def default_variant?(object)
        return false unless object.respond_to?(:title)
        match = object.title == DefaultVariant::TITLE

        return match unless object.respond_to?(:option1)

        match &&= (object.option1.nil? || object.option1 == DefaultVariant::TITLE)
        return match unless object.respond_to?(:option2)

        match && object.option2.nil?
      end
    end

    class Hash
      def initialize(hash)
        @hash = hash
      end

      def match?
        return false unless @hash.is_a?(::Hash)

        plain_hash_match? || graphql_hash_match?
      end

      private

      def plain_hash_match?
        v = variants
        return default_variant?(@hash) unless v

        v.is_a?(Array) && v.size == 1 && v[0].is_a?(::Hash) && default_variant?(v[0])
      end

      def graphql_hash_match?
        if @hash.include?(:hasOnlyDefaultVariant) || @hash.include?("hasOnlyDefaultVariant")
          return @hash[:hasOnlyDefaultVariant] || @hash["hasOnlyDefaultVariant"]
        end

        v = variants
        match = v.is_a?(::Hash) ? graphql_default_variant?(v) : false
        return match unless match && (@hash.include?(:totalVariants) || @hash.include?("totalVariants"))

        match && (@hash[:totalVariants] || @hash["totalVariants"]) == 1
      end

      def variants
        @hash[:variants] || @hash["variants"]
      end

      def default_variant?(hash)
        match = default_title?(hash)
        # FIXME: should do like we do for GraphQL and not assume we have a title
        return match unless match && (hash.include?(:option1) || hash.include?("option1"))

        match &&= (hash[:option1] || hash["option1"]) == DefaultVariant::TITLE
        return match unless match && (hash.include?(:option2) || hash.include?("option2"))

        match && (hash[:option2] || hash["option2"]).nil?

        # option3 too!
      end

      def graphql_default_variant?(variants)
        edges = variants[:edges] || variants["edges"]
        return false unless edges.is_a?(Array)

        nodes = edges.map { |e| e[:node] || e["node"] }
        return false unless nodes.size == 1 && nodes[0].is_a?(::Hash)

        match = nil
        if nodes[0].include?(:title) || nodes[0].include?("title")
          match = default_title?(nodes[0])
        end

        return false if match == false

        if nodes[0].include?(:selectedOptions) || nodes[0].include?("selectedOptions")
          match = graphql_default_option?(nodes[0][:selectedOptions] || nodes[0]["selectedOptions"])
        end

        # Could still be nil so we force a boolean
        !!match
      end

      def graphql_default_option?(options)
        return false unless options.is_a?(Array) && options.size == 1

        name = options[0][:name] || options[0]["name"]
        value = options[0][:value] || options[0]["value"]

        name == "Title" && value == DefaultVariant::TITLE
      end

      def default_title?(hash)
        hash[:title] == DefaultVariant::TITLE || hash["title"] == DefaultVariant::TITLE
      end
    end

    class << self
      def match?(object)
        handler(object).match?
      end

      private

      def handler(object)
        if object.is_a?(::Hash)
          DefaultVariant::Hash.new(object)
        else
          DefaultVariant::Object.new(object)
        end
      end
    end
  end
end
