# 機械語で遊ぼう（ARM64）ハンズオン教材ガイド（現行版）

> **このドキュメントについて**
> 元のスライド `slides/arm64-prosecit-20250727.pdf` は、`ex04`〜`ex06` の追加演習や
> Windows + Docker Desktop 環境などを反映しておらず、現在のリポジトリの内容とは
> ズレがあります。このガイドは、リポジトリの現在の内容（`README.md` /
> `README_STUDENTS.md` / `examples/` / `exercises/` / `solutions/` / `docs/`）を
> もとに、演習に必要な内容をすべて1つのマークダウンにまとめたものです。
> スライドの代わりに、このガイドを教材として使ってください。

## 目次

1. [この教材について](#1-この教材について)
2. [ARM64プロセッサの基礎知識](#2-arm64プロセッサの基礎知識)
3. [実行環境の準備](#3-実行環境の準備)
4. [基本ツールとコマンド](#4-基本ツールとコマンド)
5. [レジスタとABIの基礎](#5-レジスタとabiの基礎)
6. [サンプルプログラム（examples/）](#6-サンプルプログラムexamples)
7. [関数呼び出しとスタック](#7-関数呼び出しとスタック)
8. [即値の制約（算術即値とビットマスク即値）](#8-即値の制約算術即値とビットマスク即値)
9. [GDBでの観察](#9-gdbでの観察)
10. [演習一覧（exercises/）](#10-演習一覧exercises)
11. [参考解答（solutions/）](#11-参考解答solutions)
12. [講師向け情報](#12-講師向け情報)
13. [教材の検証スクリプト](#13-教材の検証スクリプト)
14. [チートシート（総まとめ）](#14-チートシート総まとめ)

---

## 1. この教材について

このリポジトリは、ARM64（AArch64）の機械語・アセンブリを実際に手を動かして体験するための
ハンズオン教材です。学生はサンプルを入力・ビルド・実行し、GDB でレジスタの変化を観察します。
最後に自分で小さな ARM64 プログラムを書き、命令とレジスタの使い方を説明します。

### リポジトリの構成

| ディレクトリ | 内容 |
| --- | --- |
| `slides/` | 元スライド PDF（現状は演習内容と一部ズレあり） |
| `examples/` | 導入で使う、動作確認済みのサンプルプログラム（01〜06） |
| `exercises/` | 学生向け演習（ex01〜ex06）。各演習に `README.md` と `code_example.s` がある |
| `solutions/` | 追加演習（ex04〜ex06）の参考解答 |
| `docs/` | 講師用ガイドとチートシート（本ガイドもここに置かれています） |
| `scripts/` | 教材構成と実行例の検証スクリプト |

### 演習一覧（概要）

| No. | 内容 | 目安時間 |
| --- | --- | --- |
| ex01 | `first.s` を GDB でステップ実行し、戻り値を観察する | 10分 |
| ex02 | `add` / `sub` と複数レジスタを使って計算を変える | 15分 |
| ex03 | オリジナルの ARM64 プログラムを作り、動作を説明する | 20分 |
| ex04 | 追加演習：大きな即値を `movz` / `movk` でロードする | 15分 |
| ex05 | 追加演習：bitmask immediate の通る値・通らない値を調べる | 15分 |
| ex06 | 追加演習：関数呼び出し、プロローグ、エピローグを観察する | 20分 |

### 進め方

1. まず本ガイドの「[3. 実行環境の準備](#3-実行環境の準備)」を読み、環境を用意する
2. 「[6. サンプルプログラム](#6-サンプルプログラムexamples)」を `examples/01-first` から順に動かす
3. `exercises/ex01-debug-first` から演習を進める
4. 時間が余ったら `ex04` から `ex06` の追加演習に取り組む

---

## 2. ARM64プロセッサの基礎知識

演習に入る前に、背景として ARM/ARM64 について簡単に押さえておきます。

- ARM系のプロセッサは非常に多くのデバイスに搭載されており、事実上の業界標準の一つです。
  ARM社自身は製造を行わず、命令セットアーキテクチャの設計とライセンスを提供する立場を取っています。
- スマートフォンや組み込み機器だけでなく、スーパーコンピュータからノートPC（Apple Silicon Mac など）
  まで、幅広い製品で ARM 系のプロセッサが使われています。
- **AArch64（ARMv8以降の64ビット実行状態）** が、本教材で扱う ARM64 です。32ビット時代の
  ARMv7 などとは、レジスタ幅や命令エンコーディングがかなり異なります。
- 機械語（アセンブリ）に触れるために必要な道具は、基本的に次の3つだけです。
  - **GAS**（GNU Assembler）: アセンブリソース (`.s`) を機械語に変換する
  - **GCC**: アセンブリや C のソースをビルドし、実行ファイルを作る（本教材では GAS 経由で `.s` を直接ビルドします）
  - **GDB**: ビルドしたプログラムを1命令ずつ実行し、レジスタやメモリを観察する

これらのツールが動く Linux ARM64 環境さえあれば、クラウドの特別なインスタンスがなくても、
Docker Desktop 経由で手元の PC だけでこの教材を進められます（詳細は次章）。

---

## 3. 実行環境の準備

推奨環境は **Linux ARM64** です。次のいずれかの方法で用意してください。

1. 講師が用意した ARM64 Linux 環境へ SSH する
2. Apple Silicon Mac などで Docker Desktop を使い、Linux ARM64 コンテナを起動する
3. x64 Windows PC で Docker Desktop を使い、QEMU エミュレーションで Linux ARM64 コンテナを起動する

### Docker を使う場合（Mac / Linux ホスト）

```bash
docker compose build
docker compose run --rm handson
```

### x64 Windows + Docker Desktop の場合

Docker Desktop は QEMU（binfmt_misc）を内蔵しており、x64 PC 上でもホストの CPU 種別を問わず
ARM64 コンテナを透過的にエミュレーション実行できます。クラウド環境を用意しなくても、
学生各自の Windows PC だけで完結します。

事前準備:

1. Windows 11（Home / Pro いずれも可）
2. BIOS/UEFI で仮想化支援（Intel VT-x または AMD-V）を有効化
3. [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) をインストールし、
   WSL 2 backend を有効にする（インストーラーが自動で WSL2 を設定する場合が多い）

PowerShell または WSL のターミナルから、リポジトリのルートで:

```powershell
docker compose build
docker compose run --rm handson
```

初回ビルド時にコンテナ内で ARM64 バイナリが起動しない場合は、QEMU の binfmt ハンドラが
未登録の可能性があります。その場合は一度だけ次を実行してください。

```powershell
docker run --privileged --rm tonistiigi/binfmt --install all
```

**注意点:**

- QEMU エミュレーションのため、ネイティブ実行より体感で数倍遅くなりますが、
  この教材（数命令〜数十命令の GDB ステップ実行）の範囲では支障ありません。
- コンテナに入った後の操作（`make all` や GDB の使い方）は Mac / Linux ホストの場合と同じです。

### コンテナの中身（Dockerfile）

コンテナには次のツールがインストールされています。

```
build-essential  ca-certificates  file  gdb  less  make  nano  vim
```

### コンテナに入った後

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

---

## 4. 基本ツールとコマンド

必要なツール:

- `gcc`
- `gdb`
- `make`
- エディタ: `vim`、`nano`、`emacs` など

### すべてのサンプルをビルド

```bash
make all
```

### 実行

```bash
make run-first
make run-add1
make run-hello
make run-sum100
```

### GDB の起動

```bash
gdb build/add1
```

### GDB 内でよく使うコマンド

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

### 演習全体を通じての注意事項

- 終了ステータスは `echo $?` で確認できます。
- `main` の戻り値は `w0` / `x0` に入ります。
- `main(int argc, char **argv)` の `argc` は `w0` / `x0` に入ります（プログラム名自体も1個の引数として数えられます）。
- 関数呼び出しでは、戻りアドレスが `x30` に入ります。
- AArch64 ではスタックポインタ `sp` を16バイト境界にそろえます。

### 提出物の基本フォーマット

各演習ディレクトリには `code_example.s` があります。まずそのままビルド・実行し、
GDB で観察してから自分のコードへ改造してください。演習ごとに、次の内容を短くまとめて
提出します。

- 実行したコマンド
- 実行結果
- GDB で観察したレジスタの変化
- 書き換えたコード
- そのコードが何をしているかの説明

---

## 5. レジスタとABIの基礎

| 名前 | 用途 |
| --- | --- |
| `x0` - `x7` | 関数引数、戻り値 |
| `w0` - `w7` | `x0` - `x7` の下位32ビット |
| `x29` | フレームポインタ |
| `x30` | リンクレジスタ、戻りアドレス |
| `sp` | スタックポインタ |
| `xzr` / `wzr` | ゼロレジスタ（読むと常に0、書き込みは捨てられる） |

### よく使う命令

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

### 関数の基本形（プロローグ／エピローグ）

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

### `printf` の呼び出し方

```asm
    mov x1, #5050
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

.section .rodata
fmt:
    .asciz "%ld\n"
```

`x0` にフォーマット文字列のアドレス、`x1` に表示したい値を入れてから `bl printf` を
呼び出す、という順番を間違えないようにしてください。

---

## 6. サンプルプログラム（examples/）

導入として、次の6つのサンプルを順番に動かします。それぞれ `make all` でまとめてビルドできます。

### 6.1 `examples/01-first/first.s` — 最初の機械語

```asm
.text
.global main

main:
    mov w0, #2
    ret
```

実行:

```bash
gcc -static -o first first.s
./first
echo $?
```

`mov w0, #2` で `w0` に `2` を入れて `ret` するだけのプログラムです。`main` の戻り値が
シェルの終了ステータスになるため、`echo $?` で `2` が表示されることを確認します。

### 6.2 `examples/02-add1/add1.s` — 足し算してみる

```asm
.text
.global main

main:
    add w0, w0, #1
    ret
```

実行:

```bash
gcc -g -o add1 add1.s
./add1
echo $?
./add1 a b
echo $?
```

`main(int argc, char **argv)` が呼ばれる時点で、`argc`（コマンドライン引数の個数、
プログラム名を含む）が `w0` に入っています。ここに `1` を足して返すため、引数なしなら
`2`、引数を2つ渡すと `argc` が `3` になり `4` が返ります。

### 6.3 `examples/03-hello/a002.s` — `puts` の呼び出し

```asm
.text
.global main
.extern puts

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adrp x0, hello
    add x0, x0, :lo12:hello
    bl puts

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
hello:
    .asciz "Hello, world!"
```

実行:

```bash
gcc -g a002.s -o a002
./a002
```

`puts` のような外部関数（C ライブラリの関数）を呼ぶ最初の例です。`adrp` + `add …
:lo12:` の組み合わせで、`.rodata` に置いた文字列 `hello` のアドレスを `x0` に作り、
`bl puts` で呼び出します。関数を呼ぶ前後で `stp` / `ldp` によるプロローグ・エピローグが
必要になる点にも注目してください（詳細は次章）。

### 6.4 `examples/04-sum100/sum100.s` — 1から100まで足す

```asm
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
```

実行結果は `5050` です。`x1` が合計、`x2` がカウンタとして使われ、`cmp` + `bgt` による
条件分岐でループを抜けます。GDB で `x1` / `x2` の変化をステップ実行しながら観察するのに
向いた例です。

### 6.5 `examples/05-large-immediate/load_imm.s` — 大きな即値のロード

```asm
.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    movz x1, #0xabcd
    movk x1, #0x1234, LSL #16

    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%lx\n"
```

実行結果は `1234abcd` です。ARM64 の1命令が保持できる即値の幅には限りがあるため、
`0x1234abcd` のような32ビット値をそのまま `mov` に入れることはできません。
`movz`（ゼロクリアしてロード）で下位16ビットを、`movk`（該当ビット位置だけ書き換え）で
上位16ビットを組み立てています。詳しくは「[8. 即値の制約](#8-即値の制約算術即値とビットマスク即値)」で扱います。

### 6.6 `examples/06-bitmask/bitmask_good.s` — 論理即値（bitmask immediate）

```asm
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
```

実行結果は `1010101010101010` です。`orr x1, xzr, #値` は「`xzr`（常に0）と値を OR
する」＝「`x1` に値をそのまま入れる」という定番のイディオムです。ただし、この `#値`
は任意のビットパターンを指定できるわけではなく、**bitmask immediate** と呼ばれる
制約のある値だけが使えます（詳細は次々章）。

### ビルド・実行のまとめ（Makefile 経由）

```bash
make all
make run-first      # -> exit=2
make run-add1       # -> 引数なし: exit=2 / a b: exit=4
make run-hello      # -> Hello, world!
make run-sum100     # -> 5050
make run-load-imm   # -> 1234abcd
make run-bitmask    # -> 1010101010101010
```

---

## 7. 関数呼び出しとスタック

`examples/03-hello` 以降のサンプルには、次のプロローグ・エピローグが登場します。

**プロローグ（呼び出し準備）**

```asm
stp x29, x30, [sp, #-16]!
```

- `STP`：`x29` と `x30` を同時にメモリへ保存（Store Pair）
- `x29`：フレームポインタ、`x30`：戻りアドレス（リンクレジスタ）
- `[sp, #-16]!`：プリデクリメントアドレッシング。`sp` を16減らしてから、そこに保存する

**エピローグ（後始末）**

```asm
ldp x29, x30, [sp], #16
```

- `LDP`：`x29` と `x30` を同時にメモリからロード（Load Pair）
- `[sp], #16`：ポストインクリメントアドレッシング。`[sp]` の位置からロードしたあとで、
  `sp` に +16 する

自分で関数（`bl` で呼ばれるサブルーチン）を書くときは、`main` だけでなく、
呼び出された側の関数にもこのプロローグ・エピローグを書く必要があります
（`exercises/ex06-function-call-stack` で実際に扱います）。

`bl label` を実行すると、次の命令のアドレスが自動的に `x30` に入ります。
呼ばれた側は最後に `ret` を実行すると、`x30` の指すアドレスに戻ります。

---

## 8. 即値の制約（算術即値とビットマスク即値）

ARM64 は固定長（32ビット）の命令セットのため、命令の中に埋め込める即値の幅には
命令の種類ごとに制限があります。

### 8.1 算術命令の即値（ADD / SUB）

```asm
add x2, x0, #0xdef
add x1, x2, #0xabc, LSL #12
```

- 即値の範囲は基本的に **12ビット**（0〜4095）です。
- `LSL #12` を付けることで、12ビット左シフトした即値も指定できます
  （4096刻みの大きな値を1命令で作れる）。
- これを超える任意の値をレジスタに入れたい場合は、`movz` / `movk` を組み合わせます。

### 8.2 大きな即値のロード（`movz` / `movk`）

64ビットレジスタ `Xn` は0〜63、32ビットレジスタ `Wn` は0〜31の範囲でシフト演算を
行えます。

```asm
reg, LSL, #amount
reg, LSR, #amount
reg, ASR, #amount
reg, ROR, #amount
```

`movz`（Move Zero）は指定した16ビット位置以外をゼロにしてロードし、`movk`
（Move Keep）は指定した16ビット位置だけを書き換え、他のビットはそのまま保持します。
16ビットずつ、`LSL #0 / #16 / #32 / #48` の位置を指定しながら組み立てることで、
任意の64ビット値を作れます。

```asm
movz x1, #0xabcd            ; x1 = 0x000000000000abcd
movk x1, #0x1234, LSL #16   ; x1 = 0x000000001234abcd
```

### 8.3 論理命令の即値（bitmask immediate）

`AND` / `ORR` / `EOR` / `ANDS` などの論理命令の即値は、任意のビット列を自由に
指定できるわけではありません。ARM64 の bitmask immediate は、**特定の長さの
ビットパターンの繰り返しと回転**で表現できる値に限られます。

64ビット命令の場合、内部的には次の3つの値の組み合わせ（`N:immr:imms`）で
エンコードされます。

| 要素 | 意味 |
| --- | --- |
| `N` | パターン長を決めるビット（1ビット幅、32ビット命令か64ビット命令かに関係） |
| `immr` | 回転量（6ビット） |
| `imms` | マスクビットサイズ（6ビット） |

つまり「同じビットパターンを一定周期で繰り返し、それを回転させたもの」しか
即値として直接埋め込めない、という制約です。

**うまくいくパターンの例**（`orr x1, xzr, #値` がアセンブルできる）:

- `0xff00ff00ff00ff00`
- `0xff0000ffff0000ff`
- `0x1010101010101010`

**ダメなパターンの例**（アセンブルエラーになる）:

- `0xabababababababab`
- `0x1100110011001100`

通らない値をレジスタに入れたい場合は、8.2 で説明した `movz` / `movk` を
16ビットずつ組み合わせてロードします。

```asm
movz x1, #0xabab
movk x1, #0xabab, LSL #16
movk x1, #0xabab, LSL #32
movk x1, #0xabab, LSL #48
```

この違いを実際に手を動かして確認するのが `exercises/ex05-bitmask-immediate` です。

---

## 9. GDBでの観察

本教材で使う GDB コマンド一覧です。

```gdb
break main            ; ラベル main にブレークポイントを設定（b main でも可）
run                    ; プログラムを実行（run a b c のように引数も渡せる）
info registers         ; すべてのレジスタの値を確認
print $x0              ; x0 レジスタの値を確認（$w0、$x1 なども同様）
stepi                  ; 1命令だけ実行する（si でも可）
b 11 if $x2==95        ; 11行目でレジスタ x2 が95になったらブレーク、という条件付きブレークポイントも可能
cont                   ; 次のブレークポイントまで実行
finish                 ; 現在の関数を抜けるまで実行
disassemble /m main    ; main 関数を逆アセンブルして表示
quit                   ; GDB を終了
```

典型的な使い方の流れ：

```bash
gdb build/add1
```

```gdb
break main
run
info registers
stepi
print $w0
stepi
quit
```

`print $w0` と `print $x0` の表示の違い（32ビットとして見るか64ビットとして見るか）も
実際に確認してみてください。

---

## 10. 演習一覧（exercises/）

各演習ディレクトリには `README.md` と `code_example.s` があります。まずは
`code_example.s` をそのままビルド・実行し、GDB で観察してから、指示された課題に
取り組んでください。

### ex01: `first.s` をステップ実行する（`exercises/ex01-debug-first`）

**目的**：`main` の戻り値が `w0` に置かれることを GDB で確認します。

```asm
.text
.global main

main:
    mov w0, #2
    ret
```

手順:

```bash
gcc -g -o /tmp/ex01 code_example.s
/tmp/ex01
echo $?
```

`examples/01-first/first.s` を使う場合は、リポジトリのルートで次を実行します。

```bash
make build/first
gdb build/first
```

GDB 内:

```gdb
break main
run
disassemble /m main
info registers
stepi
print $w0
stepi
quit
```

通常実行:

```bash
./build/first
echo $?
```

確認すること:

- `mov w0, #2` の実行前後で `w0` がどう変わるか
- `ret` のあと、シェルで見える終了ステータスはいくつか
- `w0` と `x0` の表示はどう違うか

**提出**：GDB の観察結果を3行程度で説明してください。

---

### ex02: `add` / `sub` と複数レジスタ（`exercises/ex02-add-sub-registers`）

**目的**：`argc` が `w0` に入っていることを確認し、`add` / `sub` と複数レジスタを
使った計算に書き換えます。

```asm
.text
.global main

main:
    mov w1, w0
    add w2, w1, w1
    sub w0, w2, #1
    ret
```

`code_example.s` は `argc * 2 - 1` を `add` と `sub` で計算する例です。

```bash
gcc -g -o /tmp/ex02 code_example.s
/tmp/ex02
echo $?
/tmp/ex02 a b
echo $?
```

ビルド済みサンプル `add1` で `argc + 1` を見る場合は、リポジトリのルートで次を実行します。

```bash
make build/add1
./build/add1
echo $?
./build/add1 a b
echo $?
```

**課題**：`examples/02-add1/add1.s` を参考に、別ファイル `work/ex02.s` を作って
次の計算をしてください。

1. `argc + 3` を返す
2. `argc * 2 - 1` と同じ値を `add` と `sub` だけで返す
3. `w1` と `w2` を途中計算に使い、最後に `w0` に戻り値を入れる

GDB で確認:

```gdb
break main
run a b c
info registers
stepi
print $w0
print $w1
print $w2
```

**提出**：

- 作成した `work/ex02.s`
- 引数なし、引数2個、引数3個での終了ステータス
- 使ったレジスタと命令の説明

---

### ex03: オリジナルの ARM64 プログラム（`exercises/ex03-original-program`）

**目的**：ここまで使った命令を組み合わせ、自分の小さな機械語プログラムを作ります。

```asm
.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, #0
    mov x2, #1

loop:
    cmp x2, #10
    bgt done
    add x1, x1, x2
    add x2, x2, #1
    b loop

done:
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "sum(1..10) = %ld\n"
```

`code_example.s` は、1から10まで足して `printf` で表示する例です（実行結果：
`sum(1..10) = 55`）。

```bash
gcc -g -o /tmp/ex03 code_example.s
/tmp/ex03
```

GDB で `x1` が合計、`x2` がカウンタとして変化する様子を観察できます。

次の条件を満たすプログラムを `work/original.s` として作ってください。

- `gcc -g -o original work/original.s` でビルドできる
- `./original` で実行できる
- 少なくとも3種類の命令を使う
- 少なくとも3つの汎用レジスタを使う
- GDB で途中のレジスタ変化を説明できる

アイデア:

- 引数の数に応じて違う終了ステータスを返す
- 1から10まで足して表示する
- `printf` で16進数を表示する
- `add`、`sub`、`cmp`、条件分岐を組み合わせる

**提出**：

- ソースコード
- 実行結果
- GDB で観察したこと
- 命令ごとの説明

---

### ex04: 追加演習 — 大きな即値をロードする（`exercises/ex04-large-immediate`）

**目的**：`0x1234abcd` のような大きな値を、ARM64 の命令でレジスタへ作ります。

```asm
.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    movz x1, #0xabcd
    movk x1, #0x1234, LSL #16

    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "0x%lx\n"
```

`code_example.s` は、`0x1234abcd` を `movz` / `movk` で作って表示する例です
（実行結果：`0x1234abcd`）。

```bash
gcc -g -o /tmp/ex04 code_example.s
/tmp/ex04
gdb /tmp/ex04
```

GDB では `bl printf` の前で止めて `print/x $x1` を確認してください。

`work/ex04.s` を作成し、次を実現してください。

1. `x1` に `0x1234abcd` を入れる
2. `printf` で16進数として表示する
3. GDB で `x1` の値を確認する

まずは次のような命令が使えるか試してください。

```asm
movz x1, #0xabcd
movk x1, #0x1234, LSL #16
```

**発展**：`0x9999abcd56781234` を `x1` に作って表示してください。

**提出**：

- ソースコード
- 表示結果
- `movz` と `movk` の違いの説明

---

### ex05: 追加演習 — bitmask immediate（`exercises/ex05-bitmask-immediate`）

**目的**：ARM64 の論理命令では、即値として使えるビット列に制限があります。
この制限を実際にアセンブルして確認します。

```asm
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
```

`code_example.s` は、論理即値で直接作れる値と、`movz` / `movk` で組み立てる値を
並べて表示する例です（実行結果：`bitmask immediate: 0x1010101010101010` と
`movz/movk value:    0xabababababababab` の2行）。

```bash
gcc -g -o /tmp/ex05 code_example.s
/tmp/ex05
```

`orr x1, xzr, #0xabababababababab` のような通らない例は、`code_example.s` に
追記してアセンブルエラーを確認してください。

次の値について、`orr x1, xzr, #値` がアセンブルできるか確認してください。

- `0xff00ff00ff00ff00`
- `0xff0000ffff0000ff`
- `0x1010101010101010`
- `0xabababababababab`
- `0x1100110011001100`

例:

```asm
orr x1, xzr, #0x1010101010101010
```

記録すること:

- 通る値
- 通らない値
- 通らない場合のエラーメッセージ
- 通らない値を `movz` / `movk` で作る方法

**提出**：調査結果を表にして提出してください。

---

### ex06: 追加演習 — 関数呼び出しとスタック（`exercises/ex06-function-call-stack`）

**目的**：`bl`、`ret`、`x29`、`x30`、`sp` の関係を GDB で観察します。

```asm
.text
.global main
.global sum_to_n
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x0, #100
    bl sum_to_n

    mov x1, x0
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

sum_to_n:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, #0
    mov x2, #1

loop:
    cmp x2, x0
    bgt done
    add x1, x1, x2
    add x2, x2, #1
    b loop

done:
    mov x0, x1
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%ld\n"
```

`code_example.s` は、`main` から `sum_to_n` を呼び出す完成例です（実行結果：
`5050`）。まずはそのまま動かし、GDB で `x30` と `sp` を観察してください。

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

GDB で確認:

```gdb
break main
break sum_to_n
run
info registers x29 x30 sp
stepi
finish
info registers x0 x29 x30 sp
```

**提出**：

- ソースコード
- 実行結果
- `bl` の直後に `x30` が何を表しているか
- `finish` 実行後に `x0` が何になっているか

---

## 11. 参考解答（solutions/）

`ex04`〜`ex06` については、参考解答が `solutions/` に用意されています
（`ex01`〜`ex03` はオリジナル性の高い課題のため、模範解答は用意されていません）。

### `solutions/ex04-large-immediate/ex04_solution.s`

```asm
.text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    movz x1, #0xabcd
    movk x1, #0x1234, LSL #16

    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%lx\n"
```

実行結果：`1234abcd`

### `solutions/ex05-bitmask-immediate/ex05_solution.s`

```asm
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
```

実行結果：`abababababababab`

`solutions/ex05-bitmask-immediate/notes.md` には、次のようにまとめられています。

- 論理即値として直接使える値の例：`0xff00ff00ff00ff00` / `0xff0000ffff0000ff` /
  `0x1010101010101010`
- `orr x1, xzr, #値` では通らない値の例：`0xabababababababab` / `0x1100110011001100`
- 通らない値も、`movz` / `movk` で16ビットずつ組み立てればレジスタへロードできる

### `solutions/ex06-function-call-stack/ex06_solution.s`

```asm
.text
.global main
.global sum_to_n
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x0, #100
    bl sum_to_n

    mov x1, x0
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

sum_to_n:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, #0
    mov x2, #1

loop:
    cmp x2, x0
    bgt done
    add x1, x1, x2
    add x2, x2, #1
    b loop

done:
    mov x0, x1
    ldp x29, x30, [sp], #16
    ret

.section .rodata
fmt:
    .asciz "%ld\n"
```

実行結果：`5050`

---

## 12. 講師向け情報

### ねらい

学生が ARM64 の命令を「書いて、動かして、観察する」ことを目標にします。正確な命令
エンコードの暗記よりも、レジスタ、関数呼び出し、即値制約、GDB での観察に慣れることを
重視します。

### 60分進行案

| 時間 | 内容 |
| --- | --- |
| 0-5分 | 導入（本ガイドの1〜2章）、環境確認 |
| 5-15分 | `first.s` をビルドし、終了ステータスを見る |
| 15-25分 | `add1.s` で `argc` と `w0` の関係を見る |
| 25-35分 | `a002.s` で `puts` と関数呼び出しを見る |
| 35-45分 | `sum100.s` を GDB でステップ実行する |
| 45-60分 | `ex01` - `ex03` または追加演習へ進む |

### 追加した演習

もとのスライドの演習が少ないため、次の3つが追加されています。

- `ex04-large-immediate`：`movz` / `movk` とシフトで大きな即値を作る
- `ex05-bitmask-immediate`：ARM64 の論理即値の制約を実際のアセンブルで確認する
- `ex06-function-call-stack`：関数呼び出し、`x29`、`x30`、`sp` を GDB で観察する

### 評価観点

- 自分でビルド・実行できている
- GDB でブレークポイントとステップ実行を使えている
- `x0` / `w0`、`x29`、`x30`、`sp` の役割を説明できる
- 即値制約でエラーになる例を説明できる
- オリジナルプログラムで使った命令を説明できる

### よくあるつまずき

- ARM64 ではなく x86_64 Linux で実行している
- macOS の `gcc` で Linux 向けサンプルを直接ビルドしようとしている
- `echo $?` の前に別のコマンドを実行してしまい、終了ステータスが変わっている
- `printf` 呼び出し前にスタックを16バイト境界にしていない
- `x0` にフォーマット文字列、`x1` に表示する値を置く順番を間違えている

---

## 13. 教材の検証スクリプト

リポジトリには、教材の整合性を確認するためのスクリプトが用意されています。

### 教材ファイルの構成チェック

```bash
scripts/check-materials.sh
```

必要なファイルが揃っているか、演習が6件以上あるか、README に必要な記述があるかなどを
確認します。

### Linux ARM64 上でのビルド・実行チェック

```bash
scripts/test-examples.sh
```

Linux ARM64 環境でのみ実際にビルド・実行し、それぞれの出力・終了ステータスが期待値と
一致するかを検証します（それ以外の環境では検証をスキップします）。期待される結果は
本ガイドの各演習セクションに記載した実行結果と一致します。

`Makefile` からも呼び出せます。

```bash
make check   # scripts/check-materials.sh を実行
make test    # scripts/test-examples.sh を実行
```

---

## 14. チートシート（総まとめ）

### レジスタ

| 名前 | 用途 |
| --- | --- |
| `x0` - `x7` | 関数引数、戻り値 |
| `w0` - `w7` | `x0` - `x7` の下位32ビット |
| `x29` | フレームポインタ |
| `x30` | リンクレジスタ、戻りアドレス |
| `sp` | スタックポインタ |
| `xzr` / `wzr` | ゼロレジスタ |

### よく使う命令

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

### 関数の形

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

### `printf` の呼び出し

```asm
    mov x1, #5050
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    bl printf

.section .rodata
fmt:
    .asciz "%ld\n"
```

### GDB

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

### 即値

- `add` / `sub` の即値は基本的に12ビットです。
- `add x1, x2, #0xabc, LSL #12` のように12ビット左シフトした即値も使えます。
- 大きな値は `movz` と `movk` を組み合わせます。
- 論理命令（`orr` / `and` / `eor` など）の即値は任意のビット列ではなく、
  繰り返しパターンとして表現できる値（bitmask immediate）に限られます。

### ビルド・実行コマンド早見表

```bash
make all
make run-first      # exit=2
make run-add1       # 引数なし: exit=2 / a b: exit=4
make run-hello      # Hello, world!
make run-sum100     # 5050
make run-load-imm   # 1234abcd
make run-bitmask    # 1010101010101010
make check          # 教材ファイルの構成チェック
make test           # ビルド・実行チェック（Linux ARM64 のみ）
```
