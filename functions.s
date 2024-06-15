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
	.ascii "│                  + │ a command                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ delete record      │ Deletes record in already opened data   │\n"
	.ascii "│      <file_name>   │ file with a given file_name. Number of  │\n"
	.ascii "│                    │ the record would be asked after running │\n"
	.ascii "│                  + │ a command                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ close <file_name>  │ Close opend data file with a given      │\n"
	.ascii "│                  + │ file_name                               │\n"
	.ascii "├────────────────────┼─────────────────────────────────────────┤\n"
	.ascii "│ exit             + │ Exits an application                    │\n"
	.asciz "├────────────────────┴─────────────────────────────────────────┘\n"
manual_end:
.equ manual_len, manual_end - manual

# Confirming line block
confirm_line:
	.ascii "│ [!]Are you sure you want to delete this line?[y/n] \0"
confirm_line_end:
.equ confirm_line_len, confirm_line_end - confirm_line

password_line:
	.ascii "│\n"
	.ascii "│ Set password to a file: "
password_line_end:
.equ password_line_len, password_line_end - password_line

password_confirm_line:
	.ascii "│\n"
	.ascii "│ Repeat the password: "
password_confirm_line_end:
.equ password_confirm_line_len, password_confirm_line_end - password_confirm_line

# Errors line block
create_password_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. Passwords aren't simulare. Try again.\n"
create_password_error_line_end:
.equ create_password_error_line_len, create_password_error_line_end - create_password_error_line

confirm_line_error:
	.ascii "\n│ [!]Error. Enter symbol `y` for `yes` or `n` for `no` in any case to continue. \n"
confirm_line_error_end:
.equ confirm_line_error_len, confirm_line_error_end - confirm_line_error

create_error_line:
	.ascii "│\n"
	.ascii "│ [!]Error. File was not created.\n"
	.ascii "│ - Try to change file_name or directory to solve this problem.\n"
	.ascii "│\n"
create_error_line_end:
.equ create_error_line_len, create_error_line_end - create_error_line

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
# Prints manual
print_man:
	movl $STDOUT, %ebx
	movl $manual, %ecx
	movl $manual_len, %edx 
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	ret


.globl create_func
.type create_func, @function
# Creates a file and set the password to it

# First parameter from the stack is name of a file to create
# Second parameter from the stack is a data_buffer
# Third parameter from the stack is a size of a data_buffer
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

	jmp create_password

create_password:
	pushl $password_line_len
	pushl $password_line
	call print_func
	addl $8, %esp

	movl 12(%esp), %ecx
	movl 8(%esp), %edx

	pushl %ecx 
	pushl %edx
	call buf_init
	addl $8, %esp

	movl 12(%esp), %ecx
	movl 8(%esp), %edx

	pushl %ecx 
	pushl %edx
	call scan_func
	addl $8, %esp

	movl 12(%esp), %ecx
	movl 8(%esp), %edx

	pushl %eax
	pushl %edx
	call hash_func
	addl $8, %esp 

	# Store hash value
	pushl %eax

	movl 16(%esp), %ecx
	movl 12(%esp), %edx

	pushl $password_confirm_line_len
	pushl $password_confirm_line
	call print_func
	addl $8, %esp

	movl 16(%esp), %ecx
	movl 12(%esp), %edx

	pushl %ecx 
	pushl %edx
	call buf_init
	addl $8, %esp

	movl 16(%esp), %ecx
	movl 12(%esp), %edx

	pushl %ecx 
	pushl %edx
	call scan_func
	addl $8, %esp

	movl 16(%esp), %ecx
	movl 12(%esp), %edx

	pushl %eax
	pushl %edx
	call hash_func
	addl $8, %esp 

	cmp (%esp), %eax
	jne create_password_error

	movl 16(%esp), %ecx
	movl 12(%esp), %edx

	pushl %ecx 
	pushl %edx
	call buf_init
	addl $8, %esp

	# Make string from a hash number
	movl 16(%esp), %ecx
	movl 12(%esp), %edx

	decl %ecx
	decl %ecx
	pushl %ecx
	pushl %edx
	pushl 8(%esp)
	call itoa_func
	addl $16, %esp

	# Open the file
	movl $SYS_OPEN, %eax
	movl 4(%esp), %ebx
	movl $2, %ecx
	movl $0777, %edx
	int $LINUX_SYSCALL

	# save descriptor 
	pushl %eax

	# Write string with hash to a file
	movl %eax, %ebx
	movl 12(%esp), %ecx
	movl 16(%esp), %edx
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	# Close the file
	movl (%esp), %ebx
	movl $SYS_CLOSE, %eax
	int $LINUX_SYSCALL

	# Delete descriptor
	addl $4, %esp

	jmp create_exit

