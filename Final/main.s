.include "definitions.s"
.section .data

# Lines to print block
hi_line:
	.ascii "┌─────────────────────────────────────────────────────────────┐\n"
	.ascii "├─────────────────  Welcome to the TasIApp!  ─────────────────┤\n"
	.ascii "├─────────────────────────────────────────────────────────────┤\n"
	.ascii "│ Type 'manual' to list all the commands supported            │\n"
	.asciz "├─────────────────────────────────────────────────────────────┘\n"
hi_line_end:
.equ hi_line_len, hi_line_end - hi_line

beauty_line:
	.ascii "│\n"
	.ascii "│ "
beauty_line_end:
.equ beauty_line_len, beauty_line_end - beauty_line

new_line:
	.ascii "\n│\n"
new_line_end:
.equ new_line_len, new_line_end - new_line

file_created_n_line:
	.ascii "│\n"
	.ascii "│ File was successfully created.\n\0"
	.ascii "│\n"
file_created_n_line_end:
.equ file_created_n_line_len, file_created_n_line_end - file_created_n_line

ask_user_line:
	.ascii "│ Command_line_@TasiApp: \0"
ask_user_line_end:
.equ ask_user_line_len, ask_user_line_end - ask_user_line

error_command_line:
	.ascii "│\n"
	.ascii "│ TasIApp doesn't support this command.\n"
	.ascii "│\n"
	.ascii "│ Here is a list of all commands supported:\n"
error_command_line_end:
.equ error_command_line_len, error_command_line_end - error_command_line

file_exist_line:
	.ascii "│\n"
	.ascii "│ Error. File was not created.\n"
	.ascii "│ Try to change file_name or directory to solve the problem\n"
	.ascii "│\n"
file_exist_line_end:
.equ file_exist_line_len, file_exist_line_end - file_exist_line

exit_line:
	.ascii "├─────────────────────────────────────────────────────────────┐\n"
	.ascii "├──────────────────────  Good bye! 🌚  ───────────────────────┤\n"
	.ascii "└─────────────────────────────────────────────────────────────┘\n"
exit_line_end:
.equ exit_line_len, exit_line_end - exit_line

# Commands block to check what user wants
manual_command:
	.ascii "manual\0"

exit_command:
	.ascii "exit\0"

create_command:
	.ascii "create \0"

view_command:
	.ascii "view \0"

add_record_command:
	.ascii "add record\0"

# Buffers block
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
	movl $ask_user_line, %ecx
	movl $ask_user_line_len, %edx
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
	pushl $manual_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je man_ask

	# Exit check, comparing using "\0"
	pushl $0
	pushl $exit_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je exit_ask

	# Create file check, comparing + file_name existance check
	pushl $1
	pushl $create_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je create_ask

	# View check, comparing + file_name existance check
	pushl $1
	pushl $view_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je view_ask

	# Add record check, comparing using "\0"
	pushl $0
	pushl $add_record_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax 
	je add_record_ask

	# Command not found
	movl $STDOUT, %ebx
	movl $error_command_line, %ecx
	movl $error_command_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	call print_man
	jmp waiting_for_user

man_ask:
	call print_man
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
	movl $file_created_n_line, %ecx
	movl $file_created_n_line_len, %edx
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
	movl $beauty_line, %ecx
	movl $beauty_line_len, %edx
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

	#TODO:		- add "add record" command
	#			- count number of records to make view command work normally
	#			- fix success notification (again)

	jmp waiting_for_user

add_record_ask:
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
