import os
from numpy import *

file = open(os.path.dirname(os.path.realpath(__file__)) + "/g3.txt")
vertices, edges = map(lambda x: int(x), file.readline().replace("\n", "").split(" "))
rows = []

def initialise_cache(vertices, s):
    cache = empty(vertices)
    cache[:] = float("inf")
    cache[s] = 0
    return cache    

adjacency_matrix = zeros((vertices, vertices))
adjacency_matrix[:] = float("inf")
for line in file.readlines():
    tail, head, weight = line.split(" ")
    adjacency_matrix[int(head)-1][int(tail)-1] = int(weight)    

shortest_paths = []

for s in range(0, 1):
    cache = initialise_cache(vertices, s)
    for i in range(1, vertices):
        previous_cache = cache
        combined = (previous_cache.T + adjacency_matrix).min(axis=1)
        cache = minimum(previous_cache, combined)

    shortest_paths.append([s, cache])

# for path in shortest_paths:
#     print(str(path[1]))

shortest_path = min(reduce(lambda x, y: x + y, map(lambda x: x[1], shortest_paths)))
print("Shortest Path: " + str(shortest_path))  