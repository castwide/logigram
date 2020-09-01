module Logigram
  # A base class for creating logic puzzles. Authors should not instantiate
  # this class directly, but extend it with their own puzzle implementations.
  #
  # @example
  #   class Puzzle < Logigram::Base
  #     constrain 'color', ['red', 'green', 'blue'], subject: 'the %{value} thing'
  #     constrain 'size', ['small', 'medium', 'large'], subject: 'the %{value} thing'
  #   end
  #
  class Base
    # The piece that represents the solution. The puzzle's premises should be
    # clues from which this solution can be deduced.
    #
    # @return [Piece]
    attr_reader :solution

    class << self
      # An array of the puzzle's constraints.
      #
      # Constraints specify attributes that get assigned to puzzle pieces.
      # When a puzzle gets instantiated, each piece is assigned a value from
      # each constraint, and the puzzle uses them to generate premises.
      #
      # @return [Array<Constraint>]
      def constraints
        constraint_map.values
      end

      # Get a constraint by name.
      #
      # @param name [String]
      # @return [Constraint, nil]
      def constraint name
        constraint_map[name]
      end

      protected

      # Add a constraint to the puzzle.
      #
      # @example The pieces in the instantiated puzzle will each be assigned a unique color and size.
      #
      #   class MyPuzzle < Logigram::Base
      #     constrain 'color', ['red', 'green', 'blue']
      #     constrain 'size', ['small', 'medium', 'large']
      #   end
      #   puzzle = MyPuzzle.new ['dog', 'cat', 'rat']
      #
      # @param name [String]
      # @param values [Array<Object>]
      # @param subject [String, nil]
      # @param predicate [String, nil]
      # @param negative [String, nil]
      # @param reserve [Object, Array<Object>, nil] Require the solution to be one of these values
      # @return [Logigram::Constraint] The newly created constraint
      def constrain name, values, subject: nil, predicate: nil, negative: nil, reserve: nil
        f = Constraint.new(name, values, subject: subject, predicate: predicate, negative: negative, reserve: reserve)
        constraint_map[name] = f
        f
      end

      private

      def constraint_map
        @constraint_map ||= {}
      end
    end

    # Generate a puzzle with the provided configuration.
    #
    # The `objects` array is required. If `solution` and `term` are not provided, they'll be randomly generated.
    #
    # @param objects [Array<Object>] The piece identifiers
    # @param solution [Object, nil] Which object to use as the solution
    # @param term [String, nil] The solution term
    def initialize objects, solution: nil, term: nil
      @object_pieces = {}
      @solution_term = term || self.class.constraints.map(&:name).sample
      generate_pieces objects, (solution || objects.sample)
    end

    # @return [Array<Premise>]
    def premises
      @premises ||= generate_all_premises
    end

    # @return [Array<Constraint>]
    def constraints
      self.class.constraints
    end

    # @param name [String]
    # @return [Constraint, nil]
    def constraint name
      self.class.constraint name
    end

    # Get an array of values for a constraint.
    # This method will only include values that are currently assigned to pieces.
    #
    # @return [Array<Object>]
    def term_values key
      # Use an intersection to retain the order in which the values were
      # assigned to the constraint
      self.class.constraint(key).values & pieces.map { |p| p.value(key) }
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
      @solution.value(@solution_term)
    end

    # Shortcut to get the solution term's predicate, e.g., "is red"
    #
    # @return [String]
    def solution_predicate
      self.class.constraint(@solution_term).predicate(@solution.value(@solution_term))
    end

    # @return [Array<Logigram::Piece>]
    def pieces
      @object_pieces.values
    end

    # Get the piece associated with an object.
    #
    # @param object [Object] The object used to generate the piece
    # @return [Logigram::Piece]
    def piece_for object
      @object_pieces[object]
    end

    private

    # Generate the puzzle pieces.
    #
    # @param objects [Array<#to_s>]
    # @param solution [#to_s, nil]
    # @return [void]
    def generate_pieces objects, solution
      selected = solution || objects.sample
      repo = generate_constraint_repo
      objects.each { |o| insert o, o == selected, repo }
    end

    def insert object, selected, repo
      terms = {}
      # @param c [Constraint]
      constraints.each do |c|
        pick = selected ? repo[c.name][:answer] : repo[c.name][:others].pop
        raise "Unable to select value for constraint '#{c.name}'" if pick.nil?
        terms[c.name] = pick
      end
      p = Piece.new(object, terms)
      @solution = p if selected
      @object_pieces[object] = p
    end

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
    def generate_piece_premises piece
      result = []
      piece.terms.each do |t|
        # Positive specific
        result.push Premise.new(piece, self.class.constraint(t), piece.value(t))
        # Positive generic
        (self.class.constraints - [self.class.constraint(t)]).each do |o|
          result.push Premise.new(piece, self.class.constraint(t), piece.value(t), o)
        end
        # Negative specific
        (term_values(t) - [piece.value(t)]).each do |o|
          result.push Premise.new(piece, self.class.constraint(t), o)
        end
        # Negative generic
        (term_values(t) - [piece.value(t)]).each do |o|
          (self.class.constraints - [self.class.constraint(t)]).each do |id|
            result.push Premise.new(piece, self.class.constraint(t), o, id)
          end
        end
      end
      result
    end

    def generate_constraint_repo
      r = {}
      self.class.constraints.each do |constraint|
        answer = constraint.reserves.sample
        r[constraint.name] = {
          answer: answer,
          others: (constraint.values - [answer]).shuffle
        }
      end
      r
    end
  end
end
