# frozen_string_literal: true

module Logigram
  # A puzzle generated from constraints and objects.
  #
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
    # @param terms [Constraint, Array<Constraint>]
    # @param selection [Object]
    def initialize(constraints:, objects:, terms: constraints.sample, selection: objects.sample)
      @constraints = constraints
      @terms = [terms].flatten
      @terms.each { |term| constraints.push term unless constraints.include?(term) }
      objects.push selection unless objects.include?(selection)
      @pieces, @solution = Piece::Factory.make(constraints, @terms, objects, selection)
    end

    # @return [Array<Premise>]
    def premises
      @premises ||= generate_all_premises
    end

    # Get the piece associated with an object.
    #
    # @param object [Object] The object used to generate the piece
    # @return [Piece]
    def piece_for(object)
      pieces.find { |piece| piece.object == object }
    end

    private

    # Create an array of all possible premises for the puzzle.
    #
    # @return [Array<Logigram::Premise>]
    def generate_all_premises
      pieces.map { |pc| generate_piece_premises pc }.flatten
    end

    # Create an array of all possible premises for the specified piece.
    #
    # @param piece [Logigram::Piece]
    # @return [Array<Logigram::Premise>]
    def generate_piece_premises(piece)
      result = []
      piece.terms.each do |t|
        # Positive specific
        result.push Premise.new(piece, constraint(t), piece.value(t))
        term_values = pieces.map { |piece| piece.value(t) }
        # Positive generic
        (constraints - [constraint(t)]).each do |o|
          result.push Premise.new(piece, constraint(t), piece.value(t), o)
        end
        # Negative specific
        (term_values - [piece.value(t)]).each do |o|
          result.push Premise.new(piece, constraint(t), o)
        end
        # Negative generic
        (term_values - [piece.value(t)]).each do |o|
          (constraints - [constraint(t)]).each do |id|
            result.push Premise.new(piece, constraint(t), o, id)
          end
        end
      end
      result
    end
  end
end
