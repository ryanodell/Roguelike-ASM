; Vim notes: Undo: 'u' redo: 'ctrl + r'
;	     copy: select '"+y"
; Tmux notes: 'ctrl+b "' open terminal. ctrl+b arrow key to change. ctrl+d to close
;	      'ctrl+b'	alt + arrow key to shrink or grow
; MACROS
;
%define PLAYER_NAME_LEN	16

global _start			; Entry Point

;
; CONSTANTS
;
SYS_WRITE	equ	1
SYS_EXIT	equ	60
SYS_READ	equ	0
STDOUT		equ	1
STDIN		equ	0


;
; INIT DATA
;
SECTION .data
	welcome_message		db	"Welcome, to the game", 10		; char*
	welcome_message_len	equ	$-welcome_message			; size_t

	ask_name_message	db	"Tell me hero, what is your name? "	; char*
	ask_name_message_len	equ	$-ask_name_message			; size_t

	msg_prefix		db	"Very well, ", 0
	msg_prefix_len		equ	$-msg_prefix

	msg_suffix		db	", tell me what class you wish to play", 10
	msg_suffix_len		equ	$-msg_suffix

	class_prompt		db	"Choose your class:", 10, "1. Warrior", 10, "2. Mage", 10, "3. Rogue", 10, "> ", 0
	class_prompt_len	equ	$-class_prompt

	invalid_choice		db	"Invalid choice. Try again.", 10
	invalid_choice_len	equ	$-invalid_choice

	class_warrior		db	"Warrior", 0
	class_warrior_len	equ	$-class_warrior
	class_mage		db	"Mage", 0
	class_mage_len		equ	$-class_mage
	class_rogue		db	"Rogue", 0
	class_rogue_len		equ	$-class_rogue

	game_begin_mid_pre	db	" the ", 0
	game_begin_mid_pre_len	equ	$-game_begin_mid_pre
	game_begin_suffix	db	", this is where your story begins...", 10
	game_begin_suffix_len	equ	$-game_begin_suffix

;
; RESERVATIONS
;
SECTION .bss
	player_name		resb	PLAYER_NAME_LEN
	response_message	resb	128			; Reserve bytes for full sentence
	player_class		resb	1			; Store 1, 2, or 3
	input_buffer		resb	2			; 2 bytes to read 1 char + newLine
	game_begin_message	resb	200			; Just 200 for now, will tweak this later

;
; CODE
;
SECTION .text

_start:
	mov rax, SYS_WRITE		; Places 1 in the rax register to indicate 'sys_write'
	mov rdi, STDOUT			; File hand 1 for STDOUT
	mov rsi, welcome_message	; Provide the address
	mov rdx, welcome_message_len	; Number of byes (the length of message)
	syscall				; Invoke SYS_WRITE method w/ the parameters

	mov rax, SYS_WRITE		;
	mov rdi, STDOUT			;
	mov rsi, ask_name_message	; Same as previous
	mov rdx, ask_name_message_len	;
	syscall				;

	call _getName			; Call get name method to load into player_name


	mov rdi, response_message	; Put the address of the buffer into rdi. rdi is our 'Destination'
	xor rbx, rbx			; This essentially sets rbx to 0. But it's shorter to encode (machine wise), doesn't require fetching. Basically: Faster
					; We do 0 because this is the number of bytes written, which none have yet.

	; Copy "Very well, " into buffer
	mov rsi, msg_prefix		; Leverage rsi register and store the address
	mov rcx, msg_prefix_len		; Number of bytes we need to copy that _copy will make use of
	call _copy			; Copy the prefix into the buffer

	; Append player_name (up to new line)
	mov rsi, player_name		; move the player_name into rsi (the source)
	call _copy_name_until_newline	; copy player_name into rdi until we find the new line char

	; Append ", tell me what class you wish to play\n"
	mov rsi, msg_suffix		; Move msg_suffix into rsi (the source)
	mov rcx, msg_suffix_len		; Number of bytes we need to copy
	call _copy			; Copy the suffix into the buffer

	; Write the final message
	mov rax, SYS_WRITE		; Same as writing anything to the console, except with the dynamic message built up
	mov rdi, STDOUT			;
	mov rsi, response_message	;
	mov rdx, rbx			; rbx = total length
	syscall

	call _getClass

	call _showGameBeginMessage

	mov rax, SYS_EXIT		; Places 60 in the rax register to indicate 'sys_exit'
	mov rdi, 0			; Exit code 0SECTION .data
	syscall

