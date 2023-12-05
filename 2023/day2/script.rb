# Which games are possible with the given cubes?
# 12 red cubes, 13 green cubes, and 14 blue cubes

class Round
  def initialize(round_text)
    @round_text = round_text
    @red = 0
    @blue = 0
    @green = 0
    parse_round_text
  end
  attr_accessor :red, :green, :blue

  def playable?
    @red <= 12 && @green <= 13 && @blue <= 14
  end

  private

  def parse_round_text
    @round_text.split(',').each do |cube_text|
      cube_text.strip!
      case cube_text
      when /(\d+) red/
        @red = ::Regexp.last_match(1).to_i
      when /(\d+) green/
        @green = ::Regexp.last_match(1).to_i
      when /(\d+) blue/
        @blue = ::Regexp.last_match(1).to_i
      end
    end
  end
end

class Game
  def initialize(game_text)
    @game_text = game_text
    @id = game_text.match(/Game (\d+):/)[1].to_i
    parse_rounds
  end
  attr_accessor :id

  def playable?
    @rounds.all?(&:playable?)
  end

  private

  def parse_rounds
    @rounds = []
    @game_text.split(';').each do |round_text|
      @rounds << Round.new(round_text)
    end
  end
end

def playable?(game_text)
  Game.new(game_text).playable?
end

require 'test/unit'

class ColourGameTest < Test::Unit::TestCase
  def log
    true
  end

  def test_playable
    assert_true(playable?("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"))
    assert_true(playable?("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue"))
    assert_false(playable?("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red"))
    assert_false(playable?("Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red"))
    assert_true(playable?("Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"))
  end
end

playable = []
File.foreach("#{File.dirname(__FILE__)}/input") do |line|
  g = Game.new(line)
  playable << g.id if g.playable?
end
puts "Sum: #{playable.sum}"


