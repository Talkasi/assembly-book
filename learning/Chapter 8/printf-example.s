#PURPOSE: This program is to demonstrate how to call printf
#

.section .data

#This string is called the format string. It's the first parameter,
#and printf uses it to find out how many parameters it was given, 
#and what kind the are.
first_string:
	.ascii "Hi. %s is an %s number %d\n\0"

first_arg:
	.ascii "This\0"

second_arg:
	.ascii "experiment\0"

third_arg:
	.long 83

.section .text
.globl _start 
_start:
	pushl third_arg
	pushl $second_arg
	pushl $first_arg
	pushl $first_string

	call printf
	pushl $0
	call exit

