COBC=cobc

BIN=$(BIN_DIR)/sdl2-cobol

LIBS=-lSDL2
MAIN=MAIN.COB

BIN_DIR=BIN

all: $(BIN)

$(BIN_DIR):
	mkdir -p $@

$(BIN): $(MAIN) | $(BIN_DIR)
	$(COBC) -Ox -o $@ $^ $(LIBS)

clean:
	rm $(BIN)
