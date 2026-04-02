COBC=cobc

COBFLAGS=-x -std=ibm -Wall -Wextra -Wno-terminator

SRC_DIR=src
BIN_DIR=bin

SRCS=$(wildcard $(SRC_DIR)/*.cob)
LIBS=$(addprefix -l, sqlite3)

BIN=$(BIN_DIR)/cobol_sqlite

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
