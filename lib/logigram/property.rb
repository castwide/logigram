# frozen_string_literal: true

module Logigram
  # A constraint/value tuple.
  #
  class Property
    # @return [Constraint]
    attr_reader :constraint

    # @return [Object]
    attr_reader :value

    def initialize(constraint, value)
      @constraint = constraint
      @value = value
    end

    def name
      constraint.name
    end

    def subject
      constraint.subject(value)
    end

    def predicate
      constraint.predicate(value)
    end
  end
end
