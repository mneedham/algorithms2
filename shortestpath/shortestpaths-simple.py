import os
from copy import *

file = open(os.path.dirname(os.path.realpath(__file__)) + "/g_medium.txt")

vertices, edges = map(lambda x: int(x), file.readline().replace("\n", "").split(" "))

rows = []
adjacency_list = [[] for k in xrange(vertices)]
for line in file.readlines():
    tail, head, weight = line.split(" ")
    adjacency_list[int(head)-1].append({"from" : int(tail), "weight" : int(weight)})

n = vertices

shortest_paths = []
s=0

def initialise_cache(vertices, s):
    cache = [0 for k in xrange(vertices)]
    cache[s] = 0

    for v in range(0, vertices):
      if v != s:
        cache[v] = float("inf")
    return cache    

cache = initialise_cache(vertices, s)

for i in range(1, vertices):
    previous_cache = deepcopy(cache)
    cache = initialise_cache(vertices, s)
    for v in range(0, vertices):
        adjacent_nodes = adjacency_list[v]
    
        least_adjacent_cost = float("inf")
        for node in adjacent_nodes:
            adjacent_cost = previous_cache[node["from"]-1] + node["weight"]
            if adjacent_cost < least_adjacent_cost:
                least_adjacent_cost = adjacent_cost
    
        cache[v] = min(previous_cache[v], least_adjacent_cost)

shortest_paths.append([s, cache])

for path in shortest_paths:
  print(str(path[1]))

shortest_path = min(reduce(lambda x, y: x + y, map(lambda x: x[1], shortest_paths)))
print("Shortest Path: " + str(shortest_path))  
