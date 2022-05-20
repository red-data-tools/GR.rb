#!/usr/bin/env bash

cd "$(dirname "$0")"

delta <(./gr_h.sh) <(./gr_ffi.sh)
# diff <(./gr_h.sh) <(./gr_ffi.sh)
