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

ask_user_line:
	.ascii "│ Command_line_@TasiApp: \0"
ask_user_line_end:
.equ ask_user_line_len, ask_user_line_end - ask_user_line

table_information_line:
	.ascii "├────────┬────────────────────────┬──────────────┬────────┬─────────────────────────────────────────────────────────────────────────┐\n"
	.ascii "│    #   │       Car model        │   Lisence #  │  Year  │                               Owners name                               │\n"
	.asciz "├────────┴────────────────────────┴──────────────┴────────┴─────────────────────────────────────────────────────────────────────────┘\n"
table_information_line_end:
.equ table_information_line_len, table_information_line_end - table_information_line

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
	.ascii "add record \0"

change_record_command:
	.ascii "change record \0"

delete_record_command:
	.ascii "delete record \0"

open_command:
	.ascii "open \0"

close_command:
	.ascii "close \0"

new_line:
	.ascii "\n"

slash_new_line:
	.ascii "│\n"
slash_new_line_end:
.equ slash_new_line_len, slash_new_line_end - slash_new_line

slash_new_slash_line:
	.ascii "│\n│ "
slash_new_slash_line_end:
.equ slash_new_slash_line_len, slash_new_slash_line_end - slash_new_slash_line

new_slash_new_line:
	.ascii "\n│\n"
new_slash_new_line_end:
.equ new_slash_new_line_len, new_slash_new_line_end - new_slash_new_line

slash_line:
	.ascii "│ \0"
slash_line_end:
.equ slash_line_len, slash_line_end - slash_line

end_of_line:
	.ascii "\0"

# Errors line block
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

itoa_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. TasIApp doesn't support more than 99999 records in a file\n"
	.ascii "│\n"
itoa_error_line_end:
.equ itoa_error_line_len, itoa_error_line_end - itoa_error_line

close_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. File wasn't closed because it wasn't opened.\n"
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

change_record_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. The record you want to change doesn't exist.\n"
	.ascii "│\n"
change_record_error_line_end:
.equ change_record_error_line_len, change_record_error_line_end - change_record_error_line

delete_record_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. The record you want to delete doesn't exist.\n"
	.ascii "│\n"
delete_record_error_line_end:
.equ delete_record_error_line_len, delete_record_error_line_end - delete_record_error_line

number_ask_line:
	.ascii "│\n"
	.ascii "│ Enter number of the record should be changed: "
number_ask_line_end:
.equ number_ask_line_len, number_ask_line_end - number_ask_line

number_ask_delete_line:
	.ascii "│\n"
	.ascii "│ Enter number of the record should be deleted: "
number_ask_delete_line_end:
.equ number_ask_delete_line_len, number_ask_delete_line_end - number_ask_delete_line

# Buffers block
.equ RECORD_SIZE, 130
.equ DATA_SIZE, 130
.equ OPENED_FILE_NAME_SIZE, 50
.section .bss
	.lcomm record_buffer, RECORD_SIZE
	.lcomm data_buffer, DATA_SIZE
	.lcomm opened_file_name_buffer, OPENED_FILE_NAME_SIZE

.section .text

.globl _start
_start:
	pushl %ebp
	movl %esp, %ebp

	# Print the first hi-line in terminal
	pushl $hi_line_len
	pushl $hi_line
	call print_func
	addl $8, %esp

	# To check if file is opened at the moment
	.equ OPENED_FLAG, -4
	push $0


