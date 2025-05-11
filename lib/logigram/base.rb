module Logigram
  # A base class for creating logic puzzles. Authors should not instantiate
  # this class directly, but extend it with their own puzzle implementations.
  #
  # @example
  #   class Puzzle < Logigram::Base
  #     constrain 'color', ['red', 'green', 'blue']
  #     constrain 'size', ['small', 'medium', 'large']
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
      def constrain(name, values, reserve: nil, formatter: Formatter::DEFAULT)
        constraint_map[name] = Constraint.new(name, values, reserve: reserve, formatter: formatter)
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
    # @param solution [Object] Which object to use as the solution
    # @param terms [String, Array<String>, nil] The solution term(s)
    # @param recur [String, Array<String>, nil] Recurring constraints (uniqueness never enforced)
    def initialize(objects, solution: objects.sample, terms: nil, recur: nil)
      @object_pieces = {}
      @solution_terms = terms ? [terms].flatten : [constraints.map(&:name).sample]
      @recur = recur ? [recur].flatten : []
      objects.push solution unless objects.include?(solution)
      generate_pieces objects, solution
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
    def constraint(name)
      self.class.constraint name
    end

    # Get an array of values for a constraint.
    # This method will only include values that are currently assigned to pieces.
    #
    # @return [Array<Object>]
    def term_values(key)
      # Use an intersection to retain the order in which the values were
      # assigned to the constraint
      constraint(key).values & pieces.map { |piece| piece.value(key) }
    end

    # The terms that should be used to identify the solution.
    #
    # @return [Array<String>]
    attr_reader :solution_terms

    # Shortcut to get the solution terms' values, e.g., "red"
    #
    # @return [Array<String>]
    def solution_values
      @solution_terms.map { |t| @solution.value(t) }
    end

    # Shortcut to get the solution terms' predicates, e.g., "is red"
    #
    # @return [Array<String>]
    def solution_predicates
      @solution_terms.map { |t| constraint(t).predicate(@solution.value(t)) }
    end

    # @return [Array<Logigram::Piece>]
    def pieces
      @object_pieces.values
    end

    # Get the piece associated with an object.
    #
    # @param object [Object] The object used to generate the piece
    # @return [Logigram::Piece]
    def piece_for(object)
      @object_pieces[object]
    end

    private

    # Generate the puzzle pieces.
    #
    # @param objects [Array<Object>]
    # @param solution [Object]
    # @return [void]
    def generate_pieces(objects, solution)
      selected_values = {}
      solution_terms.each do |term|
        selected_values[term] = constraint(term).reserves.sample
      end
      @solution = generate_piece(solution, selected_values, true)
      objects.each do |obj|
        @object_pieces[obj] = if obj == solution
                                @solution
                              else
                                generate_piece(obj, selected_values, false)
                              end
      end
    end

    # @param object [Object]
    # @param selected_values [Hash]
    # @param selected [Boolean]
    # @return [Piece]
    def generate_piece(object, selected_values, selected)
      constraint_repo = generate_constraint_repo(selected_values, selected)
      properties = []
      constraint_repo.each_pair do |key, values|
        raise "Unable to select value for constraint '#{key}'" if values.empty?

        # terms[key] = values.sample
        properties.push Property.new(constraint(key), values.sample)
      end
      Piece.new(object, properties)
    end

    # @param selected_values [Hash]
    # @param selected [Boolean]
    # @return [Hash]
    def generate_constraint_repo(selected_values, selected)
      repo = {}
      # Setting a fixed term ensures that at least one solution term will not
      # be duplicated by another piece
      fixed_term = selected_values.keys.sample
      constraints.each do |c|
        repo[c.name] = if selected_values.key?(c.name)
                         if selected
                           [selected_values[c.name]]
                         elsif c.name == fixed_term
                           limit_available_values(c, selected_values[fixed_term], selected)
                         else
                           limit_available_values(c, nil, false)
                         end
                       else
                         limit_available_values(c, nil, selected)
                       end
      end
      repo
    end

    # @param constraint [Constraint]
    # @param exception [String]
    # @param selected [Boolean]
    # @return [Array<String>]
    def limit_available_values(constraint, exception, selected)
      available = (selected ? constraint.reserves : constraint.values) - [exception]
      filtered = available -
                 [@solution&.value(constraint.name)] -
                 (@recur.include?(constraint.name) ? [] : pieces.map { |p| p.value(constraint.name) })
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
    def generate_piece_premises(piece)
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
