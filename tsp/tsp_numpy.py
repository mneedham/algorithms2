import os
from numpy import *
from time import time
import sys
from math import *
from itertools import chain, combinations

def all_subsets(ss):
  return chain(*map(lambda x: combinations(ss, x), range(0, len(ss)+1)))

file = open(os.path.dirname(os.path.realpath(__file__)) + "/" + sys.argv[1:][0])
number_of_cities = int(file.readline().replace("\n", ""))

cache = {}

for subset in all_subsets(range(1,number_of_cities+1)):
    if not subset in cache:
        # cache[subset] = [0 for k in xrange(number_of_cities+1)]
        cache[subset] = zeros(number_of_cities+1)
    if(subset == (1,)):
        cache[subset][1] = 0
    else:
        cache[subset][1] = float("inf")

def distance(city1, city2):
    return sqrt((city1[0]-city2[0]) ** 2 + (city1[1]-city2[1]) ** 2)

cities = []
for line in file.readlines():
    parts = line.replace("\n","").rstrip().split(" ")
    cities.append(map(float, parts))

adjacency_matrix = zeros((number_of_cities, number_of_cities)) 
for index, pair in enumerate(cities):
    for i in range(0, number_of_cities):
        # print("from: " + str(index) + " to: " + str(i) + " -> " + str(distance(cities[index], cities[i])))
        adjacency_matrix[index][i] = distance(cities[index], cities[i])

def subset_without(subset, element_to_remove):
    subset_without_j = []
    for s in list(subset):
        if not s == element_to_remove:
            subset_without_j.append(s)
    return tuple(subset_without_j)


for m in range(2,number_of_cities+1):
    subsets_to_consider = filter(lambda(subset): len(subset) == m and 1 in subset, cache.keys())
    print(subsets_to_consider)
    for subset in subsets_to_consider:
        print("start: " + str(subset) + " -> " + str(cache[subset]))
        # should be able to vectorise this bit
        cache[subset][2:] = cache[subset][2:]
        for j in subset:
            if j != 1:
                print("subset: " + str(subset))
                subset_without_j = subset_without(subset, j)                
                adj_matrix_costs = delete(adjacency_matrix[:, j-1], j-1, 0)
                cache_costs = delete(cache[subset_without_j][1:], j-1, 0)
                
                print("j: " + str(j))
                print("adj mat cost: " + str(adj_matrix_costs))
                print("subset costs: " + str(cache_costs))
                print("combined: " + str((adj_matrix_costs + cache_costs)))
                print("sum: " + str((adj_matrix_costs + cache_costs).min()))
                
                k_costs = []
                for k in subset:
                    if k != j:
                        k_cost = cache[subset_without_j][k] + adjacency_matrix[k-1][j-1]
                        k_costs.append(k_cost)
                print("costs: "  + str(k_costs))
                print("for min: " + str(min(k_costs)))
                print("vec min: " + str((adj_matrix_costs + cache_costs).min()))
                cache[subset][j] = min(k_costs)
        print("end: " + str(subset) + " -> " + str(cache[subset]))
            
minimum_tour_candidates = []

for j in range(2, number_of_cities+1):
    tour_cost = cache[tuple(range(1, number_of_cities+1))][j] + adjacency_matrix[j-1][0]
    minimum_tour_candidates.append(tour_cost)

print("minimum tour is: " + str(min(minimum_tour_candidates)))