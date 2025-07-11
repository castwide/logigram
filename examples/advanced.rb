# An advanced example of a Logigram puzzle

require 'bundler/setup'
require 'logigram'

constraints = [
  Logigram::Constraint.new(
    'hair',
    %w[brown black red blond gray],
    unique: false, # Multiple suspects can have the same hair color
    formatter: Logigram::Formatter.new(subject: 'the %<value>s-haired suspect', verb: :have,
                                       descriptor: '%<value>s hair')
  ),
  Logigram::Constraint.new(
    'job',
    ['a lawyer', 'a teacher', 'an accountant', 'a salesperson', 'an executive'],
    formatter: Logigram::Formatter.new(subject: 'the suspect who works as %<value>s')
  ),
  Logigram::Constraint.new(
    'address',
    ['Cleveland', 'Boston', 'Denver', 'San Diego', 'Atlanta'],
    unique: false,
    formatter: Logigram::Formatter.new(subject: 'the suspect from %<value>s', verb: :live_in, descriptor: '%<value>s')
  )
]

puzzle = Logigram::Puzzle.new(constraints: constraints, objects: %w[Bob Sam Jan])
challenge = Logigram::Challenge.new(puzzle, difficulty: :medium)

puts "The suspects are #{puzzle.pieces.map(&:name).sort.join(', ')}"

tables = Logigram::Statistics.constraint_tables(puzzle)
tables.each do |constraint, data|
  if data.values.all? { |cnt| cnt == 1 }
    puts "1 of each #{constraint.verb} #{data.keys.map { |val| constraint.descriptor(val) }.sort.join(', ')}"
  else
    out = data.map { |value, count| "#{count} #{constraint.predicate(value, count)}" }
              .shuffle
              .sort_by { |str| [str[0, str.index(' ')].to_i * -1, str[str.index(' ')..]] }
    puts out
  end
end

puts "Which suspect #{puzzle.solution.property(puzzle.determinants.first).predicate}?"

puts 'Known facts:'
challenge.premises.each do |premise|
  puts "* #{premise}"
end

print 'Press enter for the solution....'
$stdin.gets

puts "#{puzzle.solution.to_s.capitalize} #{puzzle.solution.property(puzzle.determinants.first).predicate}."