_showGameBeginMessage:
	push rcx
	mov rdi, game_begin_message	; Our destination
	xor rbx, rbx			; Reset
	mov rsi, player_name
	call _copy_name_until_newline
	
	mov rsi, game_begin_mid_pre
	mov rcx, game_begin_mid_pre_len
	call _copy

	mov al, [player_class]
	cmp al, '1'
	je .copy_warrior
	cmp al, '2'
	je .copy_mage
	cmp al, '3'
	je .copy_rogue

	.copy_warrior:
		mov rsi, class_warrior
		mov rcx, class_warrior_len
		call _copy
		jmp .done_class_copy
	.copy_mage:
		mov rsi, class_mage
		mov rcx, class_mage_len
		call _copy
		jmp .done_class_copy
	.copy_rogue:
		mov rsi, class_rogue
		mov rcx, class_rogue_len
		call _copy
		jmp .done_class_copy

	
	.done_class_copy:
		mov rsi, game_begin_suffix
		mov rcx, game_begin_suffix_len
		call _copy

		mov rax, SYS_WRITE
		mov rdi, STDOUT
		mov rsi, game_begin_message
		mov rdx, rbx
		syscall
		pop rcx
		ret


_getClass:
	.choose_class:
		mov rax, SYS_WRITE
		mov rdi, STDOUT
		mov rsi, class_prompt
		mov rdx, class_prompt_len
		syscall

		mov rax, SYS_READ
		mov rdi, STDIN
		mov rsi, input_buffer
		mov rdx, 2
		syscall

		mov al, [input_buffer]
		cmp al, '1'
		je .store_choice
		cmp al, '2'
		je .store_choice
		cmp al, '3'
		je .store_choice

		; invalid choice
		mov rax, SYS_WRITE
		mov rdi, STDOUT
		mov rsi, invalid_choice
		mov rdx, invalid_choice_len
		syscall
		jmp .choose_class

	.store_choice:
		mov [player_class], al
		ret



_getName:
	mov rax, SYS_READ		; Places 0 in the rax register to indicate 'sys_read'
	mov rdi, STDIN			; File handle 0 for STDIN
	mov rsi, player_name		; Provide the address to read into
	mov rdx, PLAYER_NAME_LEN	; How many bytes to read from the input (can we get this a better way?)
	syscall
	ret

_copy:
	push rcx			; Save rcx on the stack because we'll be modifying it in the loop (preserve for caller)
	.next:
		cmp rcx, 0		; Check if there are any more bytes to copy
		je .done		; If done, jump to .done to restore rcx and return
		mov al, [rsi]		; Load the byte pointed to by rsi (source) into al (lowest byte of rax)
		mov [rdi], al		; Store that byte into the address pointed to by rdi (destination)
		inc rsi			; Advance source pointer by 1 byte
		inc rdi			; Advance destination pointer by 1 byte
		inc rbx			; rbx is tracking the total number of bytes written — update it
		dec rcx			; Decrease byte counter
		jmp .next		; Loop again
	.done:
		pop rcx			; Restore rcx to its original value before the call
		ret			; Return to caller

_copy_name_until_newline:
	mov rcx, PLAYER_NAME_LEN	; Set a maximum name length to avoid over-reading the buffer
	.next_char:
		cmp rcx, 0		; If we’ve reached the limit, stop
		je .done		
		mov al, [rsi]		; Load next byte from player_name (pointed to by rsi)
		cmp al, 10		; Is it a newline character? (ASCII 10). We look for \n (0A in hex) because you hit 'Enter' after typing name
		je .done		; If yes, stop copying — end of name
		mov [rdi], al		; Write byte to destination buffer
		inc rsi			; Move to next byte in source
		inc rdi			; Move to next byte in destination
		inc rbx			; Keep tracking total bytes written
		dec rcx			; Decrement remaining byte count
		jmp .next_char		; Continue loop
	.done:
		ret

