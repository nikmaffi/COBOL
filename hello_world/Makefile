COBC=cobc

COBFLAGS=-x -std=ibm -Wall -Wextra -Wno-terminator

SRC_DIR=src
BIN_DIR=bin

SRCS=$(wildcard $(SRC_DIR)/*.cob)
LIBS=$(addprefix -l, )

BIN=$(BIN_DIR)/hello_world

all: $(BIN)

$(BIN_DIR):
	mkdir -p $@

$(BIN): $(SRCS) | $(BIN_DIR)
	$(COBC) $(COBFLAGS) $^ -o $@ $(LIBS)
	strip $(BIN)

run: all
	./$(BIN)

clean:
	rm -rf ./$(BIN_DIR)/*
