#!/usr/bin/env bash

if [ -z $2 ]; then
    echo "Usage: fen2pgn FENFILE OUTFILE"
else
    FENSTRING=`head -n 1 $1 | sed -E 's/ /%20/g'`
    wget -q "https://fen2png.com/api/?fen=${FENSTRING}&raw=true" -O $2
fi
 
