#!/usr/bin/env bash

curl -sL https://raw.githubusercontent.com/sciapp/gr/master/lib/gr/gr.h \
  | sed -z -e "s/\n//g" -e "s/;/\n/g" -e 's/  */ /g' \
  | grep "DLLEXPORT" \
  | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" \
  | grep -v -E "^#" \
  | sed -e "s/^DLLEXPORT //"
