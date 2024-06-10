#!/usr/bin/env python3

# flags
# -a  append to data file (default off = truncate)
# -p  pad sizes within data file to next block size (default off)

# parameters
# stdin - input containing list of files (e.g. FX.CONF)
# stdout - binary OKVS data structure
# 1 - output filename for data file
# 2 - input directory of files to merge into data file
# 3 - (optional) output filename for log of key,offset,size

import argparse
import os
import os.path
import struct
import sys

kStandardFilename = 'STANDARD'
kFileMode = {False: 'wb', True: 'ab'}

def build(records, args):
    if args.append:
        output_file_size = os.path.getsize(args.output_file)
    else:
        output_file_size = 0
    standard_offset = standard_size = 0
    standard_filename = os.path.join(args.input_directory, kStandardFilename)
    with open(args.output_file, kFileMode[args.append]) as output_file_handle:
        if os.path.exists(standard_filename):
            standard_offset = output_file_size
            standard_size = os.path.getsize(standard_filename)
            with open(standard_filename, 'rb') as standard_handle:
                output_file_handle.write(standard_handle.read())
            output_file_size += standard_size

        # yield OKVS header (2 x 2 bytes, unsigned int, little-endian)
        yield struct.pack('<H', len(records))
        yield struct.pack('<H', 0)

        for rec in records:
            filename, dummy, dummy = rec.partition('=')
            key, dummy, addr = filename.partition('#')
            filename = os.path.join(args.input_directory, filename)
            rec_offset = standard_offset
            rec_size = standard_size

            # yield record length (1 byte, unsigned byte)
            if addr:
                # if filename is in the form 'NAME#06ADDR' then create extended index record
                yield struct.pack('B', len(key)+9)
                # trim '06' so we get just the starting address
                addr = addr[2:]
            else:
                yield struct.pack('B', len(key)+7)

            # yield key (Pascal-style string)
            yield struct.pack(f'{len(key)+1}p', key.encode('ascii'))

            if os.path.exists(filename):
                rec_offset = output_file_size
                rec_size = os.path.getsize(filename)
                output_file_size += rec_size
                if args.pad:
                    # If offset+size does not cross a block boundary, use file's true size.
                    # Otherwise, round up size to the next block boundary.
                    # This padding does not get added to the file; it is just an
                    # optimization to avoid a partial copy on the last block read.
                    if (rec_offset // 512) != ((rec_offset + rec_size) // 512):
                        rec_size = ((rec_offset + rec_size + 511) & -512) - rec_offset
                with open(filename, 'rb') as input_file_handle:
                    output_file_handle.write(input_file_handle.read())

            # yield record offset (3 bytes, big-endian, unsigned long)
            yield struct.pack('>L', rec_offset)[1:]

            # yield record size (2 bytes, little-endian, unsigned short)
            yield struct.pack('<H', rec_size)

            if addr:
                # for extended index record, yield load address (2 bytes, little-endian, unsigned short)
                yield bytes.fromhex(addr)[::-1]

            if args.log_file:
                with open(args.log_file, 'a') as log_file_handle:
                    log_file_handle.write(f'{key},{rec_offset},{rec_size}\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build indexed OKVS structure with links to data stored in TOTAL.DATA file")
    parser.add_argument("output_file")
    parser.add_argument("input_directory")
    parser.add_argument("log_file")
    parser.add_argument("-p", "--pad", action="store_true", default=False, help="pad file sizes to multiples of 512 (default: use exact size)")
    parser.add_argument("-a", "--append", action="store_true", default=False, help="append to output file (default: overwrite)")
    args = parser.parse_args()
    records = [x.strip() for x in sys.stdin.readlines()]
    records = [x for x in records if x and x[0] not in ('#', '[')]
    for b in build(records, args):
        sys.stdout.buffer.write(b)
