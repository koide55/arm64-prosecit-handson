.text
.global main
.global sum_to_n
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x0, #100
    bl sum_to_n

    mov x1, x0
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

sum_to_n:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, #0
    mov x2, #1

loop:
    cmp x2, x0
    bgt done
    add x1, x1, x2
    add x2, x2, #1
    b loop

done:
    mov x0, x1
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%ld\n"

