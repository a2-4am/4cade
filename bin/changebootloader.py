#!/usr/bin/env python3

import sys
import os.path

target_2mg_file, bootloader = sys.argv[1:]
assert(os.path.splitext(target_2mg_file)[-1].lower() == ".2mg")
with open(bootloader, 'rb') as f:
    boot = f.read()
assert(len(boot) == 512)
with open(target_2mg_file, 'rb') as f:
    data = bytearray(f.read())
data[64:64+len(boot)] = boot
with open(target_2mg_file, 'wb') as f:
    f.write(data)
