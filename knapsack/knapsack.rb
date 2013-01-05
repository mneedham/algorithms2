def file 
  @file ||= File.readlines(File.dirname(__FILE__) + "/knapsack1.txt").map { |x| x.gsub(/\n/, "") }
end

header = file.first
knapsack_size, number_of_items = header.split(" ")[0..1].map(&:to_i)

cache = [].tap { |m| (number_of_items+1).times { m << Array.new(knapsack_size+1) } }
cache[0].each_with_index { |value, weight| cache[0][weight] = 0  }

rows = file.drop(1).map { |row| row.split(" ").map(&:to_i)}

(1..number_of_items).each do |i|
  value, weight = rows[i-1]
  (0..knapsack_size).each do |x|
    # puts "weight: #{weight}, x: #{x}, i:#{i}"
    if weight > x
      cache[i][x] = cache[i-1][x] 
    else
      cache[i][x] = [cache[i-1][x], cache[i-1][x-weight] + value].max
    end
  end
end

# cache.each do |row|
#   p row
# end

p cache[number_of_items][knapsack_size]