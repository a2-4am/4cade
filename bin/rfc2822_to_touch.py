#!/usr/bin/env python3

from email.utils import parsedate_to_datetime
from datetime import UTC
from sys import stdin, stdout

d = parsedate_to_datetime(stdin.readline())
stdout.write(d.astimezone(UTC).strftime("%Y-%m-%dT%H:%M:%SZ\n"))
