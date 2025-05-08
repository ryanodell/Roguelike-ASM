%include "macros.inc"

section .data
	message		db 	"Hello"
	message_len	equ	$-message


section .text
	global _start

_start:
	mov rax, message
	print message

	exit
