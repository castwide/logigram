# frozen_string_literal: true

require 'logigram/formatter/conjugations'

module Logigram
  # Rules for generating premise statements.
  #
  # @example Use the default rules, but refer to pieces as "objects" instead of "things"
  #   Formatter.new(subject: 'the %{value} object')
  #   # Example premise: "the green object is large"
  #
  # @example Use the default rules, except make the "be" conjugations past tense
  #   Formatter.new(verb: ['was', 'were', 'was not', 'were not'])
  #   # Example premise: "the red thing was small"
  #
  class Formatter
    # @param subject [String]
    # @param plural [String]
    # @param verb [Symbol, Array<String>]
    # @param descriptor [String]
    def initialize(subject: 'the %<value>s thing', plural: "#{subject}s", verb: :be, descriptor: '%<value>s')
      @conjugations = normalize_verb(verb)
      @subject = subject
      @plural = plural
      @descriptor = descriptor
    end

    def subject(value, amount = 1)
      format((amount == 1 ? @subject : @plural), value: fix_article(value))
    end

    def predicate(value, amount = 1)
      "#{predicate_verb(amount)} #{format(@descriptor, value: value)}"
    end

    def negative(value, amount = 1)
      "#{negative_verb(amount)} #{format(@descriptor, value: value)}"
    end

    def descriptor(value)
      format(@descriptor, value: value)
    end

    def verb(amount = 1, affirmative = true)
      affirmative ? predicate_verb(amount) : negative_verb(amount)
    end

    def predicate_verb(amount)
      amount == 1 ? @conjugations[0] : @conjugations[1]
    end

    def negative_verb(amount)
      amount == 1 ? @conjugations[2] : @conjugations[3]
    end

    private

    # @param value [String]
    def fix_article(value)
      return value unless @subject.include?('the %<value>s')

      value.to_s.sub(/^(a|an) /, '')
    end

    # @return [String]
    def normalize_verb(verb)
      CONJUGATIONS[verb] ||
        validate_conjugation(verb) ||
        raise(ArgumentError, 'Verb must be a predefined infinitive or an array of verb forms')
    end

    # @param [String]
    def validate_conjugation(verb)
      verb if verb.is_a?(Array) && verb.length == 4
    end

    DEFAULT = Formatter.new
  end
end
