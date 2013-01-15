import os
from numpy import *
                    
file = open(os.path.dirname(os.path.realpath(__file__)) + "/g_tiny.txt")

vertices, edges = map(lambda x: int(x), file.readline().replace("\n", "").split(" "))

rows = []
adjacency_list = [[] for k in xrange(vertices)]
for line in file.readlines():
    tail, head, weight = line.split(" ")
    adjacency_list[int(head)-1].append({"from" : int(tail), "weight" : int(weight)})

# print(adjacency_list)

n = vertices


def find_min_cost(row):
  row_with_indexes = enumerate(row)
  print(row_with_indexes)
  adjacent_nodes = adjacency_list[v]
  
  least_adjacent_cost = float("inf")
  for node in adjacent_nodes:
    adjacent_cost = row[node["from"]-1] + node["weight"]
    if adjacent_cost < least_adjacent_cost:
      least_adjacent_cost = adjacent_cost  
  # min(previous, least_adjacent_cost)
  return row

shortest_paths = []
for s in range(0, 1):
  # print("processing: " + str(s))
  # cache = [[0 for k in xrange(vertices)] for j in xrange(vertices)]
  cache = zeros((vertices,vertices))
  cache[0][s] = 0
  for v in range(0, vertices):
    if v != s:
      cache[0][v] = float("inf")
  # print(cache)    

  # >>> a[1:,:] = a[0,:] + 3
  # >>> apply_along_axis(fn, 1, a)
  # fn = lambda x : x+2

  for i in range(1, vertices):
    prev_row = cache[i-1]
    print(prev_row)
    apply_along_axis(find_min_cost, 0, prev_row)
    # cache[i] = apply_along_axis(find_min_cost, 0, enumerate(prev_row))
    
    
  #   for v in range(0, vertices):
  #     adjacent_nodes = adjacency_list[v]
  # 
  #     least_adjacent_cost = 1e10  
  #     for node in adjacent_nodes:
  #       adjacent_cost = cache.item((i-1, node["from"]-1)) + node["weight"]
  #       if adjacent_cost < least_adjacent_cost:
  #         least_adjacent_cost = adjacent_cost
  #     cache.itemset((i,v), min(cache.item((i-1,v)), least_adjacent_cost))
  # shortest_paths.append([s, cache[vertices-1]])

print(cache)

for path in shortest_paths:
  print(str(path[1]))

# print(shortest_paths)
# shortest_path = reduce(lambda x, y: x + y, map(lambda x: x[1], shortest_paths)).min()  
# print("Shortest Path: " + str(shortest_path))  
