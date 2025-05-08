section .bss
	digitSpace		resb	100
	digitSpacePos		resb	8
	printSpace		resb	8

%macro print 1
	mov rax, %1
	mov [printSpace], rax
	mov rbx, 0
%%printLoop:
	mov cl, [rax]
	cmp cl, 0
	je %%endPrintLoop
	inc rbx
	inc rax
	jmp %%printLoop
%%endPrintLoop:
	mov rax, SYS_WRITE
	mov rdi, STDIN
	mov rsi, [printSpace]
	mov rdx, rbx
	syscall
%endmacro

%macro exit 0
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall
%endmacro

;
; CONSTANTS
;
SYS_WRITE	equ	1
SYS_EXIT	equ	60
SYS_READ	equ	0
STDOUT		equ	1
STDIN		equ	0
