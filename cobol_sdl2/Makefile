COBC=cobc

BIN=$(BIN_DIR)/sdl2-cobol

LIBS=-lSDL2
MAIN=MAIN.COB

BIN_DIR=BIN

all: $(BIN)

$(BIN): $(MAIN)
	$(COBC) -Ox -o $@ $^ $(LIBS)

clean:
	rm $(BIN)