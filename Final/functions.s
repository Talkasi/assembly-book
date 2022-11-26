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

.equ ID_POSITION, 0
.equ CAR_MODEL_POSITION, 10
.equ LICENSE_PLATE_POSITION, 35
.equ MANUFACTURE_YEAR_POSITION, 50
.equ OWNER_POSITION, 59

.equ ID_LEN, 5
.equ CAR_MODEL_LEN, 21
.equ LICENSE_PLATE_LEN, 11
.equ MANUFACTURE_YEAR_LEN, 5
.equ OWNER_LEN, 71

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

.globl itoa_func
.type itoa_func, @function
itoa_func:
	.equ ID, 4
	.equ DATA, 8
	movl DATA(%esp), %edi
	addl $4, %edi
	movl $0, %esi

	jmp itoa_loop 
         
itoa_loop:
	movl $0, %edx
	movl ID(%esp), %eax
	movl $10, %ecx
	div %ecx
	# %eax store ID/10
	# %edx store ID%10
	movl %eax, ID(%esp)

	or %edx, %eax
	cmp $0, %eax
	je itoa_end_normal

	cmp $5, %esi
	je itoa_end_normal

	add $48, %edx 
	movb %dl, (%edi)

	incl %esi 
	decl %edi 

	jmp itoa_loop

itoa_end_normal:
	movl $1, %eax
	ret

itoa_end_wrong:
	movl $0, %eax
	ret


.globl atoi_func
.type atoi_func, @function
atoi_func:
	# Store given_string_start_position in the %ebx. Expecting string is a null-terminated number
	.equ LEN, 8
	.equ BUFF, 4
	movl LEN(%esp), %esi
	movl BUFF(%esp), %ebx

	# NULL in the end of the string is not a number to count it in the length of the string
	dec %esi
	# There is a number should be multiplying by 10 ** 0, so lwngth - 1 is needed
	dec %esi

	# Compute 10 ** length
	push %esi
	push $10
	call power_func
	addl $8, %esp

	# %edi stores 10 ** (current position of the number)
	movl %eax, %edi

	# %ecx stores an answer
	movl $0, %ecx

	jmp atoi_loop

atoi_loop:
	# Comparing if current byte is NULL
	cmpb $0, (%ebx)
	# Exit if true
	je atoi_end

	# Set %eax to 0 to avoid rubish in the higher bytes of a register
	movl $0, %eax
	# Move lower byte of %ebx (current string with number) to %al
	movb (%ebx), %al
	# Receiving number from string with number (string - ascii code of 0)
	sub $48, %al
	# Multiplying %eax (current number) with ten ** power
	mul %edi

	# Add current result to the main result
	add %eax, %ecx

	# Set %ebx with the address of the next byte of the string (next number or space)
	incl %ebx

	# Dividing 10 ** power by ten
	movl %edi, %eax
	movl $10, %esi
	div %esi
	movl %eax, %edi

	jmp atoi_loop

atoi_end:
	movl %ecx, %eax
	ret


.globl power_func
.type power_func, @function
# First parameter from the stack is number_given
# Second parameter from the stack is power_given

# Returns number_given in power of power_given
power_func:
	# Stores power
	movl 8(%esp), %esi
	# Stores number
	movl 4(%esp), %ecx
	# Stores answer
	movl $1, %edi

	jmp power_loop

power_loop:
	# If %ebx <= 0 -> break
	cmpl $0, %esi
	jle power_end

	# While esi >= 1 do
	movl %edi, %eax
	mul %ecx
	movl %eax, %edi

	dec %esi
	jmp power_loop

power_end:
	movl %edi, %eax
	ret


.globl n_records_counter_func
.type n_records_counter_func, @function
n_records_counter_func:
	movl 4(%esp), %ebx
	movl $SYS_READ, %eax
	movl 8(%esp), %ecx
	movl 12(%esp), %edx
	int $LINUX_SYSCALL

	cmpl $0, %eax
	jle end_counter_func

	jmp n_records_counter_func

end_counter_func:
	movl $0, %edx
	movl 12(%esp), %ecx
	div %ecx
	incl %eax

	ret


.globl record_func 
.type record_func, @function
record_func:
	pushl %ebp
	movl %esp, %ebp
	.equ DATA, 8
	movl DATA(%ebp), %edi

	# Ask for a car model
	pushl $car_model_line_len
	pushl $car_model_line
	call print_func
	addl $8, %esp

	#	data_buffer		ret_addr	ebp		esp

	# Write car model into a data buffer
	pushl $CAR_MODEL_LEN
	addl $CAR_MODEL_POSITION, DATA(%ebp)
	pushl DATA(%ebp)
	call scan_func
	addl $8, %esp

	add %eax, DATA(%ebp)
	decl DATA(%ebp)
	movl DATA(%ebp), %eax
	movb $32, (%eax)


	# Ask for a licence plate
	pushl $license_plate_line_len
	pushl $license_plate_line
	call print_func
	addl $8, %esp

	# Write licence plate into a data buffer
	movl %edi, DATA(%ebp)
	pushl $LICENSE_PLATE_LEN
	addl $LICENSE_PLATE_POSITION, DATA(%ebp)
	pushl DATA(%ebp)
	call scan_func
	addl $8, %esp

	decl DATA(%ebp)
	addl %eax, DATA(%ebp)
	movl DATA(%ebp), %eax
	movb $32, (%eax)

	# Ask for a manufacture year
	pushl $manufacture_year_line_len
	pushl $manufacture_year_line
	call print_func
	addl $8, %esp

	# Write manufacture year into a data buffer
	movl %edi, DATA(%ebp)
	pushl $MANUFACTURE_YEAR_LEN
	addl $MANUFACTURE_YEAR_POSITION, DATA(%ebp)
	pushl DATA(%ebp)
	call scan_func
	addl $8, %esp

	decl DATA(%ebp)
	addl %eax, DATA(%ebp)
	movl DATA(%ebp), %eax
	movb $32, (%eax)

	# Ask for an owner's name
	pushl $owner_line_len
	pushl $owner_line
	call print_func
	addl $8, %esp

	# Write owner's name into a data buffer
	movl %edi, DATA(%ebp)
	pushl $OWNER_LEN
	addl $OWNER_POSITION, DATA(%ebp)
	pushl DATA(%ebp)
	call scan_func
	addl $8, %esp

	decl DATA(%ebp)
	addl %eax, DATA(%ebp)
	movl DATA(%ebp), %eax
	movb $32, (%eax)

	movl %ebp, %esp
	popl %ebp
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
