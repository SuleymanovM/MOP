.model small
.stack 400h
.386

.data
    crlf db 13, 10, "$"
    input_message db "Enter up to 20 fractional numbers in octal form (ESC to stop):", 13, 10, "$"
    converted_message db 13, 10, "Converted to decimal form: $"
    input_i db "Enter segment start index: $"
    input_j db 13, 10, "Enter segment end index: $"

    buffer_float_pair struc
        buffer_first db 12 dup('$')
        buffer_second db 11 dup('$')
        len_buf_first db 0
    buffer_float_pair ends

    float_pair struc
        first dd 0
        second dd 0
        joint dd 0
    float_pair ends

    buffer_i db "0$$"
    buffer_j db "0$$"
    i dw 0
    j dw 0

    fdiv_op1 dd 1
    fdiv_op2 dd ?
    fdiv_index dd ?

    entries_left dw 1
    total_entries dw 0

    buffer_floats buffer_float_pair 20 dup(<>)
    floats float_pair 20 dup(<>)

.code
    extrn outfloat: near

    mov ax, @data
    mov ds, ax

    finit

    lea dx, input_message
    mov ah, 09h
    int 21h

    xor cx, cx
    lea bx, buffer_floats
    lea si, [bx].buffer_first

float_start_input_loop:
    cmp entries_left, 20
    je float_input_loop_end

    mov ah, 07h
    int 21h

    cmp al, 1Bh
    je float_input_loop_end

    cmp al, 0Dh
    je next_float

    cmp al, '.'
    je dot

    inc ch

    mov [si], al
    inc si

    mov dl, al
    mov ah, 02h
    int 21h

    jmp float_start_input_loop

dot:
    mov dl, '.'
    mov ah, 02h
    int 21h

    mov [bx].len_buf_first, ch

    lea si, [bx].buffer_second
    jmp float_start_input_loop

next_float:
    lea dx, crlf
    mov ah, 09h
    int 21h

    add bx, type buffer_float_pair
    inc entries_left
    xor ch, ch
    lea si, [bx].buffer_first
    jmp float_start_input_loop

float_input_loop_end:
    mov dx, entries_left
    mov total_entries, dx

    lea dx, crlf
    mov ah, 09h
    int 21h

    lea dx, crlf
    mov ah, 09h
    int 21h

float_convert_loop:
    lea si, buffer_floats
    lea di, floats

next_float_conversion:
    lea bx, [si].buffer_first

float_int_part_loop:
    dec [si].len_buf_first ; index

    mov dl, [bx]

    cmp dl, '$'
    je float_decimal_part_loop

    sub dl, '0' ; number as multiplier

    cmp [si].len_buf_first, 0 ; handle 8^index (where index == 0)
    je add_index_only

    xor ax, ax
    mov al, [si].len_buf_first ; (3*index)
    mov cx, 3
    imul cx, ax
    mov ax, 1
    shl ax, cl ; 2^(3*index)

    imul eax, edx ; (number as multiplier) * (2^(3*index))
    add [di].first, eax

    inc bx
    jmp float_int_part_loop

add_index_only:
    add [di].first, edx
    lea bx, [si].buffer_second

    mov ax, 1 ; index

float_decimal_part_loop:
    xor dx, dx
    mov dl, [bx]

    cmp dl, '$'
    je join_parts

    sub dl, '0' ; number as multiplier

    mov cx, 3
    imul cx, ax ; (3*index)
    push ax
    mov ax, 1
    shl eax, cl ; 2^(3*index)
    mov fdiv_op2, eax

    fld dword ptr [fdiv_op1]
    fld dword ptr [fdiv_op2]
    fdiv
    mov fdiv_index, edx ; look for dl
    fimul dword ptr [fdiv_index]
    fld dword ptr [di].second
    faddp
    fstp dword ptr [di].second

    pop ax
    inc ax

    inc bx
    jmp float_decimal_part_loop

join_parts:
    fild dword ptr [di].first
    fld dword ptr [di].second
    faddp
    fstp dword ptr [di].joint
    fld dword ptr [di].joint

;===================================
    ;call outfloat
    ;lea dx, crlf
    ;mov ah, 09h
    ;int 21h
;===================================
    
    add si, type buffer_float_pair
    add di, type float_pair
    dec entries_left

    cmp entries_left, 0
    jg next_float_conversion

seg_inputs:
;===================================
    ;lea dx, crlf
    ;mov ah, 09h
    ;int 21h
;===================================
    lea dx, input_i
    mov ah, 09h
    int 21h

    lea si, buffer_i
    
seg_start_input_loop:
    mov ah, 07h
    int 21h

    cmp al, 0Dh
    je seg_start_input_loop_end

    mov [si], al
    inc si

    mov dl, al
    mov ah, 02h
    int 21h

    jmp seg_start_input_loop

seg_start_input_loop_end:
    lea si, buffer_i
    mov ax, 0
    xor dx, dx

convert_buf_i:
    mov dl, [si]

    cmp dl, '$'
    je save_resi

    imul ax, 10
    sub dl, '0'
    add ax, dx

    inc si

    jmp convert_buf_i

save_resi:
    mov i, ax

    lea dx, input_j
    mov ah, 09h
    int 21h

    lea si, buffer_j
    
seg_end_input_loop:
    mov ah, 07h
    int 21h

    cmp al, 0Dh
    je seg_end_input_loop_end

    mov [si], al
    inc si

    mov dl, al
    mov ah, 02h
    int 21h

    jmp seg_end_input_loop

seg_end_input_loop_end:
    lea si, buffer_j
    mov ax, 0
    xor dx, dx

convert_buf_j:
    mov dl, [si]

    cmp dl, '$'
    je save_resj

    imul ax, 10
    sub dl, '0'
    add ax, dx

    inc si

    jmp convert_buf_j

save_resj:
    mov j, ax

    lea dx, crlf
    mov ah, 09h
    int 21h

sort_array:
    mov cx, j
    dec cx

outer_loop:
    push cx

    mov ax, j
    sub ax, cx
    mov cx, j
    sub cx, ax

    lea di, floats
    mov bx, i
    imul bx, type float_pair
    add di, bx

inner_loop:
    fld dword ptr [di].joint
    fld dword ptr [di + type float_pair].joint
    fcom
    fstsw ax
    sahf
    ja continue_inner_loop

    fstp dword ptr [di].joint
    fstp dword ptr [di + type float_pair].joint

continue_inner_loop:
    add di, type float_pair
    loop inner_loop

continue_loop:
    pop cx
    loop outer_loop

print_out_seg:
    mov ax, i
    mov bx, j

    cmp ax, bx
    jg ax_more
    jmp do_print

ax_more:
    xchg ax, bx

do_print:
    lea si, floats

    mov cx, bx
    sub cx, ax
    inc cx

    imul ax, type float_pair
    add si, ax

do_print_loop:
    fld dword ptr [si].joint

    fxtract
    call outfloat

    mov dl, 'P'
    mov ah, 02h
    int 21h

    call outfloat

    lea dx, crlf
    mov ah, 09h
    int 21h

    add si, type float_pair
    loop do_print_loop

exit:
    ffree
    mov ax, 4c00h
    int 21h
end
