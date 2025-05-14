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

    # @param constraint [Constraint]
    # @return [Property, nil]
    def property(constraint)
      constraint_property_hash[constraint]
    end

    # @param constraint [Constraint]
    # @return [Object, nil]
    def value(constraint)
      constraint_property_hash[constraint]&.value
    end

    def to_s
      name
    end

    private

    def constraint_property_hash
      @constraint_property_hash ||= properties.map { |prop| [prop.constraint, prop] }.to_h
    end
  end
end
