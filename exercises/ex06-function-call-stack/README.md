# ex06: 追加演習 - 関数呼び出しとスタック

## 目的

`bl`、`ret`、`x29`、`x30`、`sp` の関係を GDB で観察します。

## 課題

このディレクトリの `code_example.s` は、`main` から `sum_to_n` を呼び出す完成例です。まずはそのまま動かし、GDB で `x30` と `sp` を観察してください。

```bash
gcc -g -o /tmp/ex06 code_example.s
/tmp/ex06
gdb /tmp/ex06
```

`work/ex06.s` を作成してください。

条件:

- `main` から `sum_to_n` 関数を呼び出す
- `sum_to_n(100)` が `5050` を返す
- `main` が `printf` で結果を表示する
- `main` と `sum_to_n` の両方にプロローグとエピローグを書く

プロローグ:

```asm
stp x29, x30, [sp, #-16]!
mov x29, sp
```

エピローグ:

```asm
ldp x29, x30, [sp], #16
ret
```

## GDB で確認

```gdb
break main
break sum_to_n
run
info registers x29 x30 sp
stepi
finish
info registers x0 x29 x30 sp
```

## 提出

- ソースコード
- 実行結果
- `bl` の直後に `x30` が何を表しているか
- `finish` 実行後に `x0` が何になっているか
