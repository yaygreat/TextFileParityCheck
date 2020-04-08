.data

ifile: 	 .asciiz "input.txt"

okmsg:		 .asciiz "data is ok"
notokmsg: .asciiz "data has been corrupted"

buffer: 	 .space 100
buffer2:  .space 100 # reserve space to copy file contents with parity bit

.text

###############################################################

# Open a file for input
li $v0, 13         		  #open a file
li $a1, 0           		  #reading flag
la $a0, ifile      		  # load file name
add $a2, $zero, $zero   	  # file mode (unused)
syscall
move $a0, $v0        #file decriptor
li $v0, 14           #read from file
la $a1, buffer    # allocate space for the bytes loaded
li $a2, 100         # number of bytes to be read
syscall  
la $a0, buffer        # address of string to be printed
li $v0, 4            # print string
syscall
# Close the file
li $v0, 16 # system call for close file
move $a0, $s6 # file descriptor to close
syscall # close file

jal setParityBit
addi $zero, $0, 0		#sentinal
jal checkParityBit

exit:	#exit 
li $v0, 10
syscall



setParityBit:
la $a1, buffer # load address of buffer 
la $a2, buffer2 # load address of parity buffer
li $t0, 0		#load 0 in t0 couter

loop1:		#set parity loop
bgt $t0, 100, exitloop1
lb $t1 , ($a1)

# parity bit is sets msb to 1 if number of 1's is odd to make the parity even
srl $t3, $t1, 16
xor $t2, $t1, $t3
srl $t3, $t2, 8
xor $t2, $t2, $t3
srl $t3, $t2, 4
xor $t2, $t2, $t3
srl $t3, $t2, 2
xor $t2, $t2, $t3
srl $t3, $t2, 1
xor $t2, $t2, $t3
and $t2, $t2, 1

sll $t2,$t2,7		#shift the parity bit to 8 by 
or $t1,$t1,$t2 		#set parity
sb $t1, ($a2)		#store byte in buffer
add $a1,$a1,1 		#increment buffer ptr
add $a2,$a2,1		#increment buffer2 ptr
addi $t0,$t0,1 		#loop counter
j loop1
exitloop1: 
jr $ra

checkParityBit:
loop2:
bgt $t0, 100, exitloop2
lb $t1 , ($a1)
# bit wise XOR of character read from buffer to find parity
# parity bit is set if number of 1's is odd to make the parity even
srl $t3, $t1, 16
xor $t2, $t1, $t3
srl $t3, $t2, 8
xor $t2, $t2, $t3
srl $t3, $t2, 4
xor $t2, $t2, $t3
srl $t3, $t2, 2
xor $t2, $t2, $t3
srl $t3, $t2, 1
xor $t2, $t2, $t3
and $t2, $t2, 1
beq $t2, 0, ok 	   # if 0 ok else
li $v0, 4 		 	#else error msg
la $a0, notokmsg 	#load address of message into $a0
syscall 	
			
j exitCheckParity
ok:
add $a1,$a1,1  # increment pointers to next character
addi $t0,$t0,1 # loop counter
j loop2

exitloop2:
li $v0, 4 		#system call code for Print String
la $a0, okmsg #load address of message into $a0
syscall #print the string

exitCheckParity:
jr $ra