# Main loop
waiting_for_user:
	# Print query line in terminal
	pushl $ask_user_line_len
	pushl $ask_user_line
	call print_func
	addl $8, %esp

	# Get the information from the terminal to the buffer
	pushl $RECORD_SIZE
	pushl $record_buffer
	call scan_func
	addl $8, %esp 

	movl $0, record_buffer - 1(%eax)

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

	# Add record check, comparing + file_name existance check
	pushl $1
	pushl $add_record_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax 
	je add_record_ask

	# Change record check, comparing + file_name existance check
	pushl $1
	pushl $change_record_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je change_record_ask

	# Change record check, comparing + file_name existance check
	pushl $1
	pushl $delete_record_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je delete_record_ask

	# Open file check, comparing + file_name existance check
	pushl $1
	pushl $open_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je open_ask

	# Close file check, comparing + file_name existance check
	pushl $1
	pushl $close_command
	pushl $record_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	je close_ask

	# Command not found
	movl $STDOUT, %ebx
	movl $command_error_line, %ecx
	movl $command_error_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	call print_man
	jmp waiting_for_user


# Commands block
man_ask:
	call print_man
	jmp waiting_for_user 

create_ask:
	pushl $record_buffer + 7
	call create_func
	addl $4, %esp

	jmp waiting_for_user

open_ask:
	movl $SYS_OPEN, %eax
	movl $record_buffer + 5, %ebx
	movl $2, %ecx
	movl $0777, %edx
	int $LINUX_SYSCALL

	cmpl $0, %eax 
	jl open_error

	cmpl $0, OPENED_FLAG(%ebp)
	jne open_error

	movl $1, OPENED_FLAG(%ebp)
	pushl %eax
	.equ DESCRIPTOR_POSITION, -8

	pushl $OPENED_FILE_NAME_SIZE
	pushl $opened_file_name_buffer
	call buf_init
	addl $8, %esp

	pushl $record_buffer + 5
	pushl $opened_file_name_buffer
	call cpy_str
	addl $8, %esp

	jmp waiting_for_user

view_ask:
	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp

	pushl $0
	pushl $record_buffer + 5
	pushl $opened_file_name_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	jne not_opened_error

	cmpl $0, OPENED_FLAG(%ebp)
	je not_opened_error

	pushl $table_information_line_len
	pushl $table_information_line
	call print_func
	addl $8, %esp 

	pushl $slash_line_len
	pushl $slash_line
	call print_func
	addl $8, %esp

	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $SYS_LSEEK, %eax
	movl $0, %ecx
	movl $0, %edx
	int $LINUX_SYSCALL

	jmp view_ask_loop

view_ask_loop:
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $SYS_READ, %eax
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	int $LINUX_SYSCALL

	cmpl $0, %eax
	jle view_ask_end

	pushl $DATA_SIZE
	pushl $data_buffer
	call print_func
	addl $8, %esp

	pushl $slash_line_len
	pushl $slash_line
	call print_func
	addl $8, %esp 

	jmp view_ask_loop

view_ask_end:
	pushl $1
	pushl $new_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user


add_record_ask:
	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp

	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $SYS_LSEEK, %eax
	movl $0, %ecx
	movl $0, %edx
	int $LINUX_SYSCALL

	pushl $0
	pushl $record_buffer + 11
	pushl $opened_file_name_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	jne not_opened_error

	cmpl $0, OPENED_FLAG(%ebp)
	je not_opened_error

	pushl $DATA_SIZE
	pushl $data_buffer
	pushl DESCRIPTOR_POSITION(%ebp)
	call n_records_counter_func
	addl $12, %esp

	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp

	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $SYS_LSEEK, %eax
	movl $0, %ecx
	movl $2, %edx
	int $LINUX_SYSCALL

	movl $0, %edx
	movl $DATA_SIZE, %ecx
	div %ecx
	incl %eax

	pushl $data_buffer
	pushl %eax
	call itoa_func
	addl $8, %esp

	cmpl $0, %eax
	je itoa_error

	pushl $data_buffer
	call record_func
	addl $4, %esp

	pushl $slash_new_slash_line_len
	pushl $slash_new_slash_line
	call print_func
	addl $8, %esp

	pushl $DATA_SIZE
	pushl $data_buffer
	call print_func
	addl $8, %esp

	# Write into a file
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	pushl $slash_new_line_len
	pushl $slash_new_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user


