#!/usr/bin/env python3

# parameters
# stdin - input containing slideshow (e.g. some file in res/SS/)
# stdout - binary OKVS data structure
# 1 - name of slideshow file (used to decide whether if this is an action slideshow)
# 2 - name of file containing list of games with metadata (e.g. build/GAMES.CONF)

import argparse
import os.path
import struct
import sys

# indexes into |flags| as string
iNeedsJoystick = 0
iNeeds128K     = 1

# maps of flag raw string value -> value in final flags byte
kNeedsJoystick = {'0': 0, '1': 128}
kNeeds128K     = {'0': 0, '1': 64}

def build(records, args):
    with open(args.games_file, 'r') as games_file_handle:
        games_list = [x.strip() for x in games_file_handle.readlines()]
    games_list = [x.replace('=',',').split(',')
                  for x in games_list
                  if x and x[0] not in ('#', '[')]
    games_cache = {}
    if os.path.basename(args.slideshow_file).startswith('ACT'):
        for flags, key, displayname in games_list:
            games_cache[key] = (flags, displayname)
    else:
        for flags, key, dummy in games_list:
            games_cache[key] = (flags, "")
    
    # yield OKVS header (2 x 2 bytes, unsigned int, little-endian)
    yield struct.pack('<2H', len(records), 0)

    for key, dummy, value in records:
        filename = value or key
        flags, displayname = games_cache[filename]

        # yield record length (1 byte)
        yield struct.pack('B', len(key) + len(value) + len(displayname) + 5)

        # yield key (Pascal-style string)
        yield struct.pack(f'{len(key)+1}p', key.encode('ascii'))

        # yield value (Pascal-style string)
        yield struct.pack(f'{len(value)+1}p', value.encode('ascii'))

        # yield display name (Pascal-style string)
        yield struct.pack(f'{len(displayname)+1}p', displayname.encode('ascii'))

        # yield flags
        yield struct.pack('B', kNeedsJoystick[flags[iNeedsJoystick]] + \
                          kNeeds128K[flags[iNeeds128K]])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build indexed OKVS structure from slideshow configuration file")
    parser.add_argument("slideshow_file")
    parser.add_argument("games_file")
    args = parser.parse_args()
    records = [x.strip() for x in sys.stdin.readlines()]
    records = [x.partition('=') for x in records if x and x[0] not in ('#', '[')]
    for b in build(records, args):
        sys.stdout.buffer.write(b)
