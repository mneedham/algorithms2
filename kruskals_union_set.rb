#Kruskal's algorithm
def header 
  @header ||= file.take(1)[0]
end

def number_of_nodes
  @number_of_nodes ||= header.split(" ")[0].to_i
end

def file 
  @file ||= File.readlines("edges.txt")
end

class QuickFind
  def initialize(n)
    @ids = []
    0.upto(n-1) {|i| @ids[i] = i}
  end
  
  def connected?(id1,id2)
    @ids[id1] == @ids[id2]
  end
  
  def union(id1,id2)
    id_1, id_2 = @ids[id1], @ids[id2]
    @ids.map! {|i| (i == id_1) ? id_2 : i }
  end
end

qf = QuickFind.new number_of_nodes

@minimum_spanning_tree = []

edges = file.drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }.
                     map { |one, two, weight| { :from => one, :to => two, :weight => weight}}.
                     sort_by { |x| x[:weight]}
                     
edges.each do |edge|
  p qf
  if !qf.connected?(edge[:from] -1, edge[:to] -1)
    @minimum_spanning_tree << edge 
    qf.union(edge[:from]-1, edge[:to] -1)
  end  
end

puts "MST: #{@minimum_spanning_tree}"
puts "Cost: #{@minimum_spanning_tree.inject(0) { |acc, x| acc + x[:weight]}}"

p qf