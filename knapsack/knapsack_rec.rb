def file 
  @file ||= File.readlines(File.dirname(__FILE__) + "/knapsack2.txt").map { |x| x.gsub(/\n/, "") }
end

header = file.first
@knapsack_size, @number_of_items = header.split(" ")[0..1].map(&:to_i)

# @cache = [].tap { |m| (@number_of_items+1).times { m << Array.new(@knapsack_size+1) } }
# @cache[0].each_with_index { |value, weight| @cache[0][weight] = 0  }

@new_cache = [].tap { |m| (@number_of_items+1).times { m << {} } }

rows = file.drop(1).map { |row| row.split(" ").map(&:to_i)}

# naive
# def knapsack(rows, knapsack_size, index)
#   return 0 if knapsack_size == 0 || index == 0
#   value, weight = rows[index]
#   if weight > knapsack_size 
#     return knapsack(rows, knapsack_size, index-1)
#   else
#     return [knapsack(rows, knapsack_size, index-1), value + knapsack(rows, knapsack_size - weight, index-1)].max
#   end
# end

@output = File.open("/tmp/knappers", "w")

def knapsack_cached(rows, knapsack_size, index)
  return 0 if knapsack_size == 0 || index == 0
  value, weight = rows[index]
  if weight > knapsack_size
    stored_value = @new_cache[index-1][knapsack_size]
            
    return stored_value unless stored_value.nil?  
    return @new_cache[index-1][knapsack_size] = knapsack_cached(rows, knapsack_size, index-1)
  else
    stored_value = @new_cache[index-1][knapsack_size]
    return stored_value unless stored_value.nil?

    option_1  = knapsack_cached(rows, knapsack_size, index-1)
    option_2  = value + knapsack_cached(rows, knapsack_size - weight, index-1)
    return @new_cache[index-1][knapsack_size] = [option_1, option_2].max
  end
end

p knapsack_cached(rows, @knapsack_size, @number_of_items-1)