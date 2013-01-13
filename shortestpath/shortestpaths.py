import os
                    
file = open(os.path.dirname(os.path.realpath(__file__)) + "/g_from_video.txt")

vertices, edges = map(lambda x: int(x), file.readline().replace("\n", "").split(" "))

rows = []
for line in file.readlines():
    tail, head, weight = line.split(" ")
    rows.append([int(tail), int(head), int(weight)])

n = vertices
cache = [[0 for k in xrange(vertices)] for j in xrange(edges)]
# cache = [0 for k in xrange(vertices)]

s=0
cache[0][s] = 0
# cache[s] = 0
for v in range(0, vertices):
  # cache[v] = float("inf")  
  if v != s:
    cache[0][v] = float("inf")

for i in range(1, edges):
  for v in range(0, vertices):        
    adjacent_nodes = filter(lambda e: e[1] == v+1, rows)
    
    lookup_costs = []
    for node in adjacent_nodes:
      lookup_costs.append([cache[i-1][node[0]-1], node[2]])
    
    adjacent_costs = map(lambda x: x[0] + x[1], lookup_costs)
    # print("i:" + str(i) + " node" + str(v) + " " + str(adjacent_costs))
    
    if adjacent_costs:
      least_adjacent_cost = min(adjacent_costs)
    else:
      least_adjacent_cost = float("inf")
    
    cache[i][v] = min(cache[i-1][v], least_adjacent_cost)

print(cache)
# print(cache[edges-1][s])
