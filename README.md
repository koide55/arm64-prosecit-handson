# 機械語で遊ぼう ARM64 ハンズオン教材

このリポジトリは、スライド `slides/arm64-prosecit-20250727.pdf` に沿って ARM64/AArch64 の機械語・アセンブリを体験するための教材です。

学生はサンプルを入力・ビルド・実行し、GDB でレジスタの変化を観察します。最後に自分で小さな ARM64 プログラムを書き、命令とレジスタの使い方を説明します。

## 構成

- `slides/`: 元スライド PDF
- `examples/`: スライドの内容に対応する実行可能なサンプル
- `exercises/`: 学生向け演習
- `solutions/`: 追加演習の参考解答
- `docs/`: 講師用ガイドとチートシート
- `scripts/`: 教材構成と実行例の検証スクリプト

## 演習一覧

| No. | 内容 | 目安 |
| --- | --- | --- |
| ex01 | `first.s` を GDB でステップ実行し、戻り値を観察する | 10分 |
| ex02 | `add` / `sub` と複数レジスタを使って計算を変える | 15分 |
| ex03 | オリジナルの ARM64 プログラムを作り、動作を説明する | 20分 |
| ex04 | 追加演習: 大きな即値を `movz` / `movk` でロードする | 15分 |
| ex05 | 追加演習: bitmask immediate の通る値・通らない値を調べる | 15分 |
| ex06 | 追加演習: 関数呼び出し、プロローグ、エピローグを観察する | 20分 |

## 実行環境

推奨環境は Linux ARM64 です。次のどちらかを使ってください。

1. 講師が用意した ARM64 Linux 環境へ SSH する
2. Apple Silicon Mac などで Docker Desktop を使い、Linux ARM64 コンテナを起動する

Docker を使う場合:

```bash
docker compose build
docker compose run --rm handson
```

コンテナ内で:

```bash
make all
make run-first
make run-add1
make run-hello
make run-sum100
```

GDB を使う例:

```bash
make gdb-add1
```

## 最初の進め方

1. `README_STUDENTS.md` を読む
2. スライド 6-12 を見ながら `examples/01-first` から順に動かす
3. `exercises/ex01-debug-first` から演習を進める
4. 時間が余ったら `ex04` から `ex06` の追加演習に取り組む

## 検証

教材ファイルの構成チェック:

```bash
scripts/check-materials.sh
```

Linux ARM64 上でサンプルをビルド・実行するチェック:

```bash
scripts/test-examples.sh
```

