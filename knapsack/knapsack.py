import os

def knapsack_cached(rows, knapsack_size, index):
    global cache
    if(index is 0 or knapsack_size is 0):
        return 0
    else:
        value, weight = rows[index]
        if(weight > knapsack_size and knapsack_size not in cache[index-1]):
            cache[index-1][knapsack_size] = knapsack_cached(rows, knapsack_size, index-1)                
        else:
            if(knapsack_size not in cache[index-1]):
                option_1  = knapsack_cached(rows, knapsack_size, index-1)
                option_2  = value + knapsack_cached(rows, knapsack_size - weight, index-1)
                cache[index-1][knapsack_size] = max(option_1, option_2)                
            
        return cache[index-1][knapsack_size]
                    
file = open(os.path.dirname(os.path.realpath(__file__)) + "/knapsack2.txt")

knapsack_size, number_of_items = file.readline().replace("\n", "").split(" ")
knapsack_size = int(knapsack_size)
number_of_items = int(number_of_items)

rows = []
for line in file.readlines():
    value, weight = line.split(" ")
    rows.append([int(value), int(weight)])

cache = []
for i in range(0, number_of_items):
    cache.append({})
    
result = knapsack_cached(rows, knapsack_size, number_of_items-1)    
print(result)