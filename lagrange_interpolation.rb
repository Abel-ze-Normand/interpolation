require 'tty'
require 'pry'

def sin x
  Math.sin x
end

def fact x
  (1..x).reduce(:*)
end

def rn x, pairs
  #in my example given only sin x, so it's max |fx| will be 1 on the given range
  fact = (1..11).reduce(1, :*)
  p = pairs.inject(1) {|pp, item| pp*(x-item[0])}
  return p.to_f/fact(pairs.count+1)
end

def l x, pairs
  pairs.count.times.map do |i|
    pairs.reduce(1.0) do |res, x_j|
      pairs[i][0] == x_j[0] ? res : res * (x - x_j[0])/(pairs[i][0] - x_j[0])
    end * pairs[i][1]
  end.reduce(:+)
end

#generate points#

pairs = []

a, b = 2.0, 4.0
n = 2

puts "a = #{a} b = #{b}, #{n} steps"
x = a
h = (b-a)/n
puts "h = #{h}"
loop do
  pairs << [x, sin(x)]
  x += h.round(8)
  break if x > b 
end

fields = []

pairs.each do |subarr|
  fields << [subarr[0].round(4), subarr[1].round(4)]
end

#puts "y(1.4) = #{sin 1.4}"

#puts "L(1.4) = #{l 1.4, pairs}"

table = TTY::Table.new ['x', 'sin x'], fields
puts table.render (:ascii)
puts


#generate polynomial in lagrange form#

fields = []
h = h/2
x = a

loop do
  value = 0
  pairs.each_with_index do |pair, index|
    pol = 1
    pairs.each_with_index do |jpair, jndex|
      next if index == jndex
      pol *= (x - jpair[0])/(pair[0] - jpair[0])
    end
    value += pol*pair[1]
  end
  #calculate Rn x#
  #Rn x = max[a,b] |sin^(11)|/(n+1)! * MULT[i in 0..n](x-xi) => max[1, 5] |sin x| / 11! * MULT[i in 0..n](x-xi)#
  
  fields << [x.round(8), sin(x).round(8), value.round(8), (value - sin(x)).abs.round(8), rn(x, pairs)]
  x+=h
  break if x>b
end
table = TTY::Table.new ['x-wave', 'sin(x-wave)', 'L(x)', 'err', 'Rn(x)'], fields
puts table.render(:ascii)

#generate polynomial in newton form

nn = n - 1
fields = []
fin_diff = []

subarr = []
y = (0..nn).map.with_index {|i| pairs[i][1]}
x = (0..nn).map.with_index {|i| pairs[i][0]}
p x.inspect
p y.inspect
k = Array.new(n)
k[0] = y[0]
for j in (1..n)
  for i in (0..(nn-j)) do
    y[i]=(y[i+1]-y[i])/(x[i+j]-x[i]);
    k[j]=y[0];
  end
end
p "Finite derivatives table:"
p k
xx = a

loop do
  s = k[0]
  p = 1
  diffs = []
  for i in 1..nn do
    p *= (xx - x[i-1])
    s += k[i]*p
  end
  fields << [xx.round(8), sin(xx).round(8), s.round(8), (sin(xx) - s).abs.round(8), rn(xx, pairs)]
  break if xx > b
  xx += h
end


table = TTY::Table.new ['x-wave', 'sin(x-wave)', 'P(x)', 'err', 'Rn(x)'], fields
puts table.render(:ascii)

