.model small
.386

.code
    outfloat proc near
        push ax
        push cx
        push dx

        push bp
        mov bp, sp
        push 10
        push 0

        ftst
        fstsw ax
        sahf
        jnc @of1

        mov ah, 02h
        mov dl, '-'
        int 21h

        fchs

        @of1:
            fld1
            fld st(1)

            fprem

            fsub st(2), st
            fxch st(2)

            xor cx, cx

        @of2:
            fidiv word ptr [bp-2]
            fxch st(1)
            fld st(1)

            fprem

            fsub st(2), st

            fimul word ptr [bp-2]
            fistp word ptr [bp-4]
            inc cx

            push word ptr [bp-4]
            fxch st(1)

            ftst
            fstsw ax
            sahf
            jnz short @of2

            mov ah, 02h
        @of3:
            pop dx

            add dl, 30h
            int 21h

            loop @of3

            fstp st(0)
            fxch st(1)
            ftst
            fstsw ax
            sahf
            jz short @of5

            mov ah, 02h
            mov dl, '.'
            int 21h

            mov cx, 6

        @of4:
            fimul word ptr [bp-2]
            fxch st(1)
            fld st(1)

            fprem

            fsub st(2), st
            fxch st(2)

            fistp word ptr [bp-4]

            mov ah, 02h
            mov dl, [bp-4]
            add dl, 30h
            int 21h

            fxch st(1)
            ftst
            fstsw ax
            sahf

            loopnz @of4

        @of5:
            fstp st(0)
            fstp st(0)

        leave
        pop     dx
        pop     cx
        pop     ax

        ret
    outfloat endp

    public outfloat
end
