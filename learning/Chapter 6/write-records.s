.include "linux.s"
.include "record-def.s"

.section .data 

record1:
	.ascii "Frederick\0"
	.rept 31
	.byte 0
	.endr 

	.ascii "NONE\0"
	.rept 35
	.byte 0
	.endr 

	.ascii "4242 S Prairie\nTulsa, OK 55555\0"
	.rept 209
	.byte 0
	.endr 

	.long 45

record2:
	.ascii "Marilyn\0"
	.rept 32
	.byte 0
	.endr 

	.ascii "Taylor\0"
	.rept 32
	.byte 0
	.endr 

	.ascii "Address\0"
	.rept 232
	.byte 0
	.endr 

	.long 36


file_name:
	.ascii "test.dat\0"

.section .text

.equ ST_FILE_DESCRIPTOR, -4 

.globl _start
_start:
	movl %esp, %ebp
	subl $4, %esp 

	#Open file
	movl $SYS_OPEN, %eax 
	movl $file_name, %ebx 
	movl $0101, %ecx 		#create if doesn't exist and open for writing

	movl $0666, %edx 
	int $LINUX_SYSCALL

	#Store the file descriptor away
	movl %eax, ST_FILE_DESCRIPTOR(%ebp)

	#Write the first record
	pushl ST_FILE_DESCRIPTOR(%ebp)
	pushl $record1
	call write_record
	addl $8, %esp 

	#Write the second record
	pushl ST_FILE_DESCRIPTOR(%ebp)
	pushl $record2
	call write_record
	addl $8, %esp

	#Close the file descriptor
	movl $SYS_CLOSE, %eax
	movl ST_FILE_DESCRIPTOR(%ebp), %ebx
	int $LINUX_SYSCALL

	#Exit the program
	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL
