SORTING_METHODS = {
  :by_decreasing_order_of_distance => ->(one,two) {
    one_difference = (one[0] - one[1])
    two_difference = (two[0] - two[1])

    if one_difference == two_difference
      two[0] <=> one[0]
    else
      two_difference <=> one_difference
    end  
  },
  
  :by_decreasing_order_of_ratio => ->(one,two) {
    one_ratio = (one[0] / one[1].to_f)
    two_ratio = (two[0] / two[1].to_f)  
    two_ratio <=> one_ratio
  }
}

[:by_decreasing_order_of_distance, :by_decreasing_order_of_ratio].each do |sort_method|
  pairs = File.readlines("jobs.txt").drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }.sort(& SORTING_METHODS[sort_method])

  total = pairs.inject({:total => 0, :time_so_far => 0}) do |acc, value| 
    new_total = acc[:total] + ((acc[:time_so_far] + value[1]) * value[0])
    new_time_so_far = acc[:time_so_far] + value[1]
    {:total => new_total, :time_so_far => new_time_so_far }
  end

  puts "#{sort_method}: #{total[:total]}"
end