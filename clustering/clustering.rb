require 'set'

# Some renaming of variables of Michael Luckender's class -> https://github.com/mluckeneder/Union-Find-Ruby/blob/master/quick-union.rb
class UnionFind
  def initialize(n)
    @leaders = 0.upto(n-1).inject([]) { |leaders, i| leaders[i] = i; leaders }
  end
  
  def connected?(id1,id2)
    @leaders[id1] == @leaders[id2]
  end
  
  def union(id1,id2)
    leader_1, leader_2 = @leaders[id1], @leaders[id2]
    @leaders.map! {|i| (i == leader_1) ? leader_2 : i }
  end
  
  def number_of_clusters
    Set.new(@leaders).size
  end
  
  def cluster_leaders
    Set.new(@leaders)
  end
end

def file 
  @file ||= File.readlines("clustering_medium.txt")
end

def number_of_nodes
  @number_of_nodes ||= header.split(" ")[0].to_i
end

def header 
  @header ||= file.take(1)[0]
end

set = UnionFind.new number_of_nodes

edges = file.drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }.
                     map { |one, two, weight| { :from => one, :to => two, :weight => weight}}.
                     sort_by { |x| x[:weight]}
           
spacing = nil                     
edges.each do |edge|
  if set.number_of_clusters > 4
    set.union(edge[:from]-1, edge[:to]-1)
  else
    (spacing = edge[:weight]) && break unless set.connected?(edge[:from]-1, edge[:to]-1)
  end
end

puts "spacing: #{spacing}"