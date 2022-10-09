.include "definitions.s"
.section .data

manual:
	.ascii "│\n"
	.ascii "├────────────────────┬─────────────────────────────────────────┐\n"
	.ascii "├─────  Command  ────┼─────────────  Description  ─────────────┤\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ manual             │ Lists all the commands supported        │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ create <file_name> │ Creates a new data file with a given    │\n"
	.ascii "│                    │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ open <file_name>   │ Opens already created data file with a  │\n"
	.ascii "│                    │ given file_name                         │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ view <file_name>   │ Lets user view the file with a given    │\n"
	.ascii "│                    │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ add record         │ Adds a new record to already opened     │\n"
	.ascii "│        <file_name> │ data file with a gven file_name         │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ change record      │ Changes record in already opened data   │\n"
	.ascii "│        <file_name> │ file with a gven file_name. Number of   │\n"
	.ascii "│                    │ the record would be asked after running │\n"
	.ascii "│                    │ a command                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ delete record      │ Deletes record in already opened data   │\n"
	.ascii "│        <file_name> │ file with a gven file_name. Number of   │\n"
	.ascii "│                    │ the record would be asked after running │\n"
	.ascii "│                    │ a command                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ close <file_name>  │ Close opend data file with a given      │\n"
	.ascii "│                    │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ exit               │ Exits an application                    │\n"
//	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
//	.ascii "├──────────────────────────────────────────────────────────────┤\n"
//	.ascii "├──────────────────────────────────────────────────────────────┤\n"
	.asciz "├────────────────────┴─────────────────────────────────────────┘\n"
manual_end:
.equ manual_len, manual_end - manual

slash_new_slash_line:
	.ascii "│\n│ "
slash_new_slash_line_end:
.equ slash_new_slash_line_len, slash_new_slash_line_end - slash_new_slash_line

new_slash_new_line:
	.ascii "\n│\n"
new_slash_new_line_end:
.equ new_slash_new_line_len, new_slash_new_line_end - new_slash_new_line

new_line:
	.ascii "\n"


.section .text

.globl print_man
.type print_man, @function
print_man:
	pushl %ebp
	movl %esp, %ebp

	movl $STDOUT, %ebx
	movl $manual, %ecx
	movl $manual_len, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl %ebp, %esp
	popl %ebp
	ret


.globl cmp_str
.type cmp_str, @function
cmp_str:
	.equ BUFF_ADDRESS, 4
	.equ MAN_ADDRESS, 8
	.equ MODE_ADDRESS, 12
	movl BUFF_ADDRESS(%esp), %edx
	movl MAN_ADDRESS(%esp), %ecx
	movl MODE_ADDRESS(%esp), %esi
	movl $0, %edi

cmp_loop:
	movb (%ecx), %bl
	cmpb $0, %bl
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
	jne cmp_status_exit

	decl %edx
	movb (%edx), %al
	cmpb $32, %al 
	je cmp_exit

	movl $1, %edi
	jmp cmp_exit

cmp_status_exit:
	cmpl $0, %esi 
	je cmp_exit

	movl $1, %edi
	jmp cmp_exit

cmp_exit:
	movl %edi, %eax
	ret	

.globl new_slash_new_line_func
.type new_slash_new_line_func, @function
new_slash_new_line_func:
	movl $STDOUT, %ebx
	movl $new_slash_new_line, %ecx 
	movl $new_slash_new_line_len, %edx 
	movl $SYS_WRITE, %eax 
	int $LINUX_SYSCALL
	ret

.globl slash_new_slash_line_func
.type slash_new_slash_line_func, @function
slash_new_slash_line_func:
	movl $STDOUT, %ebx
	movl $slash_new_slash_line, %ecx 
	movl $slash_new_slash_line_len, %edx 
	movl $SYS_WRITE, %eax 
	int $LINUX_SYSCALL
	ret
