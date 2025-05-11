# frozen_string_literal: true

module Logigram
  class Piece
    # @return [Object]
    attr_reader :object

    # @return [Array<Properties>]
    attr_reader :properties

    # @param object [Object]
    # @param terms [Array<Property>]
    # @param name [String]
    def initialize object, properties, name: nil
      @object = object
      @properties = properties
      @name = name
    end

    def name
      @name || object.to_s
    end

    def terms
      properties.map(&:name)
    end

    def value key
      properties.find { |prop| prop.name == key }
                &.value
    end

    def to_s
      name
    end
  end
end
