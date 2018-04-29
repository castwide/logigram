require 'logigram'

class SimplePuzzle < Logigram::Base
  constrain 'color', 'red', 'green', 'blue', subject: 'the %{value} animal'
  constrain 'size', 'small', 'medium', 'large', subject: 'the %{value} animal'
end

puzzle = SimplePuzzle.new(['the dog', 'the cat', 'the pig'])
challenge = Logigram::Challenge.new(puzzle)

puts "The animals are #{puzzle.pieces.join(', ')}"
puzzle.constraints.values.each do |c|
  puts "One of each is #{c.values.join(', ')}"
end
puts "Which animal #{puzzle.solution_predicate}?"
puts "Total possible premises: #{puzzle.premises.length}"
puts "Known facts:"
challenge.clues.each do |c|
  puts "* #{c.to_s.capitalize}"
end

print "Press enter for the solution...."
STDIN.gets

puts puzzle.solution.to_s.capitalize
