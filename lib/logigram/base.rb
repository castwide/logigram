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
    # The `objects` array is required. If `solution` and `terms` are not provided, they'll be randomly generated.
    #
    # @param objects [Array<Object>] The piece identifiers
    # @param solution [Object, nil] Which object to use as the solution
    # @param terms [String, Array<String>, nil] The solution term(s)
    def initialize objects, solution: nil, terms: nil
      @object_pieces = {}
      @solution_terms = terms ? [terms].flatten : [constraints.map(&:name).sample]
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
      constraint(key).values & pieces.map { |p| p.value(key) }
    end

    # The term that should be used to identify the solution.
    #
    # @return [Array<String>]
    def solution_terms
      @solution_terms
    end

    def solution_term
      raise RuntimeError, 'Use `solution_terms` when there is more than one term' unless @solution_terms.length == 1
      @solution_terms.first
    end

    # Shortcut to get the solution terms' values, e.g., "red"
    #
    # @return [Array<String>]
    def solution_values
      @solution_terms.map { |t| @solution.value(t) }
    end

    # Shortcut to get the solution term's value, e.g., "red"
    #
    # @raise [RuntimeError] if there is more than one solution term
    # @return [String]
    def solution_value
      raise RuntimeError, 'Use `solution_values` when there is more than one term' unless @solution_terms.length == 1
      @solution.value(@solution_terms.first)
    end

    # Shortcut to get the solution terms' predicates, e.g., "is red"
    #
    # @return [Array<String>]
    def solution_predicates
      @solution_terms.map { |t| constraint(t).predicate(@solution.value(t)) }
    end

    # Shortcut to get the solution term's predicate, e.g., "is red"
    #
    # @return [String]
    def solution_predicate
      raise RuntimeError, 'Use `solution_predicates` when there is more than one term' unless @solution_terms.length == 1
      constraint(@solution_terms.first).predicate(@solution.value(@solution_terms.first))
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
      selected_object = solution || objects.sample
      selected_values = {}
      solution_terms.each do |term|
        c = constraint(term)
        selected_values[term] = c.reserves.sample
      end
      objects.each do |o|
        constraint_repo = generate_constraint_repo(selected_values, o == selected_object)
        terms = {}
        constraint_repo.each_pair do |key, values|
          raise "Unable to select value for constraint '#{key}'" if values.empty?
          terms[key] = values.sample
        end
        piece = Piece.new(o, terms)
        @solution = piece if o == selected_object
        @object_pieces[o] = piece
      end
    end

    def generate_constraint_repo selected_values, selected
      repo = {}
      # Setting a fixed term ensures that at least one solution term will not
      # be duplicated by another piece
      fixed_term = selected_values.keys.sample
      constraints.each do |c|
        if selected_values.key?(c.name)
          if selected
            repo[c.name] = [selected_values[c.name]]
          elsif c.name == fixed_term
            repo[c.name] = limit_available_values(c, selected_values[fixed_term])
          else
            repo[c.name] = limit_available_values(c, nil)
          end
        else
          repo[c.name] = limit_available_values(c, nil)
        end
      end
      repo
    end

    # @param constraint [Constraint]
    # @param exception [String]
    # @return [Array<String>]
    def limit_available_values constraint, exception
      available = constraint.values - [exception]
      filtered = available - pieces.map { |p| p.value(constraint.name) }
      filtered.empty? ? available : filtered
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
        result.push Premise.new(piece, constraint(t), piece.value(t))
        # Positive generic
        (constraints - [constraint(t)]).each do |o|
          result.push Premise.new(piece, constraint(t), piece.value(t), o)
        end
        # Negative specific
        (term_values(t) - [piece.value(t)]).each do |o|
          result.push Premise.new(piece, constraint(t), o)
        end
        # Negative generic
        (term_values(t) - [piece.value(t)]).each do |o|
          (constraints - [constraint(t)]).each do |id|
            result.push Premise.new(piece, constraint(t), o, id)
          end
        end
      end
      result
    end
  end
end
