#
# CMPUT 229: Cube Statistics Laboratory
# Author: Jose Nelson Amaral
# Date: December 2009
#
# Main program to read base array into memory,
# read a several cube specifications
# and print statistics for each cube.
#
	.data
arena:
	.space 32768
Pedge:
	.asciiz "edge = "
PnegAvg:
	.asciiz ", Negative Average = "
PposAvg:	
	.asciiz ", Positive Average = "
Pnewline:
	.asciiz "\n"

# These data items will be used by the CubeStats method.
	.globl countNeg
	.globl countPos
	.globl totalNeg
	.globl totalPos
totalNeg:	.word 0
totalPos:	.word 0
countNeg:	.word 0
countPos:	.word 0

######################################################################
# Register usage:                                                    #
# $s0: dimension                                                     #
# $s1: size                                                          #
# $s2: edge                                                          #
# $s3: first                                                         #
######################################################################
	
	.text
	.globl power
power:
	li $v0, 1
ploop:	
	beqz $a1, pdone
	mul $v0, $v0, $a0
	subu $a1, $a1, 1
	j ploop
pdone:
	jr $ra
	
	.globl main
main:
	subu     $sp, $sp, 4            # Adjust the stack to save $fp
	sw	 $fp, 0($sp)            # Save $fp
	move     $fp, $sp	        # $fp <-- $fp
	subu     $sp, $sp, 4	        # Adjust stack to save $ra
	sw	 $ra, -4($fp)	        # Save the return address ($ra)

	# Get the dimension
	li	 $v0, 5
	syscall
	move     $s0, $v0               # $s0 <-- dimension

	# Get the size
	li	 $v0, 5
	syscall
	move     $s1, $v0               # $s1 <-- size

	# Calculate numelems
	move     $a0, $s1	        # $a0 <-- size
	move     $a1, $s0	        # $a1 <-- dimension
	jal	 power		        # numelems <-- power(size,dimension)

	# Read array
	sll	 $v0,$v0,2	        # $v0 <-- 4*numelems
	la	 $t5, arena	        # cursor <-- start of arena 
	add	 $t6, $t5, $v0	        # $t6 <-- end of array
ReadArray:
	li	 $v0, 5
	syscall			        # $v0 <-- element
	sw	 $v0, 0($t5)	    # *cursor <-- element
	addi $t5, $t5, 4	        # *cursor++
	blt	 $t5, $t6, ReadArray # if(cursor<end of array) 

forever:
	# Read a Cube
	la	 $s3, arena	        # first <-- start of arena
	add	 $t2, $0, $0	        # d <-- 0
	
ReadCube:
	# Get the corner, calculating its absolute location along the way
	li	 $v0, 5
	syscall			        # $v0 <-- cubed
	move     $t4, $v0		# $t4 <-- cubed
	blt	 $t4, $0, ExitMain	# if(cubed<0) ExitMain
	move     $a0, $s1		# $a0 <-- size
	sub      $a1, $s0, $t2		# $a1 <-- dimension - d
	addi     $a1, $a1, -1       # $a1 <-- dimension - d - 1
	jal	 power			# $v0 <-- power(size,d)
	mul	 $t3, $t4, $v0	        # $t3 <-- cubed*power(size,dimension - d - 1)
	sll      $t3, $t3, 2            # $t3 <-- 4*$t3 (offset)
	add	 $s3, $s3, $t3	        # first = first + cubed*power(size,dimension - d - 1)
	add	 $t2, $t2, 1	        # d <-- d + 1
	blt	 $t2, $s0, ReadCube     # if(d<dimension) ReadCube

	# Get the edge length
	li	 $v0, 5
	syscall				# $v0 <-- edge
	move     $s2, $v0		# $s2 <-- edge

	# Initialize totals and counts to be used by CubeStats
	sw	$0, countNeg
	sw	$0, countPos
	sw	$0, totalNeg	
	sw	$0, totalPos
	# Set up the arguments and call CubeStats
	move     $a0, $s0		# $a0 <-- dimension
	move     $a1, $s1		# $a1 <-- size
	move     $a2, $s3		# $a2 <-- first
	move     $a3, $s2		# $a3 <-- edge
	
	jal	 CubeStats
	# Get the averages into $t0, $t1
	move     $t0, $v0
	move     $t1, $v1

	# Print the value of the edge
	li       $v0, 4
	la       $a0, Pedge
	syscall
	move     $a0, $s2
	li       $v0, 1
	syscall

	# Print the value of the positive average
	li       $v0, 4
	la       $a0, PposAvg
	syscall
	move     $a0, $t1
	li       $v0, 1
	syscall

	# Print the value of the negative average
	li      $v0, 4
	la      $a0, PnegAvg
	syscall
	move    $a0, $t0
	li      $v0, 1
	syscall
	li		$v0, 4
	la		$a0, Pnewline
	syscall
	j       forever
	
ExitMain:	
	# Usual stuff at the end of the main
	lw      $ra, -4($fp)
	addu    $sp, $sp, 4
	lw      $fp, 0($sp)
	addu    $sp, $sp, 4
	jr      $ra
