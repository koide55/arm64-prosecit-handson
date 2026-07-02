# 機械語で遊ぼう ARM64 ハンズオン教材

このリポジトリは、スライド `slides/arm64-prosecit-20250727.pdf` に沿って ARM64/AArch64 の機械語・アセンブリを体験するための教材です。

学生はサンプルを入力・ビルド・実行し、GDB でレジスタの変化を観察します。最後に自分で小さな ARM64 プログラムを書き、命令とレジスタの使い方を説明します。

## 構成

- `slides/`: 元スライド PDF
- `examples/`: スライドの内容に対応する実行可能なサンプル
- `exercises/`: 学生向け演習。各演習に `code_example.s` があります
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

推奨環境は Linux ARM64 です。次のいずれかを使ってください。

1. 講師が用意した ARM64 Linux 環境へ SSH する
2. Apple Silicon Mac などで Docker Desktop を使い、Linux ARM64 コンテナを起動する
3. x64 Windows PC で Docker Desktop を使い、QEMU エミュレーションで Linux ARM64 コンテナを起動する

Docker を使う場合（Mac/Linuxホスト）:

```bash
docker compose build
docker compose run --rm handson
```

### x64 Windows + Docker Desktop の場合

Docker Desktop は QEMU（binfmt_misc）を内蔵しており、x64 PC上でもホストのCPU種別を問わず ARM64 コンテナを透過的にエミュレーション実行できます。クラウド環境を用意しなくても、学生各自の Windows PC だけで完結します。

事前準備:

1. Windows 11（Home/Pro いずれも可）
2. BIOS/UEFI で仮想化支援（Intel VT-x または AMD-V）を有効化
3. [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) をインストールし、WSL 2 backend を有効にする（インストーラーが自動でWSL2を設定する場合が多いです）

PowerShell または WSL のターミナルから、リポジトリのルートで:

```powershell
docker compose build
docker compose run --rm handson
```

初回ビルド時にコンテナ内で ARM64 バイナリが起動しない場合は、QEMU の binfmt ハンドラが未登録の可能性があります。その場合は一度だけ次を実行してください。

```powershell
docker run --privileged --rm tonistiigi/binfmt --install all
```

注意点:

- QEMU エミュレーションのため、ネイティブ実行より体感で数倍遅くなりますが、この教材（数命令〜数十命令の GDB ステップ実行）の範囲では支障ありません。
- コンテナに入った後の操作（`make all` や GDB の使い方）は Mac / Linux ホストの場合と同じです。

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
