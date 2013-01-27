import os
from numpy import *
from time import time
import sys
from math import *
from itertools import chain, combinations

def all_subsets(ss):
  return chain(*map(lambda x: combinations(ss, x), range(0, len(ss)+1)))
  
def subset_without(subset, element_to_remove):
    subset_without_j = []
    for s in list(subset):
        if not s == element_to_remove:
            subset_without_j.append(s)
    return tuple(subset_without_j)  

file = open(os.path.dirname(os.path.realpath(__file__)) + "/" + sys.argv[1:][0])
number_of_cities = int(file.readline().replace("\n", ""))

cache = {}
for subset in all_subsets(range(1,number_of_cities+1)):
    if not subset in cache:
        cache[subset] = zeros(number_of_cities+1)
    if(subset == (1,)):
        cache[subset][1] = 0
    else:
        cache[subset][1] = float("inf")
        
without_j = {}
for subset in all_subsets(range(1,number_of_cities+1)):
    if not subset in without_j:
        without_j[subset] = zeros(number_of_cities+1)

    def fn(x): 
        if not x in subset:
            return None
        else:
            return subset_without(subset, x)

    without_j[subset] = array(map(lambda x: fn(x), range(1, number_of_cities+1)))

# print(without_j)    
    
def distance(city1, city2):
    return sqrt((city1[0]-city2[0]) ** 2 + (city1[1]-city2[1]) ** 2)

cities = []
for line in file.readlines():
    parts = line.replace("\n","").rstrip().split(" ")
    cities.append(map(float, parts))

adjacency_matrix = zeros((number_of_cities, number_of_cities)) 
for index, pair in enumerate(cities):
    for i in range(0, number_of_cities):
        adjacency_matrix[index][i] = distance(cities[index], cities[i])

for m in range(2,number_of_cities+1):
    subsets_to_consider = filter(lambda(subset): len(subset) == m and 1 in subset, cache.keys())

    for subset in subsets_to_consider:
        # print("subset: " + str(subset))                
        # print("initial cache: " + str(cache[subset]))
        # 
        # print("without j to use: " + str(without_j[subset]))
        # print(cache[subset][1:])
        # print(cache[subset][1:] + without_j[subset])
        
        for j in subset:
            if j != 1:
                subset_without_j = tuple(without_j[subset][j-1])
                adj_matrix_costs = adjacency_matrix[:, j-1][map(lambda x: x-1, subset_without_j)]
                cache_costs = cache[subset_without_j][list(subset_without_j)]                
                cache[subset][j] = (adj_matrix_costs + cache_costs).min()
                
        # print("new cache: " + str(cache[subset]))
            
minimum_tour_candidates = []

for j in range(2, number_of_cities+1):
    tour_cost = cache[tuple(range(1, number_of_cities+1))][j] + adjacency_matrix[j-1][0]
    minimum_tour_candidates.append(tour_cost)

print("minimum tour is: " + str(min(minimum_tour_candidates)))