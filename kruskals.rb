#Kruskal's algorithm

def file 
  @file ||= File.readlines("edges.txt")
end

def has_cycles(edge)
  node_one, node_two = edge[:from], edge[:to]  
  @minimum_spanning_tree.each { |x| x[:explored] = false }
  cycle_between(node_one, node_two, @minimum_spanning_tree.dup)
end

def cycle_between(one, two, edges)
  adjacent_edges = find_adjacent_edges(one, edges)
  return false if adjacent_edges.size == 0
  adjacent_edges.each do |edge|
    if !edge[:explored]
      edge[:explored] = true
      other_node = (edge[:from] == one) ? edge[:to] : edge[:from]
      return true if other_node == two
      found_cycle = cycle_between(other_node, two, edges)
      return true if found_cycle
    end
  end
  false
end

def find_adjacent_edges(one, edges)
  edges.select { |edge| edge[:to] == one || edge[:from] == one}  
end

@minimum_spanning_tree = []

edges = file.drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }.
                     map { |one, two, weight| { :from => one, :to => two, :weight => weight}}.
                     sort_by { |x| x[:weight]}
                     
edges.each do |edge|
  @minimum_spanning_tree << edge unless has_cycles edge
end

puts "MST: #{@minimum_spanning_tree}"
puts "Cost: #{@minimum_spanning_tree.inject(0) { |acc, x| acc + x[:weight]}}"