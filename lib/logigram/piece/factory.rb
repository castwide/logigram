# frozen_string_literal: true

module Logigram
  class Piece
    class Factory
      def initialize(constraints, terms, objects, selection)
        @constraints = constraints
        @terms = terms
        @objects = objects
        @selection = selection
      end

      def pieces
        @pieces ||= generate_pieces
      end

      def self.make constraints, terms, objects, selection
        new(constraints, terms, objects, selection).pieces
      end

      private

      # @return [Array<Constraint>]
      attr_reader :constraints

      # @return [Array<Constraint>]
      attr_reader :terms

      # @return [Array<Object>]
      attr_reader :objects

      # @return [Object]
      attr_reader :selection

      def generate_pieces
        solution = generate_solution(selection)
        objects.map do |object|
          object == selection ? solution : generate_candidate(object, solution)
        end
      end

      def generate_solution object
        properties = constraints.map do |con|
          value = con.reserves.sample || constraint_repo[con].sample
          raise 'NOOO!' unless value
          constraint_repo[con].delete value if con.unique?
          Property.new(con, value)
        end
        Piece.new(object, properties)
      end

      def generate_candidate object, solution
        # @todo Make sure the candidate can select properties that don't match
        #   the solution terms
        properties = constraints.map do |con|
          value = constraint_repo[con].sample
          raise 'NOOO!' unless value
          constraint_repo[con].delete value if con.unique?
          Property.new(con, value)
        end
        validated = validate(properties, solution)
        Piece.new(object, validated)
      end

      def constraint_repo
        @constraint_repo ||= constraints.map { |con| [con, con.values.dup] }.to_h
      end

      def validate properties, solution
        check = properties.select { |prop| terms.include?(prop.constraint) }
        conflicts = check.select { |prop| prop.value == solution.value(prop.constraint.name) }
        return properties if conflicts.length < check.length
        fix = conflicts.sample
        valid = properties - [fix]
        value = (fix.constraint.values - [fix.value]).sample
        raise 'OH NO!' unless value
        valid.push Property.new(fix.constraint, value)
        valid
      end
    end
  end
end
