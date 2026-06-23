# ex01: `first.s` をステップ実行する

## 目的

`main` の戻り値が `w0` に置かれることを GDB で確認します。

## 手順

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

## 確認すること

- `mov w0, #2` の実行前後で `w0` がどう変わるか
- `ret` のあと、シェルで見える終了ステータスはいくつか
- `w0` と `x0` の表示はどう違うか

## 提出

GDB の観察結果を3行程度で説明してください。

