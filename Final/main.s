.section .data
hi_line:
	.ascii "\nWelcome to the TasiApp!\n\n\0"

ask_user:
	.ascii "\nTyping line: \0"

manual:
	.ascii "manual\0"
users_answer:
	.ascii "%s"

.equ RECORD_SIZE, 7

.section .bss
	.lcomm record_buffer, RECORD_SIZE

#Common Linux Definitions
#System Call Numbers
.equ SYS_EXIT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN, 5
.equ SYS_CLOSE, 6
.equ SYS_BRK, 45

#System Call Interrupt Number
.equ LINUX_SYSCALL, 0x80

#Standard File Descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

#Common Status Codes
.equ END_OF_FILE, 0

.section .text

.globl _start
_start:
	/*# start stuff
	pushl %ebp
	movl %esp, %ebp */
	pushl $hi_line
	call printf

	# lets explane the user what he can do:
	call start_man

waiting_for_user:
	pushl $ask_user
	call printf
	
	# read what the user wants
	pushl $record_buffer
	pushl $users_answer
	call scanf

	pushl $record_buffer
	call printf


	# do what the user wants
	cmp $record_buffer, manual
	jne man_ask
	

	# funtcions: - create a new data file
	#			 - open an excist data file
	#			 - show manual

	call exit

man_ask:
	call start_man
	jmp waiting_for_user


