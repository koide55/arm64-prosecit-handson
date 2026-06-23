CC ?= gcc
CFLAGS ?= -g
BUILD_DIR := build

.PHONY: all clean check test \
	run-first run-add1 run-hello run-sum100 run-load-imm run-bitmask \
	gdb-first gdb-add1 gdb-sum100

all: \
	$(BUILD_DIR)/first \
	$(BUILD_DIR)/add1 \
	$(BUILD_DIR)/a002 \
	$(BUILD_DIR)/sum100 \
	$(BUILD_DIR)/load_imm \
	$(BUILD_DIR)/bitmask_good

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/first: examples/01-first/first.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/add1: examples/02-add1/add1.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/a002: examples/03-hello/a002.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/sum100: examples/04-sum100/sum100.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/load_imm: examples/05-large-immediate/load_imm.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/bitmask_good: examples/06-bitmask/bitmask_good.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

run-first: $(BUILD_DIR)/first
	set +e; ./$(BUILD_DIR)/first; code=$$?; set -e; echo "exit=$$code"

run-add1: $(BUILD_DIR)/add1
	./$(BUILD_DIR)/add1; echo "exit=$$?"
	./$(BUILD_DIR)/add1 a b; echo "exit=$$?"

run-hello: $(BUILD_DIR)/a002
	./$(BUILD_DIR)/a002

run-sum100: $(BUILD_DIR)/sum100
	./$(BUILD_DIR)/sum100

run-load-imm: $(BUILD_DIR)/load_imm
	./$(BUILD_DIR)/load_imm

run-bitmask: $(BUILD_DIR)/bitmask_good
	./$(BUILD_DIR)/bitmask_good

gdb-first: $(BUILD_DIR)/first
	gdb ./$(BUILD_DIR)/first

gdb-add1: $(BUILD_DIR)/add1
	gdb ./$(BUILD_DIR)/add1

gdb-sum100: $(BUILD_DIR)/sum100
	gdb ./$(BUILD_DIR)/sum100

check:
	scripts/check-materials.sh

test:
	scripts/test-examples.sh

clean:
	rm -rf $(BUILD_DIR)
