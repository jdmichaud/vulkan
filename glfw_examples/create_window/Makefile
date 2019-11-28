EXE=create_window
CFLAGS = -std=c++17 `pkg-config --cflags glfw3` -Wall -Wextra -Wpedantic
DEBUG_FLAGS= -ggdb3
OPT_FLAGS= -O3 -DNDEBUG
LDFLAGS = `pkg-config --static --libs glfw3 gl`

$(EXE): main.cpp
	g++ $(CFLAGS) $(OPT_FLAGS) -o $(EXE) main.cpp $(LDFLAGS)

debug: main.cpp
	g++ $(CFLAGS) $(DEBUG_FLAGS) -o $(EXE) main.cpp $(LDFLAGS)

.PHONY: test clean re

clean:
	rm -f $(EXE)

re: clean $(EXE)
