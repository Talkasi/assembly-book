.include "definitions.s"
.section .data

manual:
	.ascii "│\n"
	.ascii "├────────────────────┬─────────────────────────────────────────┐\n"
	.ascii "├─────  Command  ────┼─────────────  Description  ─────────────┤\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ manual           + │ Lists all the commands supported        │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ create <file_name> │ Creates a new data file with a given    │\n"
	.ascii "│                  + │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ open <file_name>   │ Opens already created data file with a  │\n"
	.ascii "│                  + │ given file_name                         │\n"
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
	.ascii "│                  + │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ exit             + │ Exits an application                    │\n"
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

slash_new_line:
	.ascii "│\n"
slash_new_line_end:
.equ slash_new_line_len, slash_new_line_end - slash_new_line

new_line:
	.ascii "\n"


.section .text

.globl print_man
.type print_man, @function
print_man:
	movl $STDOUT, %ebx
	movl $manual, %ecx
	movl $manual_len, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

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

/*
main PROC
    mov  esi,OFFSET source              
    mov  edi,OFFSET target             
L1:
    mov  al,[esi]       
    mov  [edi],al       
    inc  esi            
    inc  edi            
    test al,al          ; you could also use  cmp al,0  if you prefer that
    JNZ L1              ; repeat the loop if al != 0
*/

.globl cpy_str
.type cpy_str, @function
cpy_str:
	.equ TO, 4
	.equ FROM, 8
	movl FROM(%esp), %edx
	movl TO(%esp), %ecx

cpy_loop:
	movb (%edx), %al 
	movb %al, (%ecx)

	cmpb $0, %al
	je cpy_end

	inc %ecx 
	inc %edx
	jmp cpy_loop

cpy_end:
  	ret

.globl buf_init
.type buf_init, @function
buf_init:
	.equ SIZE_ADDRESS, 8
	.equ BUFF_ADDRESS, 4
	movl SIZE_ADDRESS(%esp), %ecx
	movl BUFF_ADDRESS(%esp), %edx
	xor %edi, %edi

buf_init_loop:
	cmpl %ecx, %edi
	je buf_init_end

	movb $32, (%edx)

	inc %edx
	inc %edi
	jmp buf_init_loop

buf_init_end:
	decl %edx
	movb $10, (%edx)
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

.globl slash_new_line_func
.type slash_new_line_func, @function
slash_new_line_func:
	movl $STDOUT, %ebx
	movl $slash_new_line, %ecx 
	movl $slash_new_line_len, %edx 
	movl $SYS_WRITE, %eax 
	int $LINUX_SYSCALL
	ret
