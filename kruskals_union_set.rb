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

# Some renaming of variables of Michael Luckender's class -> https://github.com/mluckeneder/Union-Find-Ruby/blob/master/quick-union.rb
class UnionFind
  def initialize(n)
    @subsets = Hash.new{|subsets, element| subsets[element] = [element]}
  end

  def connected?(id1,id2)
    @subsets[id1] == @subsets[id2]
  end

  def union(id1,id2)
    subset_1, subset_2 = @subsets[id1], @subsets[id2]
    subset_1.each do |element, _|
      @subsets[element] = subset_2 << element
    end unless subset_1 == subset_2
  end
end

set = UnionFind.new number_of_nodes

@minimum_spanning_tree = []

edges = file.drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }.
                     map { |one, two, weight| { :from => one, :to => two, :weight => weight}}.
                     sort_by { |x| x[:weight]}

edges.each do |edge|
  if !set.connected?(edge[:from], edge[:to])
    @minimum_spanning_tree << edge
    set.union(edge[:from], edge[:to])
  end
end

puts "MST: #{@minimum_spanning_tree}"
puts "Cost: #{@minimum_spanning_tree.inject(0) { |acc, x| acc + x[:weight]}}"
