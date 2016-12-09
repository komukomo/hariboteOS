#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import re

regex = re.compile(r'char (0x[0-9a-fA-F]+)\n(([\.\*]{8}\n){16}\n)')
script_tmpl = '''
char hankaku[{length}] = {{
{body}
}};
'''


def main():
    if len(sys.argv) != 2:
        print('usage:', sys.argv[0], '[file]', file=sys.stderr)
        sys.exit(1)
    fpath = sys.argv[1]
    with open(fpath) as f:
        lines = [','.join(l) for l in scan(f.read())]
        # char_len = len(lines)
        body = ','.join(lines)
    result = script_tmpl.format(length=4096, body=body)
    print(result)


def scan(f):
    get_token = regex.match
    mo = get_token(f, 0)
    while mo is not None:
        num = mo.group(1)
        body = mo.group(2)
        yield make_font_hex(num, body)
        mo = get_token(f, mo.end())


def make_font_hex(head, body):
    return [bits2hex(str2bits(line)) for line in body.split()]


def bits2hex(bits):
    return hex(int(bits, 2))


def str2bits(line):
    return ''.join(map(char2bit, line))


def char2bit(char):
    return '0' if char == '.' else '1'


if __name__ == '__main__':
    main()
