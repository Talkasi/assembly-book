
.section .data

create_line:
	.ascii "> Type 'create' to create a new data file.\n\0"

exit_line:
	.ascii "> Type 'exit' to exit the app.\n\0"

manual_line:
	.ascii "> Type 'manual' to see the list of the hole operations supported.\n\0"


.section .text

.globl start_man

.type start_man, @function
start_man:
	pushl %ebp
	movl %esp, %ebp

	pushl $create_line 
	call printf

	pushl $exit_line 
	call printf

	pushl $manual_line
	call printf

	movl %ebp, %esp
	popl %ebp
	ret
