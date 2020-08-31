# A simple example of a Logigram puzzle

require 'logigram'

class Puzzle < Logigram::Base
  # Apply constraints that will be used to generate the puzzle's premises
  constrain 'color', ['red', 'green', 'blue'], subject: 'the %{value} animal'
  constrain 'size', ['small', 'medium', 'large'], subject: 'the %{value} animal'
end

# Create a new puzzle with three pieces. If a `solution` is not specified, the
# puzzle will select one at random
puzzle = Puzzle.new(['the dog', 'the cat', 'the pig'])

# The challenge holds the clues the player can use to solve the puzzle
challenge = Logigram::Challenge.new(puzzle)

puts "The animals are #{puzzle.pieces.join(', ')}"
puzzle.constraints.each do |c|
  puts "One of each is #{c.values.join(', ')}"
end
puts "Which animal #{puzzle.solution_predicate}?"

puts "Known facts:"
challenge.clues.each do |c|
  puts "* #{c.to_s.capitalize}"
end

print "Press enter for the solution...."
STDIN.gets

puts puzzle.solution.to_s.capitalize
