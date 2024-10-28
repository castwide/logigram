require 'logigram'

class Murder < Logigram::Base
  constrain 'alibi', ['true alibi', 'false alibi', 'no alibi'], reserve: ['false alibi', 'no alibi']
  constrain 'weapon', ['with weapon', 'without weapon'], reserve: ['with weapon']
  constrain 'motive', ['motivated', 'motiveless'], reserve: ['motivated']
  constrain 'proof', ['with proof', 'without proof'], reserve: ['with proof']
  constrain 'knows', ['knows suspect', 'knows address', 'knows motive', 'knows nothing']
end

class Entity
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def to_s
    name
  end
end

characters = [
  Entity.new('Bob'),
  Entity.new('Joe'),
  Entity.new('Tim'),
  Entity.new('Dan'),
  Entity.new('Hal')
]

puzzle = Murder.new(characters, recur: true, terms: %w[alibi weapon])

# challenge = Logigram::Challenge.new(puzzle, difficulty: :easy)
# challenge.clues.each do |clue|
#   puts "#{clue.piece.name}, #{clue.value}"
# end
# puts challenge.puzzle.solution

puzzle.premises.select(&:affirmative?).select(&:specific?).each do |premise|
  puts "#{premise.piece}, #{premise.value}"
end
puts puzzle.solution
