# frozen_string_literal: true

module Logigram
  # A combination of a puzzle and a collection of premises that can be used to
  # determine the puzzle's solution through logical deduction.
  #
  class Challenge
    # @return [Puzzle]
    attr_reader :puzzle

    # @return [Array<Premise>]
    attr_reader :premises
    alias clues premises

    # @param puzzle [Puzzle]
    # @param generator [Class<Generator::Base>] The generator to use for creating
    #   premises. Defaults to Generator::Cascade.
    # @param opts [Hash] Options to pass to the generator.
    def initialize(puzzle, generator: Generator::Cascade, **opts)
      @puzzle = puzzle
      @premises = generator.new(puzzle, **opts).premises
    end
  end
end
