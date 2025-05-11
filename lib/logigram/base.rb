# frozen_string_literal: true

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

    # @param objects [Array<Object>] The piece identifiers
    # @param selection [Object] The object to use as the solution
    # @param determinants [String, Constraint, Array<String, Constraint>] The solution constraints or names
    def initialize(objects, selection: objects.sample, determinants: self.class.constraints.sample)
      determinants = [determinants].flatten
      det_cons = determinants.map { |id| id.is_a?(Constraint) ? id : self.class.constraint(id) }
      super(constraints: self.class.constraints, objects: objects, selection: selection, determinants: det_cons)
    end

    # @param name [String]
    # @return [Constraint, nil]
    def constraint(name)
      self.class.constraint name
    end
  end
end