change_record_ask:
	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp

	pushl $0
	pushl $record_buffer + 14
	pushl $opened_file_name_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	jne not_opened_error

	cmpl $0, OPENED_FLAG(%ebp)
	je not_opened_error

	pushl $number_ask_line_len
	pushl $number_ask_line
	call print_func
	addl $8, %esp 

	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp 

	pushl $DATA_SIZE
	pushl $data_buffer
	call scan_func
	addl $8, %esp

	movl $32, data_buffer - 1(%eax)

	pushl %eax
	pushl $data_buffer
	call atoi_func
	addl $4, %esp
	# %eax stores # of the record user wants to change
	pushl %eax

	pushl $DATA_SIZE
	pushl $data_buffer
	pushl DESCRIPTOR_POSITION(%ebp)
	call n_records_counter_func
	addl $12, %esp
	# %eax stores last record number exist

	cmpl %eax, (%esp)
	jg change_record_error
	cmpl $1, (%esp)
	jl change_record_error

	# Make %eax store position of the cursor
	decl (%esp)
	movl $DATA_SIZE, %eax
	movl (%esp), %ecx
	mul %ecx

	# Set cursor to the found position
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl %eax, %ecx
	movl $SYS_LSEEK, %eax
	movl $0, %edx
	int $LINUX_SYSCALL

	# Initialize buffer with spaces
	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp 

	# Write number of the record to a buffer
	pushl $data_buffer
	addl $1, 4(%esp)
	pushl 4(%esp)
	call itoa_func
	addl $8, %esp

	# Check an error
	cmpl $0, %eax
	je itoa_error

	# Ask user for a new parameters
	pushl $data_buffer
	call record_func
	addl $4, %esp

	# Write buffer into a file on the position of the cursor
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	pushl $slash_new_slash_line_len
	pushl $slash_new_slash_line
	call print_func
	addl $8, %esp

	pushl $DATA_SIZE
	pushl $data_buffer
	call print_func
	addl $8, %esp

	pushl $slash_new_line_len
	pushl $slash_new_line
	call print_func
	addl $8, %esp

	addl $4, %esp
	jmp waiting_for_user

delete_record_ask:
	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp

	pushl $0
	pushl $record_buffer + 14
	pushl $opened_file_name_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	jne not_opened_error

	cmpl $0, OPENED_FLAG(%ebp)
	je not_opened_error

	# Push line asking user about number of the record should be deleted
	pushl $number_ask_delete_line_len
	pushl $number_ask_delete_line
	call print_func
	addl $8, %esp 

	# Initialize buffer with spaces
	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp 

	# Scan number of record should be deleted
	pushl $DATA_SIZE
	pushl $data_buffer
	call scan_func
	addl $8, %esp

	# Delete '\n' from the end of the number
	movl $32, data_buffer - 1(%eax)

	# Convert string to integer
	pushl %eax
	pushl $data_buffer
	call atoi_func
	addl $4, %esp
	# %eax stores # of the record user wants to delete
	pushl %eax

	# Count number of records exist
	pushl $DATA_SIZE
	pushl $data_buffer
	pushl DESCRIPTOR_POSITION(%ebp)
	call n_records_counter_func
	addl $12, %esp

	# %eax stores last record number exist
	# If record should be deleted doesn't exist through an error
	cmpl (%esp), %eax
	jl delete_record_error
	cmpl $1, (%esp)
	jl delete_record_error

	# Make %eax store position of the cursor
	decl (%esp)
	movl $DATA_SIZE, %eax
	movl (%esp), %ecx
	mul %ecx

	# Value of the number of record user wants to delete is now useless
	addl $4, %esp

	# push current cursor position to the stack
	pushl %eax

	# Set cursor to the found position
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl %eax, %ecx
	movl $SYS_LSEEK, %eax
	movl $0, %edx
	int $LINUX_SYSCALL

	# Read current data line to the record buffer
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $record_buffer, %ecx
	movl $RECORD_SIZE, %edx
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	pushl $slash_new_slash_line_len
	pushl $slash_new_slash_line
	call print_func
	addl $8, %esp

	pushl $RECORD_SIZE
	pushl $record_buffer
	call print_func
	addl $8, %esp

	pushl $slash_new_line_len
	pushl $slash_new_line
	call print_func
	addl $8, %esp

	pushl $DATA_SIZE
	pushl $data_buffer
	call confirm_func
	addl $8, %esp

	cmpl $0, %eax
	je mistake_appears

	# Set cursor to the found position
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl (%esp), %ecx
	movl $SYS_LSEEK, %eax
	movl $0, %edx
	int $LINUX_SYSCALL

	jmp delete_record_loop

