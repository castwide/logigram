# frozen_string_literal: true

module Logigram
  # Constraints describe features that puzzle pieces can possess. They are
  # identified by name and have a finite set of possible values. When a puzzle
  # is generated, its pieces are assigned a unique random value for each
  # constraint.
  #
  class Constraint
    # @return [String]
    attr_reader :name

    # All possible values for the constraint
    #
    # @return [Array<String>]
    attr_reader :values

    # The subset of values that can be applied to solutions. When a puzzle
    # generates a solution, its value for the constraint should be one of the
    # reserves. (By default, reserves are all possible values.)
    #
    # @return [Array<String>]
    attr_reader :reserves

    attr_reader :formatter

    # @param name [String]
    # @param values [Array] All possible values for the constraint
    # @param reserve [Object, Array<Object>, nil] Values to reserve for solutions
    # @param formatter [Formatter] Formatting rules
    # @param unique [Boolean]
    def initialize name, values, reserve: nil, formatter: Formatter::DEFAULT, unique: true
      @name = name
      @values = values
      @reserves = configure_reserves(reserve)
      @formatter = formatter
      @unique = unique
    end

    def unique?
      @unique
    end

    # A noun form for the value, e.g., "the red thing"
    #
    # @return [String]
    def subject value
      validate value
      formatter.subject(value)
    end

    # A verbal predicate for the value, e.g., "is red"
    #
    # @return [String]
    def predicate value, quantity = 1
      validate value
      formatter.predicate(value, quantity)
    end

    # A negative verbal predicate form for the value, e.g., "is not red"
    def negative value, quantity = 1
      validate value
      formatter.negative(value, quantity)
    end

    private

    # @raise [ArgumentError] if the value is not valid
    # @param value [String]
    # @return [String]
    def validate value
      return value if values.include?(value)
      raise ArgumentError, "Constraint for #{name} received invalid value #{value}"
    end

    # @param reserve [String, Array<Sting>, nil]
    def configure_reserves(reserve)
      return values unless reserve
      [reserve].flatten.map { |v| validate(v) }
    end
  end
end
