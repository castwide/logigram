# Logigram

A library for generating [logic puzzles](https://en.wikipedia.org/wiki/Logic_puzzle).

A Logigram puzzle is a form of *syllogism*. The puzzle provides a collection of facts (or *premises*) and asks a question. The answer can be construed from the facts through deductive reasoning.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logigram'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logigram

## Usage

See [example.rb](example.rb) for a simple demonstration.

## TODO:

- Support pieces with duplicate term values.
    - Example: If a term is hair color, more than one piece can have brown hair.
- Allow for multiple terms to determine the solution.
    - Example: The solution has brown hair and blue eyes. Other pieces can have either brown hair or blue eyes, but not both.
    - In this case, there might not need to be a solution term; the solution's combined terms just need to be unique.
- Star Trek feature: Dynamically generate constraints and pieces from objects with existing properties.
    - Example: Three objects have existing properties `:hair_color` and `:eye_color`. The logigram uses the existing constraints
      and values.
    - The logigram will need to verify that the resulting challenge has exactly one discoverable solution.
    - The process for generating the logigram will need a mechanism to accept constraint properties (e.g., `predicate`)
