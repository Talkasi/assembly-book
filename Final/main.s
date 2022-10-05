.include "definitions.s"
.section .data

hi_line:
	.ascii "┌─────────────────────────────────────────────────────────────┐\n"
	.ascii "├─────────────────  Welcome to the TasIApp!  ─────────────────┤\n"
	.ascii "├─────────────────────────────────────────────────────────────┤\n"
	.ascii "│ Type 'manual' to list all the commands supported            │\n"
	.asciz "├─────────────────────────────────────────────────────────────┘\n"
hi_line_end:
.equ hi_line_len, hi_line_end - hi_line

ask_user:
	.ascii "│ Command_line_@TasiApp: \0"
ask_user_end:
.equ ask_user_len, ask_user_end - ask_user

error_command:
	.ascii "│\n"
	.ascii "│ TasIApp doesn't support this command.\n"
	.ascii "│\n"
	.ascii "│ Here is a list of all commands supported:\n"
error_command_end:
.equ error_command_len, error_command_end - error_command

exit_line:
	.ascii "├─────────────────────────────────────────────────────────────┐\n"
	.ascii "├──────────────────────  Good bye! 🌚  ───────────────────────┤\n"
	.ascii "└─────────────────────────────────────────────────────────────┘\n"
exit_line_end:
.equ exit_line_len, exit_line_end - exit_line

file_exist_line:
	.ascii "│\n"
	.ascii "│ Error. File was not created.\n"
	.ascii "│ Try to change file_name or directory to solve the problem\n"
	.ascii "│\n"
file_exist_line_end:
.equ file_exist_line_len, file_exist_line_end - file_exist_line

manual:
	.ascii "manual\0"

exit:
	.ascii "exit\0"

create:
	.ascii "create \0"

view:
	.ascii "view \0"

beauty:
	.ascii "│\n"
	.ascii "│ "
beauty_end:
.equ beauty_len, beauty_end - beauty

file_created_n:
	.ascii "│\n"
	.ascii "│ File was successfully created.\n\0"
	.ascii "│\n"
file_created_n_end:
.equ file_created_n_len, file_created_n_end - file_created_n

users_answer:
	.ascii "%s"

new_line:
	.ascii "\n│\n"
new_line_end:
.equ new_line_len, new_line_end - new_line

.equ RECORD_SIZE, 16
.section .bss
	.lcomm record_buffer, RECORD_SIZE
.equ DATA_SIZE, 105
.section .bss
	.lcomm data_buffer, DATA_SIZE

.section .text

.globl _start
_start:
	# Print the first hi-line in terminal
	movl $STDOUT, %ebx
	movl $hi_line, %ecx
	movl $hi_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

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

	# Manual check, comparing using "\0"
	pushl $0
	pushl $manual
	pushl $record_buffer
	call cmp_str
	addl $8, %esp

	cmpl $1, %eax
	je man_ask

	# Exit check, comparing using "\0"
	pushl $0
	pushl $exit
	pushl $record_buffer
	call cmp_str
	addl $8, %esp

	cmpl $1, %eax
	je exit_ask

	# Create file check, comparing + file_name existance check
	pushl $1
	pushl $create
	pushl $record_buffer
	call cmp_str
	addl $8, %esp

	cmpl $1, %eax
	je create_ask

	# View check, comparing + file_name existance check
	pushl $1
	pushl $view
	pushl $record_buffer
	call cmp_str
	addl $8, %esp

	cmpl $1, %eax
	je view_ask

	# Command not found
	movl $STDOUT, %ebx
	movl $error_command, %ecx
	movl $error_command_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	call start_man
	jmp waiting_for_user

man_ask:
	call start_man
	jmp waiting_for_user 

create_ask:
	movl $SYS_CREATE, %eax
	movl $record_buffer + 7, %ebx
	movl $0777, %ecx
	int $LINUX_SYSCALL

	cmpl $0, %eax 
	jl file_exist

	# Send notification about our success
	movl $STDOUT, %ebx
	movl $file_created_n, %ecx
	movl $file_created_n_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp waiting_for_user

file_exist:
	movl $STDOUT, %ebx
	movl $file_exist_line, %ecx
	movl $file_exist_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp waiting_for_user

view_ask:
	movl $SYS_OPEN, %eax 
	movl $record_buffer + 5, %ebx
	movl $2, %ecx
	movl $0777, %edx
	int $LINUX_SYSCALL

	movl %eax, %ebx
	movl $SYS_READ, %eax
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	int $LINUX_SYSCALL

	movl $STDOUT, %ebx
	movl $beauty, %ecx
	movl $beauty_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl $STDOUT, %ebx
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl $STDOUT, %ebx
	movl $new_line, %ecx
	movl $new_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	#TODO:		- count number of records
	
	jmp waiting_for_user

exit_ask:
	movl $STDOUT, %ebx
	movl $exit_line, %ecx
	movl $exit_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl $0, %ebx
	movl $SYS_EXIT, %eax
	int $LINUX_SYSCALL
