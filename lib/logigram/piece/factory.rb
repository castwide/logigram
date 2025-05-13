# frozen_string_literal: true

module Logigram
  class Piece
    # A class for generating puzzle pieces.
    #
    class Factory
      # @return [Array<Piece>]
      attr_reader :pieces

      # @return [Piece]
      attr_reader :solution

      # @param constraints [Array<Constraint>]
      # @param determinants [Array<Constraint>]
      # @param objects [Array<Object>]
      # @param selection [Object]
      def initialize(constraints, determinants, objects, selection)
        @constraints = constraints
        @determinants = determinants
        @solution = generate_solution(selection)
        @pieces = generate_pieces(objects)
      end

      # Generate puzzle pieces from provided constraints and objects.
      #
      # @param constraints [Array<Constraint>]
      # @param determinants [Array<Constraint>]
      # @param objects [Array<Object>]
      # @param selection [Object]
      # @return [Array(Array<Piece>, Piece)]
      def self.make(constraints, determinants, objects, selection)
        fac = new(constraints, determinants, objects, selection)
        [fac.pieces, fac.solution]
      end

      private

      # @return [Array<Constraint>]
      attr_reader :constraints

      # @return [Array<Constraint>]
      attr_reader :determinants

      # @param objects [Array<Object>]
      def generate_pieces(objects)
        drop = true
        objects.map do |object|
          # Always drop the first selected value of non-unique constraints to
          # improve the likelihood of variety
          object == solution.object ? solution : generate_candidate(object, drop).tap { drop = false }
        end
      end

      # @param object [Object]
      # @return [Piece]
      def generate_solution(object)
        properties = constraints.map do |con|
          value = con.reserves.sample || constraint_repo[con].sample
          raise "Unable to select value for constraint '#{con.name}'" unless value

          constraint_repo[con].delete value if con.unique?
          Property.new(con, value)
        end
        Piece.new(object, properties)
      end

      # @param object [Object]
      # @param drop [Boolean]
      # @return [Piece]
      def generate_candidate(object, drop)
        properties = constraints.map do |con|
          value = constraint_repo[con].sample
          raise "Unable to select value for constraint '#{con.name}'" unless value

          constraint_repo[con].delete value if con.unique? || drop
          Property.new(con, value)
        end
        Piece.new(object, validate(properties))
      end

      # @return [Hash{Constraint => Array<String>}]
      def constraint_repo
        @constraint_repo ||= constraints.map { |con| [con, con.values.dup] }.to_h
      end

      # Ensure that the properties are not an exact match for the solution's
      # properties.
      #
      # @param properties [Array<Property>]
      # @return [Array<Property>]
      def validate(properties)
        # @todo In addition to guaranteeing a unique solution, we should verify
        #   there's never a case where all the pieces have the same value for a
        #   property.
        check = properties.select { |prop| determinants.include?(prop.constraint) }
        conflicts = check.select { |prop| prop.value == solution.value(prop.constraint.name) }
        return properties if conflicts.length < check.length

        replace properties, conflicts.sample
      end

      # Replace the value for one of the properties.
      #
      # @param properties [Array<Property>]
      # @param fix [Property]
      # @return [Array<Property>]
      def replace(properties, fix)
        update = properties - [fix]
        value = (fix.constraint.values - [fix.value]).sample
        raise "Unable to select value for constraint '#{fix.constraint.name}'" unless value

        update.push Property.new(fix.constraint, value)
        update
      end
    end
  end
end
