.section .data

.section .text

.globl print_func
.type print_func, @function
# Prints given line
print_func:
	.equ FIRST_ARG, 4
	.equ SECOND_ARG, 8

	movl $STDOUT, %ebx
	movl FIRST_ARG(%esp), %ecx 		# line to print
	movl SECOND_ARG(%esp), %edx		# len of the line to print
	movl $SYS_WRITE, %eax
	int $LINUX_SYSCALL

	ret


.globl scan_func
.type scan_func, @function
# Scans users input
# and store it in the given buffer
scan_func:
	.equ FIRST_ARG, 4
	.equ SECOND_ARG, 8

	movl $STDIN, %ebx
	movl FIRST_ARG(%esp), %ecx 		# buffer to store scaned string
	movl SECOND_ARG(%esp), %edx		# len of the buffer
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	ret


.globl cpy_str
.type cpy_str, @function
# Copy string from source buffer to copy_buffer untill `\0` will be found
# `\0` will be in the end of the copy_buffer

# %edx stores address of the symbol in source buffer
# %ecx stores addres of the symbol in the copy_buffer
cpy_str:
	.equ TO, 4
	.equ FROM, 8

	movl FROM(%esp), %edx
	movl TO(%esp), %ecx

	jmp cpy_loop

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


.globl cmp_str
.type cmp_str, @function
# Compears two lines

# Mode 0: excact, untill `\0`
# Mode 1: excact untill `\0` in line comparing with, if
# anything else in line to compare, it is still OK

# %edx stores line to compare
# %ecx stores line comparing with (must end by `\0`)
# %esi stores mode of comparing
# %edi stores answer

# returnes 1 if equal (due the mode), 0 if not
cmp_str:
	.equ LINE_TO_COMPARE, 4
	.equ LINE_COMPARING_WITH, 8
	.equ MODE, 12

	movl LINE_TO_COMPARE(%esp), %edx
	movl LINE_COMPARING_WITH(%esp), %ecx
	movl MODE(%esp), %esi
	movl $0, %edi

	jmp cmp_loop

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


.globl power_func
.type power_func, @function
# First parameter from the stack is number_given
# Second parameter from the stack is power_given

# %esi stores power_given
# %ecx stores number_given
# %edi stores answer

# Returns number_given in power of power_given
power_func:
	movl 8(%esp), %esi
	movl 4(%esp), %ecx
	movl $1, %edi

	jmp power_loop

power_loop:
	# If power_given <= 0 -> break
	cmpl $0, %esi
	jle power_end

	# While power_given >= 1 do
	movl %edi, %eax
	mul %ecx
	movl %eax, %edi

	dec %esi
	jmp power_loop

power_end:
	movl %edi, %eax
	ret
