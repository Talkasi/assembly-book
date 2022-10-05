.section .data

.section .text

.globl _start
_start:
	pushl $3
	pushl $2
	call power
	addl $8, %esp

	pushl %eax
	
	pushl $0
	pushl $5
	call power
	addl $8, %esp

	popl %ebx
	
	addl %eax, %ebx
	
	movl $1, %eax
	int $0x80 			#sends a signal to a kernel to shut down
	
.type power, @function
power:
	pushl %ebp 			# Push the base pointer to a stack
	movl %esp, %ebp 	# Base pointer saves the current top of the stack
	subl $4, %esp		# Grow the stack with 4 (down)
	
	movl 8(%ebp), %ebx 	
	movl 12(%ebp), %ecx	
	
	movl %ebx, -4(%ebp)	
	
power_loop_start:
	cmpl $1, %ecx
	je end_power
	cmpl $0, %ecx
	je zero_case
	movl -4(%ebp), %eax
	imull %ebx, %eax
	
	movl %eax, -4(%ebp)
	
	decl %ecx
	jmp power_loop_start

zero_case:
	movl $1, -4(%ebp)
	jmp end_power
	
end_power:
	movl -4(%ebp), %eax
	movl %ebp, %esp
	popl %ebp
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

