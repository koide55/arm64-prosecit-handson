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

echo "examples ok"

