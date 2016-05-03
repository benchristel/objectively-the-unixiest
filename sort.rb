lines = []
while line = gets
  lines << line
end

sorted = lines.sort_by do |line|
  -line.split(' ')[1].to_i
end

sorted.each { |line| puts line }
