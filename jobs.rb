# Greedy algorithm for minimising the weighted sum of completion times

SORTING_METHODS = {
  :by_decreasing_order_of_distance => ->(one,two) {
    one_difference = (one[:weight] - one[:length])
    two_difference = (two[:weight] - two[:length])

    if one_difference == two_difference
      two[:weight] <=> one[:weight]
    else
      two_difference <=> one_difference
    end  
  },
  
  :by_decreasing_order_of_ratio => ->(one,two) {
    one_ratio = (one[:weight] / one[:length].to_f)
    two_ratio = (two[:weight] / two[:length].to_f)  
    two_ratio <=> one_ratio
  }
}

[:by_decreasing_order_of_distance, :by_decreasing_order_of_ratio].each do |sort_method|
  pairs = File.readlines("small_jobs.txt").drop(1).map do  |x| 
    (weight, length) = x.gsub(/\n/, "").split(" ").map(&:to_i)
    { :weight => weight, :length => length }
  end.sort(& SORTING_METHODS[sort_method])

  total = pairs.inject({:total => 0, :time_so_far => 0}) do |acc, row| 
    weight, length = row[:weight], row[:length]
    new_total = acc[:total] + ((acc[:time_so_far] + length) * weight)
    new_time_so_far = acc[:time_so_far] + length
    {:total => new_total, :time_so_far => new_time_so_far }
  end

  puts "#{sort_method}: #{total[:total]}"
end