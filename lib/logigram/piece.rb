module Logigram
  class Piece
    # @return [Object]
    attr_reader :object

    # @return [String]
    attr_reader :name

    # @return [Array<Logigram::Constraint>]
    attr_reader :constraints

    # @param object [Object]
    # @param puzzle [Logigram::Base]
    # @param name [String, nil]
    def initialize object, puzzle, name: nil
      @object = object
      @name = name || object.to_s
      @constraints = puzzle.constraints.values
      @terms = {}
      puzzle.terms.each do |k|
        @terms[k] = puzzle.pick(k)
      end
    end

    # Get the value assigned to this piece for the specified term.
    #
    # @param term [String] The name of a constraint
    def value term
      @terms[term]
    end

    # The names of all the constraints associated with this piece.
    #
    # @return [Array<String>]
    def terms
      @terms.keys
    end

    def to_s
      name
    end
  end
end
