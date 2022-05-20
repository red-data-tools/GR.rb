#!/usr/bin/env bash

cd "$(dirname "$0")"

delta <(./gr3_h.sh) <(./gr3_ffi.sh)
# diff <(./gr3_h.sh) <(./gr3_ffi.sh)
