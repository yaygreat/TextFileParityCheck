	.data
file:	.asciiz		"C:\\Users\\domin\\Desktop\\hw3txtfile.txt"
	.align	2
buffer1:	.space	50	#how long should this be?
	.align	2
buffer2:	.space	50
	.align	2
okmsg:	.asciiz		"data is ok"
	.align	2
badmsg:	.asciiz		"data is corrupted"

	.text
main:	#open file
	li	$v0, 13			#syscall 13 to open file
	la	$a0, file		#$a0- address of string containing filename
	li	$a1, 0			#$a1- flags
	li	$a2, 0			#$a2- mode
	syscall				#$v0- contains file string
	move	$s0, $v0			#and is stored in $s0

	#read from file and store in buffer
	li	$v0, 14			#syscall 14 to read from file
	move	$a0, $s0			#store file string ($s0) into $a0
	la	$a1, buffer1		#address of input buffer
	li	$a2, 50			#$a2- max number of bytes to read- how many are we reading?
	syscall
	
	#li	$v0, 4			#syscall to print string
	#la	$a0, buffer1
	#syscall
	
	#close file
	li	$v0, 16			#syscall 16 to close file
	add	$a0, $s0, $0		#store file string ($s0) into $a0
	syscall
	
	la	$s1, buffer1		#load address of buffer1 into $s1
	la	$s2, buffer2		#load address of buffer1 into $s2
	li	$t0, 0			#loop counter for fn. setparity
	jal	setparity
	
	la	$s2, buffer2
	li	$t0, 0			#loop counter for fn. checkparity
	j	checkparity
				
setparity:
	beq	$t0, 50, return	#go to checkparity if reached the end of buffer1
	li	$t6, 0			#$t6 = 0 used w/xor to see if even/odd parity
	lb	$t1, ($s1)		#load byte of buffer1 into $t1
	
	srl	$t5, $t1, 6		#shift to only check bit 6 (7th bit)
	xor	$t7, $t5, $t6		#results in parity = 1 if bit 6 (now 0) = 1
	
	srl	$t5, $t1, 5
	xor	$t7, $t5, $t7

	srl	$t5, $t1, 4
	xor	$t7, $t5, $t7
	
	srl	$t5, $t1, 3
	xor	$t7, $t5, $t7
	
	srl	$t5, $t1, 2
	xor	$t7, $t5, $t7
	
	srl	$t5, $t1, 1		#shift to check bit 1
	xor	$t7, $t5, $t7
	
	xor	$t7, $t1, $t7		#check bit 0, sets bit 0 = 1 if odd parity
	andi	$t7, $t7, 1		#sets bit 7-1 = 0 and bit 0 = 1 if odd parity	
	sll	$t7, $t7, 7		#final parity generated
	or	$t1,$t1, $t7		#parity is now bit 7 (8th bit) of buffer1
	sb	$t1, ($s2)		#store new byte w/parity bit into buffer2
	
	add	$s1, $s1, 1		#go to next byte (char) of buffer1
	add	$s2, $s2, 1		#go to next byte (char) of buffer2
	addi	$t0, $t0, 1		#increment counter
	j setparity
	
return:	jr $ra	
	
checkparity:
	beq	$t0, 50, exit		#exit if reached the end of buffer2
	li	$t6, 0			#$t6 = 0 used w/xor to see if even/odd parity
	lb	$t2, ($s2)		#load byte of buffer2 into $t1
	
	srl	$t5, $t2, 6		#shift to only check bit 6 (7th bit)
	xor	$t7, $t5, $t6		#results in parity = 1 if bit 6 (now 0) = 1
	
	srl	$t5, $t2, 5
	xor	$t7, $t5, $t7

	srl	$t5, $t2, 4
	xor	$t7, $t5, $t7
	
	srl	$t5, $t2, 3
	xor	$t7, $t5, $t7
	
	srl	$t5, $t2, 2
	xor	$t7, $t5, $t7
	
	srl	$t5, $t2, 1		#shift to check bit 1
	xor	$t7, $t5, $t7
	
	xor	$t7, $t2, $t7		#check bit 0, sets bit 0 = 1 if odd parity
	andi	$t7, $t7, 1		#sets bit 7-1 = 0 and bit 0 = 1 if odd parity
	srl	$t2, $t2, 7
	andi	$t2, $t2, 1		#sets bit 7-1 = 0 and bit 0 = 1 if odd parity
	
	bne	$t7, $t2, corrupted
	add	$s2, $s2, 1		#moves to next byte (char) of buffer2
	addi	$t0, $t0, 1		#increment counter
	j	checkparity

corrupted:
	li	$v0, 4			#print NOT OK message
	la	$a0, badmsg
	syscall
	li	$v0, 10			#exit
	syscall

exit:	li	$v0, 4			#print OK message
	la	$a0, okmsg
	syscall
	li	$v0, 10			#exit
	syscall