require 'stringio'
require 'test/unit'

class EngineSchematic
  NUMBER = /\d+/
  SPECIAL = /[#\$\*]/

  def initialize(schematic)
    @schematic = schematic
    @part_numbers = []
    @non_parts = []
    collect_parts
  end

  attr_reader :part_numbers, :non_parts

  private

  def collect_parts
    @previous_line = Line.new(nil)
    @current_line = Line.new(@schematic.readline)
    @next_line = Line.new(@schematic.readline)
    collect_parts_from_line

    until @next_line.empty?
      @previous_line = @current_line
      @current_line = @next_line
      @next_line = @schematic.eof ? Line.new(nil) : Line.new(@schematic.readline)
      collect_parts_from_line
    end
  end

  def collect_parts_from_line
    @current_line.scan(/\d+/) do |match|
      next unless match
      match_start = @current_line.last_match.pre_match.length

      search_for_part_indicator(match, match_start)
    end
  end

  def search_for_part_indicator(match, match_start)
    match_end = match_start + match.length
    start_position = match_start - 1
    end_position = match_end + 1
    [@current_line, @previous_line, @next_line].each do |line|
      (start_position..end_position).each do |index|
        next unless line.part_at?(index)

        @part_numbers << match.to_i
        return
      end
    end
  end

  class Line
    def initialize(line_string)
      @line_string = line_string&.strip
      @last_match = nil
    end
    attr_reader :last_match

    def empty?
      @line_string.nil?
    end

    def string
      @line_string
    end

    def part_at?(index)
      return false if empty?
      return false if index.negative? || index >= @line_string.length

      part_indicator = @line_string[index]
      return false if part_indicator.nil?

      part_indicator.match(/\W/) && !part_indicator.match(/\d/) && !part_indicator.match(/\./)
    end

    def scan(*args, &block)
      return if empty?
      @line_string.scan(*args) do |match|
        @last_match = ::Regexp.last_match
        block.call(match)
      end
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
    schematic = EngineSchematic.new(StringIO.new(@schematic))
    assert(schematic.part_numbers.include?(467))
    assert(schematic.part_numbers.include?(35))
    assert(schematic.part_numbers.include?(633))
    assert(schematic.part_numbers.include?(592))
    assert(schematic.part_numbers.include?(755))
    assert(schematic.part_numbers.include?(664))
    assert(schematic.part_numbers.include?(598))

    assert(!schematic.part_numbers.include?(114))
    assert(!schematic.part_numbers.include?(58))

    assert_equal(8, schematic.part_numbers.size)
  end
end

file = File.new("#{File.dirname(__FILE__)}/input.txt")
schematic = EngineSchematic.new(file)
puts "Parts: #{schematic.part_numbers}"
puts "Sum: #{schematic.part_numbers.sum}"
