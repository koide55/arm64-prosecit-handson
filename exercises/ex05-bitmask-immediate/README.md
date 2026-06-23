# ex05: 追加演習 - bitmask immediate

## 目的

ARM64 の論理命令では、即値として使えるビット列に制限があります。この制限を実際にアセンブルして確認します。

## 課題

このディレクトリの `code_example.s` は、論理即値で直接作れる値と、`movz` / `movk` で組み立てる値を並べて表示する例です。

```bash
gcc -g -o /tmp/ex05 code_example.s
/tmp/ex05
```

`orr x1, xzr, #0xabababababababab` のような通らない例は、`code_example.s` に追記してアセンブルエラーを確認してください。

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

## 記録すること

- 通る値
- 通らない値
- 通らない場合のエラーメッセージ
- 通らない値を `movz` / `movk` で作る方法

## 提出

調査結果を表にして提出してください。
