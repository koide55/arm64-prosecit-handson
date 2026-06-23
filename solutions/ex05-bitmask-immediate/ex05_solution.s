.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    movz x1, #0xabab
    movk x1, #0xabab, LSL #16
    movk x1, #0xabab, LSL #32
    movk x1, #0xabab, LSL #48

    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%lx\n"

