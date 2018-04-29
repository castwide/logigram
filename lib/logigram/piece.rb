module Logigram
  class Piece
    # @return [Object]
    attr_reader :object

    # @return [String]
    attr_reader :name

    # @return [Array<Logigram::Constraint>]
    attr_reader :constraints

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
    def value key
      @terms[key]
    end

    def terms
      @terms.keys
    end

    def to_s
      name
    end
  end
end
