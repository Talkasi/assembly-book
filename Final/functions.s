.include "definitions.s"
.section .data

manual:
	.ascii "│\n"
	.ascii "├────────────────────┬────────────────────────────────────────┐\n"
	.ascii "├─────  Command  ────┼────────────  Description  ─────────────┤\n"
	.ascii "├────────────────────┼────────────────────────────────────────┤\n"
	.ascii "│ create <file_name> │ Creates a new data file with a given   │\n"
	.ascii "│                    │ file_name                              │\n"
	.ascii "├────────────────────┼────────────────────────────────────────┤\n"
	.ascii "│ manual             │ Lists all the commands supported       │\n"
	.ascii "├────────────────────┼────────────────────────────────────────┤\n"
	.ascii "│ exit               │ Exits an application                   │\n"
	.asciz "├────────────────────┴────────────────────────────────────────┘\n"

manual_end:
.equ manual_len, manual_end - manual

new_line:
	.ascii "\n"


.section .text

.globl start_man
.type start_man, @function
start_man:
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
