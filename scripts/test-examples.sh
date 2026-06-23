#!/usr/bin/env bash
set -euo pipefail

os="$(uname -s)"
arch="$(uname -m)"

if [ "$os" != "Linux" ] || { [ "$arch" != "aarch64" ] && [ "$arch" != "arm64" ]; }; then
  echo "skip: examples must be executed on Linux ARM64, got $os/$arch"
  exit 0
fi

make clean
make all

set +e
./build/first >/tmp/arm64-first.out 2>&1
first_status=$?
set -e
test "$first_status" -eq 2

set +e
./build/add1 >/tmp/arm64-add1-empty.out 2>&1
add1_empty_status=$?
./build/add1 a b >/tmp/arm64-add1-args.out 2>&1
add1_args_status=$?
set -e
test "$add1_empty_status" -eq 2
test "$add1_args_status" -eq 4

test "$(./build/a002)" = "Hello, world!"
test "$(./build/sum100)" = "5050"
test "$(./build/load_imm)" = "1234abcd"
test "$(./build/bitmask_good)" = "1010101010101010"

mkdir -p build/solutions
gcc -g -o build/solutions/ex04 solutions/ex04-large-immediate/ex04_solution.s
gcc -g -o build/solutions/ex05 solutions/ex05-bitmask-immediate/ex05_solution.s
gcc -g -o build/solutions/ex06 solutions/ex06-function-call-stack/ex06_solution.s

test "$(./build/solutions/ex04)" = "1234abcd"
test "$(./build/solutions/ex05)" = "abababababababab"
test "$(./build/solutions/ex06)" = "5050"

mkdir -p build/exercises
gcc -g -o build/exercises/ex01 exercises/ex01-debug-first/code_example.s
gcc -g -o build/exercises/ex02 exercises/ex02-add-sub-registers/code_example.s
gcc -g -o build/exercises/ex03 exercises/ex03-original-program/code_example.s
gcc -g -o build/exercises/ex04 exercises/ex04-large-immediate/code_example.s
gcc -g -o build/exercises/ex05 exercises/ex05-bitmask-immediate/code_example.s
gcc -g -o build/exercises/ex06 exercises/ex06-function-call-stack/code_example.s

set +e
./build/exercises/ex01 >/tmp/arm64-ex01.out 2>&1
ex01_status=$?
./build/exercises/ex02 >/tmp/arm64-ex02-empty.out 2>&1
ex02_empty_status=$?
./build/exercises/ex02 a b >/tmp/arm64-ex02-args.out 2>&1
ex02_args_status=$?
set -e
test "$ex01_status" -eq 2
test "$ex02_empty_status" -eq 1
test "$ex02_args_status" -eq 5

test "$(./build/exercises/ex03)" = "sum(1..10) = 55"
test "$(./build/exercises/ex04)" = "0x1234abcd"
test "$(./build/exercises/ex05)" = $'bitmask immediate: 0x1010101010101010\nmovz/movk value:    0xabababababababab'
test "$(./build/exercises/ex06)" = "5050"

echo "examples ok"
