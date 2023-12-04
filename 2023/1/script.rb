
require 'pry'
coordinates = []
regex = /\D*(\d)/

File.foreach("input") do |line|
  m1 = line.match(regex)
  d1 = m1[1]
  m2 = line.reverse.strip.match(regex)
  d2 = m2[1]
  
  coordinates << (d1.to_s + d2.to_s).to_i
end

puts "Sum: #{coordinates.sum}"
