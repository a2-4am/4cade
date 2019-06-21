#!/usr/bin/env python3

STAGES = 75
BASE_ADDRESS = 8192

print("TransformLo")
for i in range(0, STAGES):
    print("       !byte <Transform{:02d}".format(i))
print("TransformHi")
for i in range(0, STAGES):
    print("       !byte >Transform{:02d}".format(i))
print()
for i in range(0, STAGES):
    with open("PI.A{:02d}#064000".format(i) , "rb") as f:
        olddata = f.read()
    with open("PI.A{:02d}#064000".format(i + 1), "rb") as f:
        newdata = f.read()
    print("Transform{:02d}".format(i))
    print("         lda   #$00")
    for j in range(0, len(olddata)):
        if olddata[j] != newdata[j]:
            print("         sta   ${:04X}".format(BASE_ADDRESS + j))
    print("         rts")
    print()
