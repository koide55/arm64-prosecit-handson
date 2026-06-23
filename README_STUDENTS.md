# 学生向け手順

この演習では ARM64 の小さなアセンブリプログラムを書き、ビルドし、GDB で1命令ずつ実行します。

## 準備

Linux ARM64 環境で作業してください。講師から SSH 先が配られている場合は、その環境にログインします。Docker を使う場合は次のコマンドでコンテナに入ります。

```bash
docker compose run --rm handson
```

必要なツール:

- `gcc`
- `gdb`
- `make`
- エディタ: `vim`、`nano`、`emacs` など

## 基本コマンド

すべてのサンプルをビルド:

```bash
make all
```

実行:

```bash
make run-first
make run-add1
make run-hello
make run-sum100
```

GDB:

```bash
gdb build/add1
```

GDB 内でよく使うコマンド:

```gdb
break main
run
info registers
print $x0
stepi
cont
finish
quit
```

## 提出物

各演習ディレクトリには `code_example.s` があります。まずそのままビルド・実行し、GDB で観察してから自分のコードへ改造してください。

演習ごとに、次の内容を短くまとめて提出してください。

- 実行したコマンド
- 実行結果
- GDB で観察したレジスタの変化
- 書き換えたコード
- そのコードが何をしているかの説明

## 注意

- 終了ステータスは `echo $?` で確認できます。
- `main` の戻り値は `w0` / `x0` に入ります。
- `main(int argc, char **argv)` の `argc` は `w0` / `x0` に入ります。
- 関数呼び出しでは、戻りアドレスが `x30` に入ります。
- AArch64 ではスタックポインタ `sp` を16バイト境界にそろえます。
