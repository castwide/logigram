module Logigram
  class Formatter
    CONJUGATIONS = {
      be: ['is', 'are', 'is not', 'are not'],
      have: ['has', 'have', 'does not have', 'do not have']
    }

    attr_reader :verb

    def initialize subject: 'the %{value} thing', plural: "#{subject}s", verb: :be, descriptor: '%{value}'
      raise ArgumentError, "Unrecognized verb #{verb}" unless CONJUGATIONS.key?(verb)
      @verb = verb
      @subject = subject
      @plural = plural
      @descriptor = descriptor
    end

    def subject value, amount = 1
      (amount == 1 ? @subject : @plural) % {value: value}
    end

    def predicate value, amount = 1
      "#{predicate_verb(amount)} #{@descriptor % {value: value}}"
    end

    def negative value, amount = 1
      "#{negative_verb(amount)} #{@descriptor % {value: value}}"
    end

    private

    def predicate_verb amount
      amount == 1 ? CONJUGATIONS[verb][0] : CONJUGATIONS[verb][1]
    end

    def negative_verb amount
      amount == 1 ? CONJUGATIONS[verb][2] : CONJUGATIONS[verb][3]
    end
  end

  Formatter::DEFAULT = Formatter.new
end
