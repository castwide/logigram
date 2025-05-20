# frozen_string_literal: true

module Logigram
  class Formatter
    CONJUGATIONS = {
      be: ['is', 'are', 'is not', 'are not'],
      belong_to: ['belongs to', 'belong to', 'does not belong to', 'do not belong to'],
      drink: ['drinks', 'drink', 'does not drink', 'do not drink'],
      eat: ['eats', 'eat', 'does not eat', 'do not eat'],
      have: ['has', 'have', 'does not have', 'do not have'],
      like: ['likes', 'like', 'does not like', 'do not like'],
      look: ['looks', 'look', 'does not look', 'do not look'],
      look_like: ['looks like', 'look like', 'does not look like', 'do not look like'],
      live_at: ['lives at', 'live at', 'does not live at', 'do not live at'],
      live_in: ['lives in', 'live in', 'does not live in', 'do not live in'],
      own: ['owns', 'own', 'does not own', 'do not own'],
      play: ['plays', 'play', 'does not play', 'do not play'],
      smell: ['smells', 'smell', 'does not smell', 'do not smell'],
      taste: ['tastes', 'taste', 'does not taste', 'do not taste'],
      work_as: ['works as', 'work as', 'does not work as', 'do not work as'],
      work_for: ['works for', 'work for', 'does not work for', 'do not work for']
    }.freeze
  end
end
