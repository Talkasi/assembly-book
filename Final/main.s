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

exit_line:
	.ascii "├─────────────────────────────────────────────────────────────┐\n"
	.ascii "├──────────────────────  Good bye! 🌚  ───────────────────────┤\n"
	.ascii "└─────────────────────────────────────────────────────────────┘\n"
exit_line_end:
.equ exit_line_len, exit_line_end - exit_line

# Add record line block
car_model_line:
	.ascii "│\n"
	.ascii "│ Enter model of the car: \0"
car_model_line_end:
.equ car_model_line_len, car_model_line_end - car_model_line

license_plate_line:
	.ascii "│ Enter license plate: \0"
license_plate_line_end:
.equ license_plate_line_len, license_plate_line_end - license_plate_line

manufacture_year_line:
	.ascii "│ Enter year of car manufacture: \0"
manufacture_year_line_end:
.equ manufacture_year_line_len, manufacture_year_line_end - manufacture_year_line

owner_line:
	.ascii "│ Enter owner of the car: \0"
owner_line_end:
.equ owner_line_len, owner_line_end - owner_line

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

open_command:
	.ascii "open \0"

close_command:
	.ascii "close \0"

new_line:
	.ascii "\n"

# Errors line block
command_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. TasIApp doesn't support this command.\n"
	.ascii "│\n"
	.ascii "│ Here is a list of all commands supported:\n"
command_error_line_end:
.equ command_error_line_len, command_error_line_end - command_error_line

create_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. File was not created.\n"
	.ascii "│ - Try to change file_name or directory to solve this problem.\n"
	.ascii "│\n"
create_error_line_end:
.equ create_error_line_len, create_error_line_end - create_error_line

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


# Buffers block
.equ RECORD_SIZE, 100
.equ DATA_SIZE, 130
.equ OPENED_FILE_NAME_SIZE, 50
.section .bss
	.lcomm record_buffer, RECORD_SIZE
	.lcomm data_buffer, DATA_SIZE
	.lcomm opened_file_name_buffer, OPENED_FILE_NAME_SIZE

.equ CAR_MODEL_POSITION, 0
.equ LICENSE_PLATE_POSITION, 25
.equ MANUFACTURE_YEAR_POSITION, 40
.equ OWNER_POSITION, 49

.equ CAR_MODEL_LEN, 21
.equ LICENSE_PLATE_LEN, 11
.equ MANUFACTURE_YEAR_LEN, 5
.equ OWNER_LEN, 71

.section .text

.globl _start
_start:
	pushl %ebp
	movl %esp, %ebp

	# Print the first hi-line in terminal
	movl $STDOUT, %ebx
	movl $hi_line, %ecx
	movl $hi_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	# To check if file is opened at the moment
	.equ OPENED_FLAG, -4
	push $0


# Main loop
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
	movl $SYS_OPEN, %eax
	movl $record_buffer + 7, %ebx
	movl $2, %ecx
	movl $0777, %edx
	int $LINUX_SYSCALL

	cmpl $0, %eax 
	jnl create_error

	movl $SYS_CREATE, %eax
	movl $record_buffer + 7, %ebx
	movl $0777, %ecx
	int $LINUX_SYSCALL

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

	call slash_new_slash_line_func

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

	movl $STDOUT, %ebx
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	call slash_line_func
	jmp view_ask_loop

view_ask_end:
	call new_slash_new_line_func

	jmp waiting_for_user

add_record_ask:
	pushl $DATA_SIZE
	pushl $data_buffer
	call buf_init
	addl $8, %esp

	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $SYS_LSEEK, %eax
	movl $0, %ecx
	movl $2, %edx
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

	# Ask for a car model
	movl $STDOUT, %ebx
	movl $car_model_line, %ecx 
	movl $car_model_line_len, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	# Write car model into a data buffer
	movl $STDIN, %ebx
	movl $data_buffer + CAR_MODEL_POSITION, %ecx 
	movl $CAR_MODEL_LEN, %edx
	movl $SYS_READ, %eax 
	int $LINUX_SYSCALL

	movb $32, data_buffer + CAR_MODEL_POSITION - 1(%eax)

	# Ask for a licence plate
	movl $STDOUT, %ebx
	movl $license_plate_line, %ecx 
	movl $license_plate_line_len, %edx 
	movl $SYS_WRITE, %eax 
	int $LINUX_SYSCALL

	# Write licence plate into a data buffer
	movl $STDIN, %ebx
	movl $data_buffer + LICENSE_PLATE_POSITION, %ecx 
	movl $LICENSE_PLATE_LEN, %edx
	movl $SYS_READ, %eax 
	int $LINUX_SYSCALL

	movb $32, data_buffer + LICENSE_PLATE_POSITION - 1(%eax)

	# Ask for a manufacture year
	movl $STDOUT, %ebx
	movl $manufacture_year_line, %ecx 
	movl $manufacture_year_line_len, %edx 
	movl $SYS_WRITE, %eax 
	int $LINUX_SYSCALL

	# Write manufacture year into a data buffer
	movl $STDIN, %ebx
	movl $data_buffer + MANUFACTURE_YEAR_POSITION, %ecx 
	movl $MANUFACTURE_YEAR_LEN, %edx
	movl $SYS_READ, %eax 
	int $LINUX_SYSCALL

	movb $32, data_buffer + MANUFACTURE_YEAR_POSITION - 1(%eax)

	# Ask for an owner's name
	movl $STDOUT, %ebx
	movl $owner_line, %ecx 
	movl $owner_line_len, %edx 
	movl $SYS_WRITE, %eax 
	int $LINUX_SYSCALL

	# Write owner's name into a data buffer
	movl $STDIN, %ebx
	movl $data_buffer + OWNER_POSITION, %ecx 
	movl $OWNER_LEN, %edx
	movl $SYS_READ, %eax 
	int $LINUX_SYSCALL	

	movb $32, data_buffer + OWNER_POSITION - 1(%eax)

	call slash_new_slash_line_func

	movl $STDOUT, %ebx
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	call new_slash_new_line_func

	# Write into a file
	movl DESCRIPTOR_POSITION(%ebp), %ebx
	movl $data_buffer, %ecx
	movl $DATA_SIZE, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

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

	movl $STDOUT, %ebx
	movl $exit_line, %ecx
	movl $exit_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	movl %ebp, %esp
	popl %ebp

	movl $0, %ebx
	movl $SYS_EXIT, %eax
	int $LINUX_SYSCALL


# Errors block
create_error:
	# Print error message
	movl $STDOUT, %ebx
	movl $create_error_line, %ecx
	movl $create_error_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp waiting_for_user

open_error:
	# Print error message
	movl $STDOUT, %ebx
	movl $open_error_line, %ecx
	movl $open_error_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp waiting_for_user

not_opened_error:
	# Print error message
	movl $STDOUT, %ebx
	movl $not_opened_error_line, %ecx
	movl $not_opened_error_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp waiting_for_user

close_error:
	# Print error message
	movl $STDOUT, %ebx
	movl $close_error_line, %ecx
	movl $close_error_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp waiting_for_user

not_closed_error:
	# Print error message
	movl $STDOUT, %ebx
	movl $not_closed_error_line, %ecx
	movl $not_closed_error_line_len, %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	jmp waiting_for_user
