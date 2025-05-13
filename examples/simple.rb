# A simple example of a Logigram puzzle

require 'bundler/setup'
require 'logigram'

class Puzzle < Logigram::Base
  # Create a formatter that refers to pieces as "animals" instead of "things"
  formatter = Logigram::Formatter.new(subject: 'the %<value>s animal')

  # Apply constraints that will be used to generate the puzzle's premises
  constrain 'color', ['red', 'green', 'blue'], formatter: formatter
  constrain 'size', ['small', 'medium', 'large'], formatter: formatter
end

# Create a new puzzle with three pieces. If a `solution` is not specified, the
# puzzle will select one at random
puzzle = Puzzle.new(['the dog', 'the cat', 'the pig'])

# The challenge holds the clues the player can use to solve the puzzle
challenge = Logigram::Challenge.new(puzzle, difficulty: :medium)

puts "The animals are #{puzzle.pieces.join(', ')}"
puzzle.constraints.each do |c|
  puts "One of each is #{c.values.join(', ')}"
end

puts "Which animal #{puzzle.solution.property(puzzle.determinants.first.name).predicate}?"

puts 'Known facts:'
challenge.premises.each do |premise|
  puts "* #{premise.to_s.capitalize}"
end

print 'Press enter for the solution....'
$stdin.gets

puts "#{puzzle.solution.to_s.capitalize} #{puzzle.solution.property(puzzle.determinants.first.name).predicate}."
