# Prim's Minimum Spanning Tree Algorithm - Naive version

def create_adjacency_matrix(size)
  [].tap do |m|
    size.times { m << Array.new(size) }
  end
end

def find_cheapest_edge(adjacency_matrix, vertices_spanned_so_far, number_of_nodes)
  available_vertices = (0..number_of_nodes-1).to_a.reject { |x| vertices_spanned_so_far.include?(x + 1) }  
  
  cheapest_edges = available_vertices.inject([]) do |acc, vertice|
    adjacency_matrix[vertice].each_with_index.reject { |edge, index| edge.nil? }.select { |edge, index| vertices_spanned_so_far.include?(index + 1) }.each do |edge, index|
      acc << { :start => vertice + 1, :end => index + 1, :weight => edge }
    end
    acc
  end
    
  cheapest_edges.sort { |x,y| x[:weight] <=> y[:weight] }.first
end

def select_first_edge(adjacency_matrix)
  cheapest_edges = adjacency_matrix[0].each_with_index.reject { |edge, index| edge.nil? }.inject([]) do |acc, (edge, index)|
    acc << { :start => 1, :end => index + 1, :weight => edge }
    acc
  end
  cheapest_edge = cheapest_edges.sort { |x,y| x[:weight] <=> y[:weight] }.first
  [[1, cheapest_edge[:end]], [cheapest_edge]]
end

file = File.readlines("edges.txt")

header = file.take(1)
number_of_nodes = header[0].split(" ")[0].to_i
m = create_adjacency_matrix(number_of_nodes)

file.drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }.each do |(node1, node2, weight)|
  m[node1 - 1][node2 - 1] = weight
  m[node2 - 1][node1 - 1] = weight
end

vertices_spanned_so_far, edges = select_first_edge(m)

while !((1..number_of_nodes).to_a - vertices_spanned_so_far).empty?
  cheapest_edge = find_cheapest_edge(m, vertices_spanned_so_far, number_of_nodes)
  edges << cheapest_edge
  vertices_spanned_so_far << cheapest_edge[:start]  
end

puts "edges: #{edges}, total spanning tree cost #{edges.inject(0) {|acc, edge| acc + edge[:weight]}}"