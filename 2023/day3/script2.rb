require 'stringio'
require 'test/unit'

class EngineSchematic
  NUMBER = /\d+/
  SPECIAL = /[#\$\*]/

  def initialize(schematic, log: false)
    @schematic = schematic
    @gears = GearCollection.new
    @log = log
    find_gears
  end

  def gears
    @gears.valid_gears
  end

  private

  def find_gears
    line_number = 0
    @previous_line = Line.new(nil, line_number)
    @current_line = Line.new(@schematic.readline, line_number += 1)
    @next_line = Line.new(@schematic.readline, line_number += 1)
    collect_gear_from_line

    until @next_line.empty?
      @previous_line = @current_line
      @current_line = @next_line
      @next_line = Line.new(@schematic.eof ? nil : @schematic.readline, line_number += 1)
      collect_gear_from_line
    end
  end

  def collect_gear_from_line
    @current_line.scan(/\d+/) do |match|
      next unless match

      match_start = @current_line.last_match.pre_match.length

      search_for_gear_indicator(match, match_start)
    end
  end

  def search_for_gear_indicator(match, match_start)
    match_end = match_start + match.length
    start_position = match_start - 1
    end_position = match_end

    [@current_line, @previous_line, @next_line].each do |line|
      (start_position..end_position).each do |index|
        next if (gear_location = line.gear_location(index)).nil?

        gear = @gears.add_part_number(gear_location, match.to_i)
        puts "Match: #{match} at #{gear_location} (#{gear})" if @log
        puts @current_line if @log
        puts @previous_line if @log
        puts @next_line_line if @log
      end
    end
  end

  class GearCollection
    def initialize
      @gears = {}
    end

    def add_part_number(location, part_number)
      gear = @gears[location] ||= Gear.new(*location)
      gear.add_part_number(part_number)
      gear
    end

    def valid_gears
      @gears.values.select(&:valid?)
    end
  end

  class Gear
    def initialize(x, y)
      @x = x
      @y = y
      @part_numbers = []
    end
    attr_reader :part_numbers

    def add_part_number(part_number)
      @part_numbers << part_number
    end

    def valid?
      @part_numbers.length == 2
    end

    def ratio
      @part_numbers.inject(:*)
    end

    def to_s
      "Gear at #{@x}, #{@y} with part numbers #{@part_numbers}"
    end
  end

  class Line
    def initialize(line_string, number)
      @line_string = line_string&.strip
      @number = number
      @last_match = nil
    end

    attr_reader :last_match, :number

    def empty?
      @line_string.nil?
    end

    def string
      @line_string
    end

    def at(index)
      return nil if empty?
      return nil if index.negative? || index >= @line_string.length

      @line_string[index]
    end

    def gear_location(index)
      return if at(index).nil?

      return unless at(index).match(/\*/)

      [number, index]
    end

    def scan(*args, &block)
      return if empty?

      @line_string.scan(*args) do |match|
        @last_match = ::Regexp.last_match
        block.call(match)
      end
    end

    def to_s
      nil if @line_string.nil?
      "\t#{@line_string} \t#{@number}"
    end
  end
end

class Day3Test < Test::Unit::TestCase
  def setup
    @schematic = <<~TEXT
      467..114..
      ...*......
      ..35..633.
      ......#...
      617*......
      .....+.58.
      ..592.....
      ......755.
      ...$.*....
      .664.598..
    TEXT
  end

  def test_schematic
    schematic = EngineSchematic.new(StringIO.new(@schematic), log: false)
    assert_equal(schematic.gears.length, 2)

    gear1 = schematic.gears.first
    assert_equal([467, 35], gear1.part_numbers)
    assert_equal(16_345, gear1.ratio)
    gear2 = schematic.gears.last
    assert_equal([755, 598], gear2.part_numbers)
    assert_equal(451_490, gear2.ratio)
  end

end

file = File.new("#{File.dirname(__FILE__)}/input.txt")
schematic = EngineSchematic.new(file)
sum = (schematic.gears.collect &:ratio).sum
pp schematic.gears
puts "Sum: #{sum}"

# Sum: 81721933
