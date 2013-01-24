import os
from numpy import *
from time import time
import sys

start_time = time()

file = open(os.path.dirname(os.path.realpath(__file__)) + "/" + sys.argv[1:][0])
number_of_cities = int(file.readline().replace("\n", ""))

cities = []
for line in file.readlines():
    cities.append(map(float, line.replace("\n","").split(" ")))

print(cities)

print(number_of_cities)