create_password_error:
	addl $4, %esp
	# Print error message
	pushl $create_password_error_line_len
	pushl $create_password_error_line
	call print_func
	addl $8, %esp

	jmp create_password

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


.globl hash_func
.type hash_func, @function
# Compute hash of a string

# Frist parameter from a string is data_buffer
# Second parameter from a string is a size of a bata_buffer

# returns hash of the given string
hash_func:
	.equ SIZE, 8
	.equ BUFFER, 4

	movl SIZE(%esp), %ecx
	movl BUFFER(%esp), %ebx

	movl $5381, %esi
	movl $0, %edi

	jmp hash_loop

hash_loop:
	cmpl SIZE(%esp), %edi
	jge hash_end

	movl $0, %edx
	movl $3, %eax
	mul %esi
	movl %eax, %esi

	movl $0, %eax
	movb (%ebx), %al
	addl %eax, %esi 

	incl %edi
	incl %ebx
	jmp hash_loop

hash_end:
	movl %esi, %eax
	ret


.globl itoa_func
.type itoa_func, @function
# Convertes integer-number to a string and writes it on the position of the records number

# %edi stores position in data_buffer where answer should be start written
# %esi stores number of symbols were written

# returns 0 if error occured, 1 if not
itoa_func:
	.equ NUMBER, 4
	.equ DATA, 8
	.equ POSITION, 12
	movl DATA(%esp), %edi
	addl POSITION(%esp), %edi
	incl POSITION(%esp)
	movl $0, %esi

	jmp itoa_loop 
         
itoa_loop:
	movl $0, %edx
	movl NUMBER(%esp), %eax
	movl $10, %ecx
	div %ecx
	# %eax store NUMBER/10
	# %edx store NUMBER%10
	movl %eax, NUMBER(%esp)

	or %edx, %eax
	cmp $0, %eax
	je itoa_end_normal

	cmp POSITION(%esp), %esi
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
# Convertes string with an integer to a number

# First parameter from the stack is a buffer with a string
# Second parameter from the stack is a size of a buffer with a string

# returns number recieved from the string
atoi_func:
	# Store given_string_start_position in the %ebx. Expecting string is a null-terminated integer
	.equ LEN, 8
	.equ BUFF, 4
	movl LEN(%esp), %esi
	movl BUFF(%esp), %ebx

	# NULL in the end of the string is not a number to count it in the length of the string
	dec %esi
	# There is a number should be multiplying by 10 ** 0, so length - 1 is needed
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
	cmpb $32, (%ebx)
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
	movl $0, %edx
	movl %edi, %eax
	movl $10, %esi
	div %esi
	movl %eax, %edi

	jmp atoi_loop

atoi_end:
	movl %ecx, %eax
	ret


.globl n_records_counter_func
.type n_records_counter_func, @function
# Computes number of records stored in data base

# First parameter from the stack is file descriptor
# Second parameter from the stack is buffer to read in
# Third parameter from the stack is size of a buffer

# %esi stores an answer

# returns number of records
n_records_counter_func:
	.equ DATA_SIZE, 12
	.equ BUFFER, 8
	.equ DESCRIPTOR, 4
	movl $0, %esi

	# Set cursor to the start of the firs record
	# (first DATA_SIZE bytes store password's hash)
	movl DESCRIPTOR(%esp), %ebx
	movl $SYS_LSEEK, %eax
	movl DATA_SIZE(%esp), %ecx
	movl $0, %edx
	int $LINUX_SYSCALL

	jmp n_records_counter_loop

