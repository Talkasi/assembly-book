.include "definitions.s"
.section .data

hi_line:
	.ascii "\nWelcome to the TasiApp!\n\n\0"
hi_line_end:
.equ hi_line_len, hi_line_end - hi_line

ask_user:
	.ascii "\nTyping line: \0"
ask_user_end:
.equ ask_user_len, ask_user_end - ask_user

manual:
	.ascii "manual\0"

users_answer:
	.ascii "%s"

.equ RECORD_SIZE, 32
.section .bss
	.lcomm record_buffer, RECORD_SIZE

.section .text

.globl _start
_start:
	/*# start stuff
	pushl %ebp
	movl %esp, %ebp */
	movl $STDOUT, %ebx
	movl $hi_line, %ecx
	movl $hi_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	# lets explane the user what he can do:
	call start_man

waiting_for_user:
	movl $STDOUT, %ebx
	movl $ask_user, %ecx
	movl $ask_user_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl $STDIN, %ebx
	movl $record_buffer, %ecx
	movl $RECORD_SIZE, %edx
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	movl $STDOUT, %ebx
	movl $record_buffer, %ecx
	movl $RECORD_SIZE, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL
	/*
	pushl $record_buffer
	call printf


	# do what the user wants
	cmp $record_buffer, manual
	jne man_ask
	

	# funtcions: - create a new data file
	#			 - open an excist data file
	#			 - show manual
	*/
	movl $0, %ebx
	movl $SYS_EXIT, %eax
	int $LINUX_SYSCALL
/*
man_ask:
	call start_man
	jmp waiting_for_user */
#4e9906
#3464a1
#c7d0bb#E8F2D9
