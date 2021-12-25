require 'logigram/formatter/conjugations'

module Logigram
  class Formatter
    # @param subject [String]
    # @param plural [String]
    # @param verb [Symbol, Array<String>]
    # @param descriptor [String]
    def initialize subject: 'the %{value} thing', plural: "#{subject}s", verb: :be, descriptor: '%{value}'
      @conjugations = validate_verb(verb)
      @subject = subject
      @plural = plural
      @descriptor = descriptor
    end

    def subject value, amount = 1
      (amount == 1 ? @subject : @plural) % {value: fix_article(value)}
    end

    def predicate value, amount = 1
      "#{predicate_verb(amount)} #{@descriptor % {value: value}}"
    end

    def negative value, amount = 1
      "#{negative_verb(amount)} #{@descriptor % {value: value}}"
    end

    private

    def predicate_verb amount
      amount == 1 ? @conjugations[0] : @conjugations[1]
    end

    def negative_verb amount
      amount == 1 ? @conjugations[2] : @conjugations[3]
    end

    def fix_article(value)
      return value unless @subject.include?('the %{value}')
      value.to_s.sub(/^(a|an) /, '')
    end

    def validate_verb verb
      CONJUGATIONS[verb] ||
        validate_conjugation(verb) ||
        raise(ArgumentError, 'Verb must be a predefined infinitive or an array of verb forms')
    end

    def validate_conjugation verb
      return verb if verb.is_a?(Array) && verb.length == 4
    end
  end

  Formatter::DEFAULT = Formatter.new
end
