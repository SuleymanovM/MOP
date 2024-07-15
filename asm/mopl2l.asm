.model small
.386

.code
    PToBasePrint proc near
        process_digits:
            xor dx, dx
            div cx
            push dx
            inc bx
            test ax, ax
            jnz process_digits

        print_loop:
            pop dx
            add dl, '0'
            mov ah, 02h
            int 21h
            dec bx
            jnz print_loop

        ret 
    PToBasePrint endp

    PToBasePrintWithDot proc near
        process_digits_dot:
            xor dx, dx
            div cx
            push dx
            inc bx
            test ax, ax
            jnz process_digits_dot

        print_loop_dot:
            pop dx
            add dl, '0'
            mov ah, 02h
            int 21h
            dec bx
            jnz print_loop_dot
        
        mov dl, '.'
        mov ah, 02h
        int 21h

        mov dl, ' '
        mov ah, 02h
        int 21h

        ret
    PToBasePrintWithDot endp

    public PToBasePrint, PToBasePrintWithDot
end
