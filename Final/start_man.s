.include "definitions.s"
.section .data

create_line:
	.ascii "> Type 'create' to create a new data file.\n\0"
create_line_end:
.equ create_line_len, create_line_end - create_line

exit_line:
	.ascii "> Type 'exit' to exit the app.\n\0"
exit_line_end:
.equ exit_line_len, exit_line_end - exit_line

manual_line:
	.ascii "> Type 'manual' to see the list of the hole operations supported.\n\0"
manual_line_end:
.equ manual_line_len, manual_line_end - manual_line

.section .text

.globl start_man
.type start_man, @function
start_man:
	pushl %ebp
	movl %esp, %ebp

	movl $STDOUT, %ebx
	movl $create_line, %ecx
	movl $create_line_len, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl $STDOUT, %ebx
	movl $exit_line, %ecx
	movl $exit_line_len, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl $STDOUT, %ebx
	movl $manual_line, %ecx
	movl $manual_line_len, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl %ebp, %esp
	popl %ebp
	ret
