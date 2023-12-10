#!/bin/bash
for i in {1..499}
do
  pn=$(printf "%06d" "$i")
  ln -s 000000.txt $pn.txt
done
