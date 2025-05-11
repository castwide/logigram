# frozen_string_literal: true

module Logigram
  class Puzzle
    # @return [Array<Constraint>]
    attr_reader :constraints

    attr_reader :terms

    attr_reader :pieces

    # The piece that represents the solution. The puzzle's premises should be
    # clues from which this solution can be deduced.
    #
    # @return [Piece]
    attr_reader :solution

    def initialize constraints:,  objects:, terms: nil, selection: nil
      @constraints = constraints
      @terms = terms ? [terms].flatten : [constraints.sample]
      @terms.each { |term| constraints.push term unless constraints.include?(term) }
      selection ||= objects.sample
      objects.push selection unless objects.include?(selection)
      @pieces = Piece::Factory.make(constraints, @terms, objects, selection)
      @solution ||= pieces.find { |piece| piece.object == selection }
    end
  end
end
