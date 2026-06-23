#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "README.md"
  "README_STUDENTS.md"
  "Makefile"
  "Dockerfile"
  "docker-compose.yml"
  "slides/arm64-prosecit-20250727.pdf"
  "docs/arm64-cheatsheet.md"
  "docs/instructor-guide.md"
  "examples/01-first/first.s"
  "examples/02-add1/add1.s"
  "examples/03-hello/a002.s"
  "examples/04-sum100/sum100.s"
  "examples/05-large-immediate/load_imm.s"
  "examples/06-bitmask/bitmask_good.s"
  "exercises/ex01-debug-first/README.md"
  "exercises/ex01-debug-first/code_example.s"
  "exercises/ex02-add-sub-registers/README.md"
  "exercises/ex02-add-sub-registers/code_example.s"
  "exercises/ex03-original-program/README.md"
  "exercises/ex03-original-program/code_example.s"
  "exercises/ex04-large-immediate/README.md"
  "exercises/ex04-large-immediate/code_example.s"
  "exercises/ex05-bitmask-immediate/README.md"
  "exercises/ex05-bitmask-immediate/code_example.s"
  "exercises/ex06-function-call-stack/README.md"
  "exercises/ex06-function-call-stack/code_example.s"
  "solutions/ex04-large-immediate/ex04_solution.s"
  "solutions/ex05-bitmask-immediate/ex05_solution.s"
  "solutions/ex06-function-call-stack/ex06_solution.s"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "missing: $file" >&2
    exit 1
  fi
done

exercise_count="$(find exercises -mindepth 2 -maxdepth 2 -name README.md | wc -l | tr -d ' ')"
if [ "$exercise_count" -lt 6 ]; then
  echo "expected at least 6 exercises, got $exercise_count" >&2
  exit 1
fi

code_example_count="$(find exercises -mindepth 2 -maxdepth 2 -name code_example.s | wc -l | tr -d ' ')"
if [ "$code_example_count" -lt 6 ]; then
  echo "expected at least 6 exercise code examples, got $code_example_count" >&2
  exit 1
fi

grep -q "追加演習" README.md
grep -q "code_example.s" README.md
grep -q "code_example.s" README_STUDENTS.md
grep -q "ex04-large-immediate" docs/instructor-guide.md
grep -q "ex05-bitmask-immediate" docs/instructor-guide.md
grep -q "ex06-function-call-stack" docs/instructor-guide.md

echo "materials ok"
