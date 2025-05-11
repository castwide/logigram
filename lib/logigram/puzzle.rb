# frozen_string_literal: true

module Logigram
  class Puzzle
    # All of the constraints in the puzzle.
    #
    # @return [Array<Constraint>]
    attr_reader :constraints

    # The constraints that must be solved to determine the solution.
    #
    # @return [Array<Constraint>]
    attr_reader :terms

    # @return [Array<Piece>]
    attr_reader :pieces

    # @return [Piece]
    attr_reader :solution

    # @param constraints [Array<Constraint>]
    # @param objects [Array<Object>]
    # @param terms [Array<Constraint>]
    # @param selection [Object]
    def initialize constraints:, objects:, terms: constraints.sample, selection: objects.sample
      @constraints = constraints
      @terms = [terms].flatten
      @terms.each { |term| constraints.push term unless constraints.include?(term) }
      objects.push selection unless objects.include?(selection)
      @pieces, @solution = Piece::Factory.make(constraints, @terms, objects, selection)
    end
  end
end
