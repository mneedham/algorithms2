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
    leader_1, leader_2 = find_parent(id1), find_parent(id2)
    @leaders[leader_1]= leader_2
  end
  
  def find_parent(index)
    parent = @leaders[index]
    return index  if parent == index
    find_parent(parent)
  end
  
  def number_of_clusters
    @leaders.each_with_index.select { |value, index| index == value }.size
    # Set.new(@leaders).size
  end
  
  def cluster_leaders
    @leaders.each_with_index.select { |value, index| index == value }
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
  friends_differing_by_one + friends_differing_by_two
end

nodes = file.drop(1).map { |x| x.gsub(/\n/, "").gsub(/ /, "").to_i(2) }.sort.uniq

@magical_hash = {}
nodes.each_with_index do |node, index|
    @magical_hash[node] = index
end

set = UnionFind.new (@magical_hash.size)

combinations = []

offsets = (0..(bits - 1)).map { |x| 2 ** x }
nodes.each_with_index do |node, index|  
  close_friends(node, offsets).each do |friend|
    friend_index = @magical_hash[friend]
    combinations << [index, friend_index] if friend_index   
  end
end

combinations = combinations.map { |x, y| x > y ? [y, x] : [x,y]  }.sort.uniq

combinations.each do |index, friend_index|
  set.union(index, friend_index)
end

# p combinations
# puts "size #{combinations.size}"
puts "size: #{set.number_of_clusters}"
# p set.cluster_leaders
