import os
                    
file = open(os.path.dirname(os.path.realpath(__file__)) + "/g1.txt")

vertices, edges = map(lambda x: int(x), file.readline().replace("\n", "").split(" "))

rows = []
adjacency_list = [[] for k in xrange(vertices)]
for line in file.readlines():
    tail, head, weight = line.split(" ")
    adjacency_list[int(head)-1].append({"from" : int(tail), "weight" : int(weight)})

# print(adjacency_list)

n = vertices

shortest_paths = []
for s in range(0, 1):
  # print("processing: " + str(s))
  cache = [[0 for k in xrange(vertices)] for j in xrange(vertices)]
  cache[0][s] = 0
  for v in range(0, vertices):
    if v != s:
      cache[0][v] = float("inf")

  for i in range(1, vertices):
    for v in range(0, vertices):
      # print("i: " + str(i) + ", v: " + str(v))
      adjacent_nodes = adjacency_list[v]

      # adjacent_costs = []
      least_adjacent_cost = float("inf")
      for node in adjacent_nodes:
        adjacent_value = cache[i-1][node["from"]-1] + node["weight"]
        if adjacent_value < least_adjacent_cost:
          least_adjacent_cost = adjacent_value
        # adjacent_costs.append(cache[i-1][node["from"]-1] + node["weight"])

      # if adjacent_costs:
      #   least_adjacent_cost = min(adjacent_costs)
      # else:
      #   least_adjacent_cost = float("inf")
      #     
      # print("updating cache..." + str(v))
      cache[i][v] = min(cache[i-1][v], least_adjacent_cost)
      if cache[i] == cache[i-1]:
        break;
  shortest_paths.append([s, cache[vertices-1]])

for path in shortest_paths:
  print(str(path[1]))

# print(shortest_paths)
shortest_path = min(reduce(lambda x, y: x + y, map(lambda x: x[1], shortest_paths)))  
print("Shortest Path: " + str(shortest_path))  
