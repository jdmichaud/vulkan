#!/bin/sh

export VULKAN_SDK_PATH=/home/jedi/projects/vulkan/.env/1.1.121.1/x86_64/

# So that vulkan will find icd.d
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/home/jedi/projects/vulkan/.env/share/

export PKG_CONFIG_PATH=/home/jedi/projects/vulkan/.env/lib/pkgconfig:/lib/pkgconfig/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/jedi/projects/vulkan/.env/lib/:/lib
export PATH=$PATH:/home/jedi/projects/vulkan/.env/bin:/bin
