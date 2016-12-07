#!/bin/bash

TARGET=hoge.s
BASE=${TARGET%.*}
IMG=test.img

# make asm
cat <<EOF > ${TARGET}
fin:
    hlt
    jmp fin
EOF

# asm to binary
as -o ${BASE}.o $TARGET
ld --oformat binary -o ${BASE}.bin ${BASE}.o

# write img
dd if=/dev/zero of=${IMG} bs=1k count=1440
mformat -f 1440 -i ${IMG}
mcopy ${BASE}.bin -i ${IMG} ::
