# ex02: `add` / `sub` と複数レジスタ

## 目的

`argc` が `w0` に入っていることを確認し、`add` / `sub` と複数レジスタを使った計算に書き換えます。

## 手順

```bash
make build/add1
./build/add1
echo $?
./build/add1 a b
echo $?
```

## 課題

`examples/02-add1/add1.s` を参考に、別ファイル `work/ex02.s` を作って次の計算をしてください。

1. `argc + 3` を返す
2. `argc * 2 - 1` と同じ値を `add` と `sub` だけで返す
3. `w1` と `w2` を途中計算に使い、最後に `w0` に戻り値を入れる

## GDB で確認

```gdb
break main
run a b c
info registers
stepi
print $w0
print $w1
print $w2
```

## 提出

- 作成した `work/ex02.s`
- 引数なし、引数2個、引数3個での終了ステータス
- 使ったレジスタと命令の説明

