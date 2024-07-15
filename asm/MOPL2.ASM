.model small
.stack 200h
.386

include mopl2.mac

.data
    buffer_words db 256 dup("$")
    buffer_nums db 256 dup("$")

    text_enter_words db "Fill the list of words (Enter to stop):", 13, 10, "$"
    text_enter_nums db 13, 10, "Fill the list of hex numbers (Enter to stop):", 13, 10, "$"
    crlf db 13, 10, "$"

    is_last_word db ?

.code
    extrn PToBasePrint: near
    extrn PToBasePrintWithDot: near

    mov ax, @data
    mov ds, ax

    lea dx, text_enter_words
    mov ah, 09h
    int 21h

    lea si, buffer_words

words_input_loop:
    mov ah, 01h
    int 21h

    cmp al, 0Dh
    je print_ordered_words

    mov [si], al
    inc si
    jmp words_input_loop

print_ordered_words:
    xor cx, cx
    lea si, buffer_words

loop_print_ordered_words:
    MPutCrlf

    inc cx
    push cx
    MToBaseWithDot cx, 10
    pop cx

loop_print_word:
    mov dl, [si]
    inc si
    cmp dl, '$'
    je end_loop_print_word
    cmp dl, ' '
    je loop_print_ordered_words

    mov ah, 02h
    int 21h
    jmp loop_print_word

end_loop_print_word:
    MPutCrlf

    lea dx, text_enter_nums
    mov ah, 09h
    int 21h

    lea si, buffer_nums

hex_input_loop:
    mov ah, 01h
    int 21h

    cmp al, 0Dh
    je parse_nums

    mov [si], al
    inc si
    jmp hex_input_loop

parse_nums:
    xor cx, cx
    xor bx, bx
    lea si, buffer_nums

convert_hex:
    mov al, [si]
    inc si
    cmp al, ' '
    je not_last_word
    cmp al, '$'
    je last_word

    cmp al, '0'
    jl convert_hex
    sub al, '0'
    shl cx, 4
    cmp al, 9
    jle handle_decimal
    sub al, 39 ; a-f

handle_decimal:
    mov ah, 0
    add cx, ax
    jmp convert_hex

not_last_word:
    mov is_last_word, 0
    jmp print_ordered_words_oct

last_word:
    mov is_last_word, 1

print_ordered_words_oct:
    push cx
    MToBaseWithDot cx, 8
    pop cx

    mov bx, 1
    lea di, buffer_words

find_word_by_num:
    cmp bx, cx
    je print_found_word

    mov al, [di]
    cmp is_last_word, 1
    je is_last_word_check
    cmp is_last_word, 0
    je is_not_last_check

is_last_word_check:
    cmp al, '$'
    je exit

is_not_last_check:
    cmp al, '$'
    je convert_hex

    cmp al, ' '
    je next_word
    
    inc di
    jmp find_word_by_num

next_word:
    inc bx
    inc di
    jmp find_word_by_num

print_found_word:
    mov dl, [di]
    cmp dl, ' '
    je end_print_found
    mov ah, 02h
    int 21h

    inc di
    jmp print_found_word

end_print_found:
    MPutCrlf

    xor cx, cx
    cmp is_last_word, 0
    je convert_hex

exit:
    mov ax, 4c00h
    int 21h
end
