# frozen_string_literal: true

module Logigram
  # An element of a puzzle.
  #
  class Piece
    # @return [Object]
    attr_reader :object

    # @return [Array<Property>]
    attr_reader :properties

    # @param object [Object]
    # @param properties [Array<Property>]
    def initialize(object, properties)
      @object = object
      @properties = properties
    end

    def name
      object.to_s
    end

    # Get a property by its constraint or name.
    #
    # @param key [Constraint, String]
    # @return [Property, nil]
    def property(key)
      constraint_property_hash[key] || name_property_hash[key]
    end

    # Get a property value by its constraint or name.
    #
    # @param key [Constraint]
    # @return [Object, nil]
    def value(key)
      property(key)&.value
    end

    def to_s
      name
    end

    private

    def constraint_property_hash
      @constraint_property_hash ||= properties.map { |prop| [prop.constraint, prop] }.to_h
    end

    def name_property_hash
      @name_property_hash ||= properties.map { |prop| [prop.name, prop] }.to_h
    end
  end
end
