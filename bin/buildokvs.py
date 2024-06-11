#!/usr/bin/env python3

# parameters
# stdin - input containing key=value pairs (e.g. res/ATTRACT.CONF or some file in res/ATTRACT/)
# stdout - binary OKVS data structure

import struct
import sys

def build(records):
    # yield OKVS header (2 x 2 bytes, unsigned int, little-endian)
    yield struct.pack('<2H', len(records), 0)

    for key, dummy, value in records:
        # yield record length (1 byte)
        yield struct.pack('B', len(key) + len(value) + 3)

        # yield key (Pascal-style string)
        yield struct.pack(f'{len(key)+1}p', key.encode('ascii'))

        # yield value (Pascal-style string)
        yield struct.pack(f'{len(value)+1}p', value.encode('ascii'))

if __name__ == "__main__":
    records = [x.strip() for x in sys.stdin.readlines()]
    records = [x.partition('=') for x in records if x and x[0] not in ('#', '[')]
    for b in build(records):
        sys.stdout.buffer.write(b)