n_records_counter_loop:
	# Read DATA_SIZE bytes from the file
	movl DESCRIPTOR(%esp), %ebx 			# descriptor of a file
	movl $SYS_READ, %eax
	movl BUFFER(%esp), %ecx 				# start of a buffer
	movl DATA_SIZE(%esp), %edx				# size of a buffer
	int $LINUX_SYSCALL

	# %eax stores number of symbols was read from a file
	# If zero bytes were read -> end of file was reached
	cmpl $0, %eax
	jle end_counter_func

	# Coumpute sum of symbols were read from a file
	addl %eax, %esi

	jmp n_records_counter_loop

end_counter_func:
	# Sum divided by 1 record length is the number of records
	movl $0, %edx
	movl %esi, %eax
	movl DATA_SIZE(%esp), %ecx
	div %ecx

	# Answer is already in %eax (after division)
	ret


.globl record_func 
.type record_func, @function
# Asks user about all needed parameters for a record and saves answers to a given buffer
# First parameter from the stack is a buffer
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


.globl buf_init
.type buf_init, @function
# Initializes buffer with spaces and '\n' in the end

# First parameter from the stack is given buffer
# Second parameter from the stack is size of a given buffer
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


.globl move_func
.type move_func, @function
# Copies a string from the sourse string starting with the car_model_position

# %ecx stores address of the first character in current_line
# %edx stores address of the first character in next_line
# First $ID_LEN characters store ID, start moving from $ID_LEN + 1
move_func:
	.equ CURRENT_LINE, 8
	.equ NEXT_LINE, 4
	movl CURRENT_LINE(%esp), %ecx 
	movl NEXT_LINE(%esp), %edx 

	add $CAR_MODEL_POSITION, %ecx 
	add $CAR_MODEL_POSITION, %edx
	jmp move_loop

move_loop:
	movl $0, %eax

	movb (%edx), %al
	movb %al, (%ecx)

	cmpb $10, %al
	je move_end

	inc %ecx 
	inc %edx 
	jmp move_loop

move_end:
	ret


.globl confirm_func
.type confirm_func, @function
# Asks if chosen record should be deleted or not

# First parameter from the stack is a size of a buffer to save confirming answer
# Second parameter from the stack is a buffer to save confirming answer

# returns 1 if users answer is yes, 0 if no
confirm_func:
	movl 8(%esp), %ecx # <- Data_size
	movl 4(%esp), %edx # <- Data_buffer

	pushl $confirm_line_len
	pushl $confirm_line
	call print_func
	addl $8, %esp 

	movl 8(%esp), %ecx # <- Data_size
	movl 4(%esp), %edx # <- Data_buffer

	pushl %ecx
	pushl %edx
	call scan_func
	addl $8, %esp

	movl 8(%esp), %ecx # <- Data_size
	movl 4(%esp), %edx # <- Data_buffer

	# Yes block
	movl $0, %eax
	movl $0, %ecx
	# If first character is Y then %al == 0
	movb (%edx), %al
	xor $89, %al

	# If first character is y then %cl == 0
	movb (%edx), %cl
	xor $121, %cl

	# If %cl == 0 or %al == 0 then %al == 0
	and %cl, %al

	# %al now is 0 if y or Y was on the first place
	# Check the second place
	inc %edx
	# If second character is `\n` then %cl == 0
	movb (%edx), %cl
	xor $10, %cl

	# %al is 0 if 'y\n' or 'Y\n'
	or %cl, %al

	cmpb $0, %al
	je confirm_end_true

	dec %edx

	# No block
	movl $0, %eax
	movl $0, %ecx
	# If first character is N then %al == 0
	movb (%edx), %al
	xor $78, %al

	# If first character is n then %cl == 0
	movb (%edx), %cl
	xor $110, %cl
	
	# If %cl == 0 or %al == 0 then %al == 0
	and %cl, %al

	# %al now is 0 if n or N was on the first place
	# Check the second place
	inc %edx
	# If second character is `\n` then %cl == 0
	movb (%edx), %cl
	xor $10, %cl

	# %al is 1 if 'n\n' or 'N\n'
	or %cl, %al

	cmpb $0, %al
	je confirm_end_false

	pushl $confirm_line_error_len
	pushl $confirm_line_error
	call print_func
	addl $8, %esp 

	jmp confirm_func

confirm_end_true:
	movl $1, %eax
	ret 

confirm_end_false:
	movl $0, %eax
	ret 
