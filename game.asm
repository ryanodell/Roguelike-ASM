%include "constants.inc"
%include "macros.inc"

section .data
	message		db 	"Hello", 10
	message_len	equ	$-message


section .text
	global _start

_start:
	; mov rax, message
	print message
	
	mov rax, 123
	call _printRAX	
	exit

_printRAX:
	mov rcx, digitSpace
	mov rbx, 10
	mov [rcx], rbx
	inc rcx
	mov [digitSpacePos], rcx

_printRAXLoop:
	mov rdx, 0
	mov rbx, 10
	div rbx				; divide so we can get the remainder
	push rax
	add rdx, 48			; Needed to convert it to ASCII

	mov rcx, [digitSpacePos]
	mov [rcx], dl			; dl = lower 8 bytes of rdx?
	inc rcx
	mov [digitSpacePos], rcx

	pop rax
	cmp rax, 0			; Go until the remainder is 0
	jne _printRAXLoop

_printRAXLoop2:
	mov rcx, [digitSpacePos]
	mov rax, 1
	mov rdi, 1
	mov rsi, rcx
	mov rdx, 1
	syscall

	mov rcx, [digitSpacePos]
	dec rcx
	mov [digitSpacePos], rcx

	cmp rcx, digitSpace
	jge _printRAXLoop2

	ret
