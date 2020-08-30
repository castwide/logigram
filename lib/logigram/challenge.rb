module Logigram
  # Use the Logigram::Challenge class to generate a list of clues from a
  # puzzle.
  #
  class Challenge
    # @return [Array<Logigram::Premise>]
    attr_reader :clues

    # @param puzzle [Logigram::Base]
    def initialize puzzle
      temp puzzle
    end

    def temp puzzle
      @puzzle = puzzle
      clues = []

      terms = (all_terms - [puzzle.solution_term])
      pieces = all_pieces
      # One piece doesn't get a specific affirmative
      other = pieces.pop

      used = []

      (pieces - [other]).each do |piece|
        # specific affirmative
        terms = (all_terms - [puzzle.solution_term]) if terms.empty?
        term = terms.pop
        used.push terms
        clues.push Logigram::Premise.new(piece, puzzle.constraints[term], piece.value(term))
      end
      # Rest are specific negative
      [other].each do |piece|
        # terms = all_terms if terms.empty?
        term = terms.pop
        term = puzzle.solution_term if term.nil?
        # herr = (pieces - [piece, puzzle.solution]).shuffle.first
        herr = pieces.shuffle.first
        clues.push Logigram::Premise.new(other, puzzle.constraints[term], herr.value(term))
      end

      if puzzle.terms.length > 2
        pieces = all_pieces
        (puzzle.terms - [puzzle.solution_term]).each do |term|
          pieces = all_pieces if pieces.empty?
          piece = pieces.pop
          ident = (puzzle.terms - [term]).shuffle.pop
          clues.push Logigram::Premise.new(piece, puzzle.constraints[term], piece.value(term), puzzle.constraints[ident])
        end

        terms = all_terms
        all_pieces.each do |piece|
          terms = all_terms if terms.empty?
          term = terms.pop
          other = (puzzle.pieces - [piece]).shuffle.pop
          ident = (puzzle.terms - [term]).shuffle.pop
          clues.push Logigram::Premise.new(piece, puzzle.constraints[term], other.value(term), puzzle.constraints[ident])
        end

        # One more should guarantee the puzzle can always be solved
        # Generic negative on the solution piece
        # term = (all_terms - [puzzle.solution_term]).shuffle.pop
        # ident = (all_terms - [puzzle.solution_term, term]).shuffle.pop
        # other = (puzzle.pieces - [puzzle.solution]).shuffle.pop
        # clues.push Logigram::Premise.new(puzzle.solution, puzzle.constraints[term], other.value(term), puzzle.constraints[ident])
      end

      @clues = clues
    end

    def all_terms
      @all_terms ||= @puzzle.terms.shuffle
      @all_terms.clone
    end

    def all_pieces
      @all_pieces ||= @puzzle.pieces.shuffle
      @all_pieces.clone
    end
  end
end
