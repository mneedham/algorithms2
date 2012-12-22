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
  @file ||= File.readlines("clustering2.txt")
end

def number_of_nodes
  @number_of_nodes ||= header.split(" ")[0].to_i
end

def header 
  @header ||= file.take(1)[0]
end

def close_friends(me)
  friends = Set.new

  change_by_one_bit(me).each do |friend|
    friends.add friend
  end
    
  me.each_with_index do |x, index|
    new_me = me.dup
    new_me[index] = x == 0 ? 1 : 0
    change_by_one_bit(new_me).each do |friend|
      friends.add(friend)
    end
  end
  friends
end

def change_by_one_bit(me)
  differ_by_one = []
  me.each_with_index do |x, index|
    new_me = me.dup
    new_me[index] = x == 0 ? 1 : 0
    differ_by_one << new_me
  end
  differ_by_one
end

def hamming_distance(a, b)
  a.zip(b).select { |x, y| x != y }.size
end

set = UnionFind.new number_of_nodes

nodes = file.drop(1).map { |x| x.gsub(/\n/, "").split(" ").map(&:to_i) }

magical_hash = {}

nodes.each_with_index do |node, index|
  magical_hash[node] ||= []
  magical_hash[node] << index
end

nodes.each_with_index do |node, index|
  friends = close_friends(node).inject([]) do |node_indexes, friend|
    (magical_hash[friend] || []).each { |friend_index| node_indexes << friend_index }
    node_indexes
  end
    
  friends.each { |friend_index| set.union(index, friend_index)  }
end

puts "size: #{set.number_of_clusters}"