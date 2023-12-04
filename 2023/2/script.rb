DIGITS = %w(zero one two three four five six seven eight nine)
REGEX = /\d|#{DIGITS.join("|")}/

def get_digits(line, log=false)
  numbers = line.scan(REGEX)
  puts "matches: #{numbers.join(", ")}" if log
  d1 = numbers[0]
  d2 = numbers[-1]

  puts "#{d1} #{d2}" if log

  num = get_digit(d1) * 10 + get_digit(d2)
  puts "num: #{num}" if log
  return num
end

def get_digit(digit)
  if digit.match(/\d/)
    return digit.to_i
  else
    return DIGITS.index(digit)
  end
end


require 'test/unit'

class DigitTest < Test::Unit::TestCase
  def log
    true
  end

  def test_get_digit
    assert_equal(29, get_digits("two1nine\n", log))
    assert_equal(83, get_digits("eightwothree", log))
    assert_equal(13, get_digits("abcone2threexyz", log))
    assert_equal(24, get_digits("xtwone3four", log))
    assert_equal(42, get_digits("4nineeightseven2", log))
    assert_equal(14, get_digits("zoneight234", log))
    assert_equal(76, get_digits("7pqrstsixteen", log))
  end
end


coordinates = []
File.foreach("input") do |line|
  coordinates << get_digits(line)
end
puts "Sum: #{coordinates.sum}"
puts "Length: #{coordinates.length}"

