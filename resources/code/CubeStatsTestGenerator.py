#!/usr/bin/python
#
# This program generates arenas and cubes for the CMPUT 229 CubeStats assignment
#
# Author: Jose Nelson Amaral
# Date: October 26 2011
#
# Known Issues:
# - Only works in dimensions 2 or above
#
# Updated by Taylor Lloyd, July 3, 2012

import sys
import random

DEBUG = 0

dimensions_to_generate = [2,3,4,5]
sizes_to_generate = [2,3,4,5]
max_cubes_to_generate = 5

def power(base, exponent):
    result = 1
    for t in range(0,exponent):
        result = result*base
    return result

def output_2d_plane(s):
    max_len = 2
    for i in range(0,s):
        for j in range(0,s):
            number =  random.randint(-99,99)
            file_out_machine.write(str(number) + "\n")
            count_len = len(str(number))
            for c in range(count_len, max_len+1):
                file_out_human.write(" ")
            file_out_human.write(str(number))
        file_out_human.write("\n")
    file_out_human.write("\n")
    return


for d in dimensions_to_generate:
    for s in sizes_to_generate:
        if(DEBUG):
            sys.stdout.write("d = " + str(d) + "  s = " + str(s) + "\n")
        filename_machine = "example_" + str(d) + "_" + str(s) + "_machine"
        filename_human = "example_" + str(d) + "_" + str(s) + "_human"
        file_out_machine = open(filename_machine,'w')
        file_out_human = open(filename_human,'w')
        file_out_machine.write(str(d) + "\n" + str(s) + "\n")
        file_out_human.write(str(d) + " " + str(s) + "\n")
        number_2d_planes = power(s,d-2)
        for plane in range(0,number_2d_planes):
            output_2d_plane(s)
        
        file_out_human.write("\n")
        num_cubes = random.randint(1,max_cubes_to_generate)
        if(DEBUG):
            sys.stdout.write("num_cubes = " + str(num_cubes) + "\n")
        for c in range(0,num_cubes):
            cube_size = random.randint(1,s)
            if(DEBUG):
                sys.stdout.write("cube_size = " + str(cube_size) + "\n")
            for i in range(0,d):
                p = random.randint(0,s-cube_size)
                file_out_human.write(str(p) + " ")
                file_out_machine.write(str(p) + "\n")
            file_out_human.write(str(cube_size) + "\n") 
            file_out_machine.write(str(cube_size) + "\n") 

        file_out_machine.write("-1\n")
        file_out_human.write("-1\n")
