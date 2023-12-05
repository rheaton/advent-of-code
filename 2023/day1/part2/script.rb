DIGITS = %w(zero one two three four five six seven eight nine)

class NumberGrabber
  def initialize(text, log = false)
    @text = text.strip
    @digits = []
    @log = log
  end

  def get_digits
    calculate_numbers_and_positions
    @digits.compact!
    d1 = @digits[0]
    d2 = @digits[-1]
    num = get_digit(d1) * 10 + get_digit(d2)
    puts "  #{@text} #{num}" if @log
    return num
  end

  private

  # https://ruby-doc.org/stdlib-2.0.0/libdoc/English/rdoc/English.html
  # $` (prematch) The string to the left of the last successful match.
  def calculate_numbers_and_positions
    DIGITS.each do |number_as_text|
      add_positions(/#{number_as_text}/)
    end
    add_positions(/\d/)
  end

  def add_positions(regex)
    @text.scan(regex) do |match|
      position = $`.length
      next unless match

      @digits[position] = match
    end
  end

  def get_digit(digit)
    if digit.match(/\d/)
      return digit.to_i
    else
      return DIGITS.index(digit)
    end
  end
end

def get_digits(text, log = false)
  ng = NumberGrabber.new(text, log)
  ng.get_digits
end

require 'test/unit'

class DigitTest < Test::Unit::TestCase
  def log
    true
  end

  def test_get_digit
    assert_equal(42, get_digits("4nineeightseven2\n", log))
    assert_equal(29, get_digits("two1nine\n", log))
    assert_equal(83, get_digits("eightwothree", log))
    assert_equal(13, get_digits("abcone2threexyz\n", log))
    assert_equal(24, get_digits("xtwone3four", log))
    assert_equal(14, get_digits("zoneight234", log))
    assert_equal(76, get_digits("7pqrstsixteen", log))
    assert_equal(31, get_digits("3xtwone", log))
    assert_equal(95, get_digits("9five4plblgvnfcfoursixmsgfive", log))
    assert_equal(51, get_digits("5csrtvjmjzs391sixtwonef", log))
  end
end

coordinates = []
File.foreach("#{File.dirname(__FILE__)}/input") do |line|
  coordinates << get_digits(line)
end
puts "Sum: #{coordinates.sum}"
puts "Length: #{coordinates.length}"
# Sum: 56017
# Length: 1000

