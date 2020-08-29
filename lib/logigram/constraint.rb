module Logigram
  # Constraints describe features that puzzle pieces can possess. They are
  # identified by name and have a finite set of possible values. When a puzzle
  # is generated, its pieces are assigned a unique random value for each
  # constraint.
  #
  class Constraint
    attr_reader :name, :values

    # @param name [String]
    # @param values [Array]
    # @param subject [String, nil]
    # @param predicate [String, nil]
    # @param negative [String, nil]
    def initialize name, values, subject: nil, predicate: nil, negative: nil
      @name = name
      @values = values
      @subject = subject || 'the %{value} thing'
      @predicate = predicate || 'is %{value}'
      @negative = negative || 'is not %{value}'
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

    def validate value
      return if values.include?(value)
      raise ArgumentError, "Constraint for #{name} received invalid value #{value}"
    end
  end
end
