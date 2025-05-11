module Logigram
  # A base class for creating logic puzzles. Authors should not instantiate
  # this class directly, but extend it with their own puzzle implementations.
  #
  # @example
  #   class Example < Logigram::Base
  #     constrain 'color', ['red', 'green', 'blue']
  #     constrain 'size', ['small', 'medium', 'large']
  #   end
  #
  class Base < Puzzle
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
      def constraint(name)
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
      # @param reserve [Object, Array<Object>, nil] Require the solution to be one of these values
      # @param formatter [Formatter] Formatting rules for generated premises
      # @return [Logigram::Constraint] The newly created constraint
      def constrain(name, values, reserve: nil, formatter: Formatter::DEFAULT, unique: true)
        constraint_map[name] = Constraint.new(name, values, reserve: reserve, formatter: formatter, unique: unique)
      end

      private

      # @return [Hash<String, Constraint>]
      def constraint_map
        @constraint_map ||= {}
      end
    end

    # Generate a puzzle with the provided configuration.
    #
    # The `objects` array is required. If `solution` and `terms` are not provided, they'll be randomly generated.
    #
    # @param objects [Array<Object>] The piece identifiers
    # @param selection [Object] Which object to use as the solution
    # @param terms [String, Constraint, Array<String, Constraint>, nil] The solution term(s) or term name(s)
    # @param recur [String, Array<String>, nil] Recurring constraints (uniqueness never enforced)
    def initialize(objects, selection: objects.sample, terms: nil)
      terms = terms ? [terms].flatten : [self.class.constraints.map(&:name).sample]
      term_constraints = terms.map { |tm| tm.is_a?(Constraint) ? tm : self.class.constraint(tm) }
      super(constraints: self.class.constraints, objects: objects, selection: selection, terms: term_constraints)
    end

    # @param name [String]
    # @return [Constraint, nil]
    def constraint(name)
      self.class.constraint name
    end

    # Shortcut to get the solution terms' values, e.g., "red"
    #
    # @return [Array<String>]
    def solution_values
      solution.properties.map(&:value)
    end

    # Shortcut to get the solution terms' predicates, e.g., "is red"
    #
    # @return [Array<String>]
    def solution_predicates
      terms.map { |term| term.predicate(solution.value(term.name)) }
    end

    # Get the piece associated with an object.
    #
    # @param object [Object] The object used to generate the piece
    # @return [Logigram::Piece]
    def piece_for(object)
      pieces.find { |piece| piece.object == object }
    end
  end
end
