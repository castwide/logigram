# frozen_string_literal: true

module Logigram
  # A fact about a puzzle piece.
  #
  # A Challenge provides a list of premises that can be used to deduce the
  # solution to its puzzle.
  #
  class Premise
    attr_reader :piece, :constraint, :value, :identifier

    # @param piece [Piece]
    # @param constraint [Constraint]
    # @param value [Object]
    # @param identifier [Constraint, nil]
    def initialize(piece, constraint, value, identifier = nil)
      @piece = piece
      @constraint = constraint
      @value = value
      @identifier = identifier
    end

    # @return [Property]
    def property
      piece.property(constraint.name)
    end

    def specific?
      identifier.nil?
    end

    def generic?
      !specific?
    end

    def affirmative?
      property.value == value
    end

    def negative?
      !affirmative?
    end

    def subject
      specific? ? piece.name : piece.property(identifier.name).subject
    end

    # A human-readable representation of the premise, e.g., "The dog is red."
    #
    # @return [String]
    def text
      if affirmative?
        "#{subject} #{piece.property(property.name).predicate}"
      else
        "#{subject} #{property.constraint.negative(value)}"
      end
    end

    def to_s
      text
    end
  end
end
