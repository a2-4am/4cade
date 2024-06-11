#!/usr/bin/env python3

# parameters
# stdin - input containing slideshow (e.g. some file in res/SS/)
# stdout - binary OKVS data structure
# 1 - name of slideshow file (used to decide whether if this is an action slideshow)
# 2 - name of file containing list of games with metadata (e.g. build/GAMES.CONF)

import argparse
import os.path
from struct import pack
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
    if os.path.basename(args.slideshow_file).startswith('ACT'):
        games_cache = dict([(key, (flags, displayname)) for flags, key, displayname in games_list])
    else:
        games_cache = dict([(key, (flags, '')) for flags, key, displayname in games_list])
    
    # yield OKVS header (2 x 2 bytes, unsigned int, little-endian)
    yield pack('<2H', len(records), 0)

    for key, dummy, value in records:
        flags, displayname = games_cache[value or key]

        # yield record length (1 byte)
        yield pack('B', len(key) + len(value) + len(displayname) + 5)

        # yield key (Pascal-style string)
        yield pack(f'{len(key)+1}p', key.encode('ascii'))

        # yield value (Pascal-style string)
        yield pack(f'{len(value)+1}p', value.encode('ascii'))

        # yield display name (Pascal-style string)
        yield pack(f'{len(displayname)+1}p', displayname.encode('ascii'))

        # yield flags
        yield pack('B', kNeedsJoystick[flags[iNeedsJoystick]] + \
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
