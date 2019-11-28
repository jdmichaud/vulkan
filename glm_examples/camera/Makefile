EXE=camera
CFLAGS = -std=c++17 `pkg-config --cflags glm` -Wall -Wextra -Wpedantic -fmax-errors=1
DEBUG_FLAGS= -ggdb3
OPT_FLAGS= -O3 -DNDEBUG
LDFLAGS = `pkg-config --static --libs glm`

$(EXE): main.cpp
	g++ $(CFLAGS) $(OPT_FLAGS) -o $(EXE) main.cpp $(LDFLAGS)

debug: main.cpp
	g++ $(CFLAGS) $(DEBUG_FLAGS) -o $(EXE) main.cpp $(LDFLAGS)

.PHONY: test clean re

clean:
	rm -f $(EXE)

re: clean $(EXE)
