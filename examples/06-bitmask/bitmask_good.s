.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    orr x1, xzr, #0x1010101010101010

    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%lx\n"

