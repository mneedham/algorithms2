import os
from numpy import *
from time import time
import sys

start_time = time()

file = open(os.path.dirname(os.path.realpath(__file__)) + "/" + sys.argv[1:][0])
vertices, edges = map(lambda x: int(x), file.readline().replace("\n", "").split(" "))
rows = []

adjacency_matrix = zeros((vertices, vertices))
adjacency_matrix[:] = float("inf")
for line in file.readlines():
    tail, head, weight = line.split(" ")
    adjacency_matrix[int(head)-1][int(tail)-1] = int(weight)

print("processed file: " + str(time() - start_time))

def initialise_cache(vertices, s):
    cache = empty(vertices)
    cache[:] = float("inf")
    cache[s] = 0
    return cache    

shortest_paths = []

for s in range(0, vertices):
    cache = initialise_cache(vertices, s)
    for i in range(1, vertices):
        previous_cache = cache[:]
                
        combined = (previous_cache.T + adjacency_matrix).min(axis=1)
        cache = minimum(previous_cache, combined)
        
        if(alltrue(cache == previous_cache)):
            break;
    
    # checking for negative cycles
    previous_cache = cache[:]
    combined = (previous_cache.T + adjacency_matrix).min(axis=1)
    cache = minimum(previous_cache, combined)
    
    print("s: " + str(s) + " done " + str(time() - start_time))
    if(not alltrue(cache == previous_cache)):
        raise Exception("negative cycle bitches")
            
    shortest_paths.append([s, cache])
    
all_shortest = reduce(lambda x, y: concatenate((x,y), axis=1), map(lambda x: x[1], shortest_paths))
print(min(all_shortest))