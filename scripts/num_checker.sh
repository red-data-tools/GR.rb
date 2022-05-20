#!/usr/bin/env bash

# This is a script to check if other shell scripts are working well.
# It is expected that the numbers output in the three files will be equal.

cd "$(dirname "$0")"

# Count DLLEXPORT

curl -sL https://raw.githubusercontent.com/sciapp/gr/master/lib/gr/gr.h \
  | sed -e "s/#.*$//g" \
  | grep -o DLLEXPORT \
  | wc -l

./gr_h.sh \
  | wc -l

./gr_ffi.sh \
  | wc -l

# Count GR3API

curl -sL https://raw.githubusercontent.com/sciapp/gr/master/lib/gr3/gr3.h \
  | sed -e "s/#.*$//g" \
  | grep -o GR3API | wc -l

./gr3_h.sh \
  | wc -l

./gr3_ffi.sh \
  | wc -l
