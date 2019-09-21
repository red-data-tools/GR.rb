#!/usr/bin/env bash

set -e

CACHE_DIR=$HOME/GR/$GR_VERSION

if [ ! -d "$CACHE_DIR" ]; then
    wget https://github.com/sciapp/gr/releases/download/v$GR_VERSION/gr-$GR_VERSION-Ubuntu-x86_64.tar.gz
    tar -xf gr-$GR_VERSION-Ubuntu-x86_64.tar.gz
    mv gr-0.41.2-Ubuntu-x86_64/gr $CACHE_DIR
else
    echo "GR cached"
fi
