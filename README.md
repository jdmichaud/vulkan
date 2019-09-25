# Dev environment setup

## Linux

Run `install_dev_env_linux.sh`. This should download and install all the dependencies
from source into the `.env`:

```
./install_dev_env_linux.sh
```

It will download and install:
* Various X libraries
* LLVM (takes a while to compile)
* mesa (opengl library)
* glfw (to create windows)
* glm (linear algebra library)
* The LunarG Vulkan SDK.

Also some build tools will be installed:
* CMake
* meson (for mesa)

All this is downloaded in `.download` and installed in `.env`. Your system and
your home folder are left alone.

Once run, the script will generate `setup_dev_env_linux` which will set the
various environment variable you need to compile a program with Vulkan.

```
source setup_dev_env_linux.sh
```

You can then compile with:
```
make
```
Then:
```
./vulkan-test
```

## MacOS

Run `install_dev_env_macos.sh`. This should download and install all the dependencies
from source into the `.env`:

```
./install_dev_env_macos.sh
```

It will download and install:
* glfw (to create windows)
* glm (linear algebra library)
* The LunarG Vulkan SDK.

It will heavily rely on installed framework, so it will probably not work if you
don't have xcode installed. No promises.
