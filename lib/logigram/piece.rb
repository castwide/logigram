module Logigram
  class Piece
    # @return [Object]
    attr_reader :object

    def initialize object, terms, name: nil
      @object = object
      @terms = terms
      @name = name
    end

    def name
      @name || object.to_s
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
