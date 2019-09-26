CFLAGS = -std=c++17 \
		-I.env/glfw-3.3/include/ \
		-I.env/vulkansdk-macos-1.1.114.0/macOS/include/ \
		-I.env/glm-0.9.9.5/ \
		-L.env/glfw-3.3/build/src/ \
		-L.env/vulkansdk-macos-1.1.114.0/MoltenVK/macOS/static
LDFLAGS = -lglfw3 \
		-lMoltenVK \
		-framework Cocoa \
		-framework OpenGL \
		-framework IOKit \
		-framework CoreVideo \
		-framework IOSurface \
		-framework Metal \
		-framework Foundation \
		-framework QuartzCore

all: VulkanTest

VulkanTest: main.cpp
	c++ $(CFLAGS)	-o VulkanTest	main.cpp $(LDFLAGS)


.PHONY: clean re

clean:
	rm -fr VulkanTest

re: clean all
