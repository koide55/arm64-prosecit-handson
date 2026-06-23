.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, #0
    mov x2, #1

loop:
    cmp x2, #10
    bgt done
    add x1, x1, x2
    add x2, x2, #1
    b loop

done:
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "sum(1..10) = %ld\n"

