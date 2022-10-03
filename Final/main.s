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

new_line:
	.ascii "\n"

.equ RECORD_SIZE, 16
.section .bss
	.lcomm record_buffer, RECORD_SIZE

.section .text

.globl _start
_start:
	# Print the first hi-line in terminal
	movl $STDOUT, %ebx
	movl $hi_line, %ecx
	movl $hi_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	# Print the list of instructions in terminal
	call start_man

waiting_for_user:
	# Print query line in terminal
	movl $STDOUT, %ebx
	movl $ask_user, %ecx
	movl $ask_user_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	# Get the information from the terminal to the buffer
	movl $STDIN, %ebx
	movl $record_buffer, %ecx
	movl $RECORD_SIZE, %edx
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	decl %eax
	movl $0, record_buffer(,%eax,1)

/*
	# Print line to make sure recieving the command was successful
	movl $STDOUT, %ebx
	movl $record_buffer, %ecx
	movl $RECORD_SIZE, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	pushl $record_buffer
	call write
	addl $4, %esp
*/
	# Start working with stack 

	pushl $manual
	pushl $record_buffer
	call cmp_str
	addl $8, %esp

	cmpl $1, %eax
	je man_ask

	# funtcions: - create a new data file
	#			 - open an excist data file
	#			 - show manual

	movl $0, %ebx
	movl $SYS_EXIT, %eax
	int $LINUX_SYSCALL

man_ask:
	call start_man
	jmp waiting_for_user 

.globl cmp_str
.type cmp_str, @function
cmp_str:
	.equ BUFF_ADDRESS, 4
	.equ MAN_ADDRESS, 8
	movl BUFF_ADDRESS(%esp), %edx
	movl MAN_ADDRESS(%esp), %ecx
	movl $0, %edi

cmp_loop:
	movb (%edx), %al
	cmpb $0, %al
	je end_buff

	movb (%edx), %al
	movb (%ecx), %bl
	cmpb %al, %bl
	jne cmp_exit

	incl %edx
	incl %ecx
	jmp cmp_loop

end_buff:
	movb (%edx), %al
	movb (%ecx), %bl
	cmpb %al, %bl
	jne cmp_exit

	movl $1, %edi
	jmp cmp_exit

cmp_exit:
	movl %edi, %eax
	ret	
/*
.globl write
.type write, @function
write:
	movl 4(%esp), %edi

loop:
	movb (%edi), %al
	cmpb $0, %al
	je exit 

	movl $STDOUT, %ebx
	movl (%edi), %ecx
	movl $1, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl $STDOUT, %ebx
	movl $new_line, %ecx
	movl $1, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	incl %edi

	jmp loop

exit:
	ret
*/