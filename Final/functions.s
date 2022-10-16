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
	.ascii "│                  + │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ add record         │ Adds a new record to the end of already │\n"
	.ascii "│      <file_name> + │ opened data file with a given file_name │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ change record      │ Changes record in already opened data   │\n"
	.ascii "│      <file_name>   │ file with a given file_name. Number of  │\n"
	.ascii "│                    │ the record would be asked after running │\n"
	.ascii "│                    │ a command                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ delete record      │ Deletes record in already opened data   │\n"
	.ascii "│      <file_name>   │ file with a given file_name. Number of  │\n"
	.ascii "│                    │ the record would be asked after running │\n"
	.ascii "│                    │ a command                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ close <file_name>  │ Close opend data file with a given      │\n"
	.ascii "│                  + │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ exit             + │ Exits an application                    │\n"
	.asciz "├────────────────────┴─────────────────────────────────────────┘\n"
manual_end:
.equ manual_len, manual_end - manual


# Errors line block
create_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. File was not created.\n"
	.ascii "│ - Try to change file_name or directory to solve this problem.\n"
	.ascii "│\n"
create_error_line_end:
.equ create_error_line_len, create_error_line_end - create_error_line

command_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. TasIApp doesn't support this command.\n"
	.ascii "│\n"
	.ascii "│ Here is a list of all commands supported:\n"
command_error_line_end:
.equ command_error_line_len, command_error_line_end - command_error_line

open_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. File was not opened.\n"
	.ascii "│ - You should create file before open it.\n"
	.ascii "│ - Only one file can be opened at a time.\n"
	.ascii "│ Close the file you're working with to open another one.\n"
	.ascii "│\n"
open_error_line_end:
.equ open_error_line_len, open_error_line_end - open_error_line

not_opened_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. File was not opened.\n"
	.ascii "│ - You should open file before dealing with it.\n"
	.ascii "│\n"
not_opened_error_line_end:
.equ not_opened_error_line_len, not_opened_error_line_end - not_opened_error_line

close_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. File was not closed.\n"
	.ascii "│ - Only opened files can be closed\n"
	.ascii "│\n"
close_error_line_end:
.equ close_error_line_len, close_error_line_end - close_error_line

not_closed_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. Close opened file to exit TasIApp.\n"
	.ascii "│\n"
not_closed_error_line_end:
.equ not_closed_error_line_len, not_closed_error_line_end - not_closed_error_line

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


.globl create_func
.type create_func, @function
create_func:
	movl $SYS_OPEN, %eax
	movl 4(%esp), %ebx
	movl $2, %ecx
	movl $0777, %edx
	int $LINUX_SYSCALL

	cmpl $0, %eax 
	jnl create_error

	movl $SYS_CREATE, %eax
	movl 4(%esp), %ebx
	movl $0777, %ecx
	int $LINUX_SYSCALL

	jmp create_exit

create_error:
	# Print error message
	movl $STDOUT, %ebx
	movl $create_error_line, %ecx
	movl $create_error_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp create_exit

create_exit:
	movl $1, %eax
	ret

.equ FIRST_ARG, 4
.equ SECOND_ARG, 8

.globl print_func
.type print_func, @function
print_func:
	movl $STDOUT, %ebx
	movl FIRST_ARG(%esp), %ecx 		# line
	movl SECOND_ARG(%esp), %edx		# len
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	ret

.globl scan_func
.type scan_func, @function
scan_func:
	movl $STDIN, %ebx
	movl FIRST_ARG(%esp), %ecx 		# line
	movl SECOND_ARG(%esp), %edx		# len
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	ret

.globl id_func
.type id_func, @function
id_func:
	.equ ID, 4
	.equ DATA, 8
	movl DATA(%esp), %edi
	addl $4, %edi
	movl $0, %esi

	jmp id_loop 
         
id_loop:
	movl $0, %edx
	movl ID(%esp), %eax
	movl $10, %ecx
	div %ecx
	# %eax store ID/10
	# %edx store ID%10
	movl %eax, ID(%esp)

	or %edx, %eax
	cmp $0, %eax
	je id_end_normal

	cmp $5, %esi
	je id_end_wrong

	add $48, %edx 
	movb %dl, (%edi)

	incl %esi 
	decl %edi 

	jmp id_loop

id_end_normal:
	movl $1, %eax
	ret

id_end_wrong:
	movl $0, %eax
	ret

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

