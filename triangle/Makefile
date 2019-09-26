EXE=vulkan-test
CFLAGS = -std=c++17 -I${VULKAN_SDK_PATH}/include `pkg-config --cflags glfw3` -Wall -Wextra -Wpedantic
DEBUG_FLAGS= -ggdb3
OPT_FLAGS= -O3 -DNDEBUG
LDFLAGS = -L$(VULKAN_SDK_PATH)/lib `pkg-config --static --libs glfw3` -lvulkan

$(EXE): main.cpp
	g++ $(CFLAGS) $(OPT_FLAGS) -o $(EXE) main.cpp $(LDFLAGS)

debug: main.cpp
	g++ $(CFLAGS) $(DEBUG_FLAGS) -o $(EXE) main.cpp $(LDFLAGS)

.PHONY: test clean re

test: $(EXE)
	LD_LIBRARY_PATH=$(VULKAN_SDK_PATH)/lib VK_LAYER_PATH=$(VULKAN_SDK_PATH)/etc/vulkan/explicit_layer.d ./$(EXE)

clean:
	rm -f $(EXE)

re: clean $(EXE)