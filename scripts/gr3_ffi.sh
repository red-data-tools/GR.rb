#!/usr/bin/env bash

cd "$(dirname "$0")"

cat ../lib/gr3/ffi.rb \
  | sed -ze "s/' *\\\\ *\n *'//g" \
  | grep "try_extern" \
  | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" \
  | sed -e "s/try_extern '//" -e "s/'$//"
