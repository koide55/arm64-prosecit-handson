# ARM64 チートシート

## レジスタ

| 名前 | 用途 |
| --- | --- |
| `x0` - `x7` | 関数引数、戻り値 |
| `w0` - `w7` | `x0` - `x7` の下位32ビット |
| `x29` | フレームポインタ |
| `x30` | リンクレジスタ、戻りアドレス |
| `sp` | スタックポインタ |
| `xzr` / `wzr` | ゼロレジスタ |

## よく使う命令

```asm
mov  x0, #1
add  x0, x1, x2
add  x0, x1, #10
sub  x0, x1, #10
cmp  x0, #100
bgt  label
b    label
bl   puts
ret
```

## 関数の形

```asm
.text
.global main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // 関数本体

    ldp x29, x30, [sp], #16
    ret
```

## `printf` の呼び出し

```asm
    mov x1, #5050
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

.section .rodata
fmt:
    .asciz "%ld\n"
```

## GDB

```gdb
break main
run
info registers
print $x0
print $w0
stepi
cont
finish
disassemble /m main
```

## 即値

- `add` / `sub` の即値は基本的に12ビットです。
- `add x1, x2, #0xabc, LSL #12` のように12ビット左シフトした即値も使えます。
- 大きな値は `movz` と `movk` を組み合わせます。
- 論理命令の即値は任意のビット列ではなく、繰り返しパターンとして表現できる値に限られます。

