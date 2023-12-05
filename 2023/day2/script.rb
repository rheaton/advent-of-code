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
    @red = 0
    @blue = 0
    @green = 0
    parse_rounds
  end

  attr_accessor :id, :red, :green, :blue

  def playable?
    @rounds.all?(&:playable?)
  end

  def power
    red * blue * green
  end

  private

  def parse_rounds
    @rounds = []
    @game_text.split(';').each do |round_text|
      round = Round.new(round_text)
      @rounds << round
      @red = [red, round.red].max
      @blue = [blue, round.blue].max
      @green = [green, round.green].max
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
    game1 = Game.new("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green")
    assert_true(game1.playable?)
    assert_equal([4, 2, 6], [game1.red, game1.green, game1.blue])
    assert_equal(game1.power, 48)

    game2 = Game.new("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue")
    assert_true(game2.playable?)
    assert_equal([1, 3, 4], [game2.red, game2.green, game2.blue])
    assert_equal(game2.power, 12)

    game3 = Game.new("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red")
    assert_false(game3.playable?)
    assert_equal([20, 13, 6], [game3.red, game3.green, game3.blue])
    assert_equal(game3.power, 1560)

    game4 = Game.new("Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red")
    assert_false(game4.playable?)
    assert_equal([14, 3, 15], [game4.red, game4.green, game4.blue])
    assert_equal(game4.power, 630)

    game5 = Game.new("Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green")
    assert_true(game5.playable?)
    assert_equal([6, 3, 2], [game5.red, game5.green, game5.blue])
    assert_equal(game5.power, 36)
  end
end

playable = []
powers = []
File.foreach("#{File.dirname(__FILE__)}/input") do |line|
  g = Game.new(line)
  playable << g.id if g.playable?
  powers << g.power
end
puts "Sum of game ids of playable games: #{playable.sum}"
puts "Sum of powers of all games: #{powers.sum}"


