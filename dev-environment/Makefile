EXE=vulkan-test
CFLAGS = -std=c++17 -I${VULKAN_SDK_PATH}/include `pkg-config --cflags glfw3`
LDFLAGS = -L$(VULKAN_SDK_PATH)/lib `pkg-config --static --libs glfw3` -lvulkan

$(EXE): main.cpp
	g++ $(CFLAGS) -o $(EXE) main.cpp $(LDFLAGS)

.PHONY: test clean re

test: $(EXE)
	LD_LIBRARY_PATH=$(VULKAN_SDK_PATH)/lib VK_LAYER_PATH=$(VULKAN_SDK_PATH)/etc/vulkan/explicit_layer.d ./$(EXE)

clean:
	rm -f $(EXE)

re: clean $(EXE)