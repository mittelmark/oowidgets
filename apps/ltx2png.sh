
function ltx2png {
    if [ -z $2 ] ; then
      echo "Usage: ltx2png INFILE OUTFILE DPI"
      echo "The default DPI is 110"
    else
        if [ -z $3 ]; then
            DPI=110
        else
            DPI=$3
        fi
        TEX=`grep -vE '^\s*%' $1 | tr -d '\n' | tr -d ' '`
        echo "$TEX"
        wget -q "https://latex.codecogs.com/png.image?\dpi{${DPI}}${TEX}" -O $2
    fi
}

ltx2png "$@"
