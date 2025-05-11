# frozen_string_literal: true

module Logigram
  # A premise is a fact about a puzzle piece. Puzzles use premises to provide
  # clues.
  #
  # Examples of premises:
  #
  #   "Bob is short."
  #   "Mary is not tall."
  #   "The short person has red hair."
  #
  class Premise
    # @return [Piece]
    attr_reader :piece

    # @return [Constraint]
    attr_reader :constraint

    # @return [String]
    attr_reader :value

    # @return [Constraint, nil]
    attr_reader :identifier

    # @param piece [Piece]
    # @param constraint [Constraint]
    # @param value [String]
    # @param identifier [Constraint, nil]
    def initialize(piece, constraint, value, identifier = nil)
      @piece = piece
      @constraint = constraint
      @identifier = identifier
      @value = value
    end

    # Determine if this premise refers to its piece specifically or uses an
    # alternate identifier.
    # A specific premise uses the piece's name for the subject, e.g., "Bob."
    # The subject of an alternate premise is typically a description, e.g.,
    # "The gray cat" or "The person with brown hair."
    #
    # @return [Boolean]
    def specific?
      identifier.nil?
    end

    # Determine if this is a generic premise.
    # @see #specific?
    def generic?
      !specific?
    end

    # Determine if this is an affirmative premise.
    # An affirmative premise is a fact, e.g., "The dog is red."
    # A negative premise is a reduction, e.g., "The dog is not blue."
    #
    # @return [Boolean]
    def affirmative?
      piece.value(constraint.name) == value
    end

    # Determine if this is a negative premise.
    # @see #affirmative?
    #
    # @return [Boolean]
    def negative?
      !affirmative?
    end

    # The name of the constraint for which this premise provides a fact.
    # Example: for the premise `the dog is red`, the term is `color`.
    #
    # @return [String]
    def term
      constraint.name
    end

    # The subject is the puzzle piece for which this premise provides a fact.
    # If the premise is `specific`, the subject is the piece's name. Otherwise
    # the subject is a description of the piece based on the constraint being
    # used as an `identifier`.
    #
    # Example: The premise's piece is named Bob. The puzzle's constraints
    # include hair color. Bob's hair is red. If this premise is specific, the
    # subject would be `Bob`. If the premise is not specific and its identifier
    # is hair color, the subject would be `the person with red hair`.
    #
    # @return [String]
    def subject
      @subject ||= if identifier.nil?
                     piece.name
                   else
                     identifier.subject(piece.value(identifier.name))
                   end
    end

    # A human-readable representation of the premise, e.g., "The dog is red."
    #
    # @return [String]
    def text
      @text ||= if affirmative?
                  "#{subject} #{constraint.predicate(value)}"
                else
                  "#{subject} #{constraint.negative(value)}"
                end
    end

    def to_s
      text
    end
  end
end
