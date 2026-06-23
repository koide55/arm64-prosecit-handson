.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, #0
    mov x2, #1

loop:
    cmp x2, #100
    bgt end
    add x1, x1, x2
    add x2, x2, #1
    b loop

end:
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%ld\n"

