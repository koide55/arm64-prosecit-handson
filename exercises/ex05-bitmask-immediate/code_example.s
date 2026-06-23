.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // This logical immediate can be encoded directly.
    orr x1, xzr, #0x1010101010101010
    adrp x0, fmt_mask
    add x0, x0, :lo12:fmt_mask
    bl printf

    // This pattern is built with movz/movk instead of a logical immediate.
    movz x1, #0xabab
    movk x1, #0xabab, LSL #16
    movk x1, #0xabab, LSL #32
    movk x1, #0xabab, LSL #48
    adrp x0, fmt_movk
    add x0, x0, :lo12:fmt_movk
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt_mask:
    .asciz "bitmask immediate: 0x%016lx\n"
fmt_movk:
    .asciz "movz/movk value:    0x%016lx\n"