delete_record_loop:
	# Read current data line to the record buffer
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $record_buffer, %ecx
	movl $RECORD_SIZE, %edx
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	# Read next data line to the data buffer
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	cmp $0, %eax
	je delete_record_end

	# Set cursor to the position of the current data line 
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl (%esp), %ecx
	movl $SYS_LSEEK, %eax
	movl $0, %edx
	int $LINUX_SYSCALL

	# Copy next data line with the number of previous data line
	pushl $record_buffer
	pushl $data_buffer
	call move_func
	addl $8, %esp

	# Write buffer into a file on a position of the cursor
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $record_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	# Add DATA_SIZE to the current position of the cusror in the stack
	addl $DATA_SIZE, (%esp)

	jmp delete_record_loop

delete_record_end:
	pushl $slash_new_line_len
	pushl $slash_new_line
	call print_func
	addl $8, %esp

	movl $SYS_FTRUNCATE, %eax
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl (%esp), %ecx
	int $LINUX_SYSCALL

	addl $4, %esp
	jmp waiting_for_user

mistake_appears:
	pushl $slash_new_line_len
	pushl $slash_new_line
	call print_func
	addl $8, %esp
	
	addl $4, %esp
	jmp waiting_for_user

close_ask:
	cmpl $0, OPENED_FLAG(%ebp)
	je close_error

	pushl $0
	pushl $record_buffer + 6
	pushl $opened_file_name_buffer
	call cmp_str
	addl $12, %esp

	cmpl $1, %eax
	jne close_error

	pushl $OPENED_FILE_NAME_SIZE
	pushl $opened_file_name_buffer
	call buf_init
	addl $8, %esp

	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $SYS_CLOSE, %eax
	int $LINUX_SYSCALL

	# Error check
	cmpl $0, %eax
	jl close_error

	movl $0, OPENED_FLAG(%ebp)
	addl $4, %esp
	jmp waiting_for_user

exit_ask:
	cmpl $0, OPENED_FLAG(%ebp)
	jne not_closed_error

	pushl $exit_line_len
	pushl $exit_line
	call print_func
	addl $8, %esp

	movl %ebp, %esp
	popl %ebp

	movl $0, %ebx
	movl $SYS_EXIT, %eax
	int $LINUX_SYSCALL

open_error:
	# Print error message
	pushl $open_error_line_len
	pushl $open_error_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user

not_opened_error:
	# Print error message
	pushl $not_opened_error_line_len
	pushl $not_opened_error_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user

itoa_error:
	pushl $itoa_error_line_len
	pushl $itoa_error_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user

change_record_error:
	pushl $change_record_error_line_len
	pushl $change_record_error_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user

delete_record_error:
	pushl $delete_record_error_line_len
	pushl $delete_record_error_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user

close_error:
	# Print error message
	pushl $close_error_line_len
	pushl $close_error_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user

not_closed_error:
	# Print error message
	pushl $not_closed_error_line_len
	pushl $not_closed_error_line
	call print_func
	addl $8, %esp

	jmp waiting_for_user
