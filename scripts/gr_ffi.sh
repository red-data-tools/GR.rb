#!/usr/bin/env bash

cat ../lib/gr/ffi.rb \
  | sed -ze "s/' *\\\\ *\n *'//g" \
  | grep "try_extern" \
  | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" \
  | sed -e "s/try_extern '//" -e "s/'$//"
