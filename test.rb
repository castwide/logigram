require 'bundler/setup'
require 'logigram'

class Mystery < Logigram::Base
  constrain 'alibi', ['telling the truth', 'lying', 'without an alibi'], reserve: ['lying', 'without an alibi']
  constrain 'hair', ['red', 'blond', 'black', 'brown', 'gray']
  constrain 'height', ['5 feet', '6 feet']
end

puzzle = Mystery.new(['Bob', 'Dave', 'George'], terms: 'hair')
challenge = Logigram::Challenge.new(puzzle, difficulty: :hard)

statistics = Logigram::Statistics.new(puzzle)
puts statistics.to_s

puts "Known facts:"
challenge.clues.each do |c|
  puts "* #{c.to_s.capitalize}"
end

print "Press enter for the solution...."
STDIN.gets

puts puzzle.solution.to_s.capitalize
