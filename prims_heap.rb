require 'rubygems'
require 'priority_queue'

# Prim's Minimum Spanning Tree Algorithm - Heap version

def file 
  @file ||= File.readlines("edges.txt")
end

def header 
  @header ||= file.take(1)[0]
end

def number_of_nodes
  @number_of_nodes ||= header.split(" ")[0].to_i
end

def create_adjacency_matrix
  adjacency_matrix = [].tap { |m| number_of_nodes.times { m << Array.new(number_of_nodes) } }
  file.drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }.each do |(node1, node2, weight)|
    adjacency_matrix[node1 - 1][node2 - 1] = weight
    adjacency_matrix[node2 - 1][node1 - 1] = weight
  end
  adjacency_matrix
end

def get_edges(adjacency_matrix, node_index)
  adjacency_matrix[node_index].each_with_index.reject { |edge, index| edge.nil? }
end

def nodes_left_to_cover
  (1..number_of_nodes).to_a - @nodes_spanned_so_far
end

# Prim's algorithm
MAX_VALUE =  (2**(0.size * 8 -2) -1)

adjacency_matrix = create_adjacency_matrix
@nodes_spanned_so_far, spanning_tree_cost = [1], 0

heap = PriorityQueue.new
nodes_left_to_cover.each do |node|
  cheapest_nodes = get_edges(adjacency_matrix, node-1).select { |_, other_node_index| @nodes_spanned_so_far.include?(other_node_index + 1) } || []
  
  cheapest = cheapest_nodes.inject([]) do |all_edges, (weight, index)|
    all_edges << { :start => node, :end => index + 1, :weight => weight }
    all_edges
  end.sort { |x,y| x[:weight] <=> y[:weight] }.first
  
  weight = !cheapest.nil? ? cheapest[:weight]: MAX_VALUE  
  heap[node] = weight
end

while !nodes_left_to_cover.empty?
  cheapest = heap.delete_min
  spanning_tree_cost += cheapest[1]
  @nodes_spanned_so_far << cheapest[0]
  
  edges_with_potential_change = get_edges(adjacency_matrix, cheapest[0]-1).reject { |_, node_index| @nodes_spanned_so_far.include?(node_index + 1) }
  edges_with_potential_change.each do |weight, node_index|
    heap.change_priority(node_index+1, [heap.priority(node_index+1), adjacency_matrix[cheapest[0]-1][node_index]].min)
  end
end

puts "total spanning tree cost #{spanning_tree_cost}"