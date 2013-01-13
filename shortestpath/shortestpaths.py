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
  
# print(cache[0])
print(cache)

for i in range(1, edges):
  for v in range(0, vertices):        
    adjacent_nodes = filter(lambda e: e[1] == v+1, rows)
    
    lookup_costs = []
    for node in adjacent_nodes:
      lookup_costs.append([cache[i-1][node[0]-1], node[2]])
    
    adjacent_costs = map(lambda x: x[0] + x[1], lookup_costs)
    print("i:" + str(i) + " node" + str(v) + " " + str(adjacent_costs))
    
    if adjacent_costs:
      least_adjacent_cost = min(adjacent_costs)
    else:
      least_adjacent_cost = float("inf")
    
    cache[i][v] = min(cache[i-1][v], least_adjacent_cost)
    
    # print("for vertex: " + str(v))
    # print(adjacent_nodes)
    # min_lookup_cost = cache[i-1][edge[0]-1] + edge[2]
    # cache[i][v] = min(cache[i-1][v], min_lookup_cost)
    
    # lookup_costs = []
    # for edge in filter(lambda e: e[1] == v, rows):      
    #   lookup_costs.append([cache[i-1][edge[0]-1], edge[2]])
    # 
    # lookup_costs = map(lambda x: x[0] + x[1], lookup_costs)
    # 
    # if not lookup_costs:
    #   min_lookup_cost = float("inf")
    # else:
    #   min_lookup_cost = min(lookup_costs)
    #         
    # cache[i][v] = min(cache[i-1][v], min_lookup_cost)

# for v in range(0, vertices):
#   for e in range(1, edges):
#     key = rows[e][0]-1
# 
#     if cache[v] > cache[key] + rows[e][2]:
#       cache[v] = cache[key] + rows[e][2]
  # lookup_costs = []
  # # print(cache)
  # for edge in filter(lambda e: e[1] == v, rows):
  #   u = edge[0]
  #   v = edge[1]
  #   lookup_costs.append([cache[u-1], edge[2]])
  # print(lookup_costs)
  # if lookup_costs:
  #   minimum_uv = min(map(lambda x: x[0] + x[1], lookup_costs))
  #   print(minimum_uv)
  # else:
  #   minimum_uv = float("inf")
  # cache[i] = min(cache[i-1], minimum_uv)  
    

print(cache)
# print(cache[edges-1][s])

# for blah in range(0,10):
#   print(blah)

# cache = []
# for i in range(0, number_of_items):
#     cache.append({})
#     
# result = knapsack_cached(rows, knapsack_size, number_of_items-1, cache)    
# print(result)