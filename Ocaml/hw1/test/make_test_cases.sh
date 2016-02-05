#!/bin/bash
MAGIC_STRING='a6b9b17503dcd9b5b8e8ad16da46c432'
for i in *.template; do
    sed s/%MAGIC%/$MAGIC_STRING/g $i > "`basename $i .template`.ml"
done

