module Logigram
  # A base class for creating logic puzzles. Authors should not instantiate
  # this class directly, but extend it with their own puzzle implementations.
  #
  class Base
    attr_reader :pieces, :premises

    class << self
      # A hash of the puzzle's constraints.
      # Constraints specify attributes that get assigned to puzzle pieces.
      # When a puzzle gets instantiated, each piece is assigned a value from
      # each constraint, and the puzzle uses them to generate premises.
      #
      # @return [Hash<String, Logigram::Constraint>]
      def constraints
        @constraints ||= {}
      end

      protected

      # Add a constraint to the puzzle.
      #
      # @example The pieces in the instantiated puzzle will each be assigned a
      # unique color and size.
      #
      #   class MyPuzzle < Logigram::Base
      #     constrain 'color', 'red', 'green', 'blue'
      #     constrain 'size', 'small', 'medium', 'large'
      #   end
      #   puzzle = MyPuzzle.new ['dog', 'cat', 'rat']
      #
      # @return [Logigram::Constraint] The newly created constraint
      def constrain name, *values, subject: nil, predicate: nil, negative: nil
        f = Constraint.new(name, *values, subject: subject, predicate: predicate, negative: negative)
        constraints[name] = f
        f
      end
    end

    def initialize objects, solution: nil, term: nil
      @object_pieces = {}
      @picks = {}
      self.class.constraints.each_pair { |k, d| @picks[d.name] = d.values.clone }

      @pieces = []
      objects.each do |p|
        r = insert(p)
        @solution_piece = r if p ==solution
      end

      @solution_piece ||= @pieces.sample
      @solution_term = term || @picks.keys.sample

      @premises = generate_all_premises
    end

    def constraints
      self.class.constraints
    end

    def terms
      self.class.constraints.keys
    end

    # Get an array of possible values for a constraint.
    # This method will only include values that are currently in use.
    #
    # @return [Array<Object>]
    def term_values key
      result = []
      @pieces.each { |p| result.push p.value(key) unless p.value(key).nil? }
      self.class.constraints[key].values & result
    end

    # Alias for solution_piece.
    #
    # @return [Logigram::Piece]
    def solution
      @solution_piece
    end

    # The piece that represents the solution. The puzzle's premises should be
    # clues from which this solution can be deduced.
    #
    # @return [Logigram::Piece]
    def solution_piece
      @solution_piece
    end

    # The term that should be used to identify the solution.
    #
    # @return [String]
    def solution_term
      @solution_term
    end

    # Shortcut to get the solution tern's value, e.g., "red"
    #
    # @return [String]
    def solution_value
      @solution_piece.value(@solution_term)
    end

    # Shortcut to get the solution facet's predicate, e.g., "is red"
    #
    # @return [String]
    def solution_predicate
      self.class.constraints[@solution_term].predicate(@solution_piece.value(@solution_term))
    end

    # Select an unused value for a term.
    #
    def pick key
      raise 'Term not set' unless self.class.constraints.include?(key)
      raise "Not enough values in #{key} term" if @picks[key].empty?
      picked = @picks[key].sample
      @picks[key].delete picked
      picked
    end

    # Get the piece associated with an object.
    #
    # @return [Logigram::Piece]
    def piece_for object
      @object_pieces[object]
    end

    private

    # Add a piece to the puzzle.
    #
    # @return [Logigram::Piece] The newly created piece.
    def insert object
      p = Piece.new(object, self)
      @object_pieces[object] = p
      @pieces.push p
      p
    end

    # Create an array of all possible premises for the puzzle.
    #
    # @return [Array<Logigram::Premise>]
    def generate_all_premises
      result = []
      pieces.each do |piece|
        result.concat generate_piece_premises(piece)
      end
      result
    end

    # Create an array of all possible premises for the specified piece.
    #
    # @param piece [Logigram::Piece]
    # @return [Array<Logigram::Premise>]
    def generate_piece_premises piece
      result = []
      piece.terms.each do |t|
        # Positive specific
        result.push Premise.new(piece, self.class.constraints[t], piece.value(t))
        # Positive generic
        (self.class.constraints.values - [self.class.constraints[t]]).each do |o|
          result.push Premise.new(piece, self.class.constraints[t], piece.value(t), o)
        end
        # Negative specific
        (term_values(t) - [piece.value(t)]).each do |o|
          result.push Premise.new(piece, self.class.constraints[t], o)
        end
        # Negative generic
        (term_values(t) - [piece.value(t)]).each do |o|
          (self.class.constraints.values - [self.class.constraints[t]]).each do |id|
            result.push Premise.new(piece, self.class.constraints[t], o, id)
          end
        end
      end
      result
    end
  end
end
