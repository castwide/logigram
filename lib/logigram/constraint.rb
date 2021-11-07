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

    # @param name [String]
    # @param values [Array] All possible values for the constraint
    # @param subject [String, nil] The format string for the subject's common noun
    # @param predicate [String, nil] The format string for the verbal predicate
    # @param negative [String, nil] The format string for negative predicates
    # @param reserve [Object, Array<Object>, nil] Values to reserve for solutions
    def initialize name, values, subject: nil, predicate: nil, negative: nil, reserve: nil
      @name = name
      @values = values
      @subject = subject || 'the %{value} thing'
      @predicate = predicate || 'is %{value}'
      @negative = negative || 'is not %{value}'
      @reserves = configure_reserves(reserve)
    end

    # A noun form for the value, e.g., "the red thing"
    #
    # @return [String]
    def subject value
      validate value
      @subject % { value: value }
    end

    # A verbal predicate for the value, e.g., "is red"
    #
    # @return [String]
    def predicate value
      validate value
      @predicate % { value: value }
    end

    # A negative verbal predicate form for the value, e.g., "is not red"
    def negative value
      validate value
      @negative % { value: value }
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
