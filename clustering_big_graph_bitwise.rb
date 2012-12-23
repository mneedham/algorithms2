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
    return if id1 == id2
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
  @file ||= File.readlines("clustering2.txt")
end

def number_of_nodes
  @number_of_nodes ||= header.split(" ")[0].to_i
end

def header 
  @header ||= file.take(1)[0]
end

def bits 
  @bits ||= header.split(" ")[1].to_i
end

def close_friends(me, offsets)  
  friends_differing_by_one = offsets.map { |off| me ^ off }
  friends_differing_by_two = offsets.combination(2).to_a.map { |a,b| me ^ (a|b) }
  friends_differing_by_one + friends_differing_by_two + [me]
end

set = UnionFind.new number_of_nodes

nodes = file.drop(1).map { |x| x.gsub(/\n/, "").gsub(/ /, "").to_i(2)}

@magical_hash = {}
nodes.each_with_index do |node, index|
  @magical_hash[node] ||= []
  @magical_hash[node] << index
end

offsets = (0..(bits - 1)).map { |x| 2 ** x }
nodes.each_with_index do |node, index|  
  close_friends(node, offsets).each do |friend|
    (@magical_hash[friend] || []).each { |friend_index| set.union(index, friend_index) }
  end
end

puts "size: #{set.number_of_clusters}"