#!/usr/bin/env bash

cd "$(dirname "$0")"

curl -sL https://raw.githubusercontent.com/sciapp/gr/master/lib/gr3/gr3.h \
  | sed -e "s/#.*$//g" \
  | sed -z -e "s/\n//g" -e "s/;/\n/g" -e 's/  */ /g' \
  | grep "GR3API" \
  | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" \
  | grep -v -E "^#" \
  | sed -e "s/^GR3API //"
