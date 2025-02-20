# lisi

__lisi__ - _graphics made easy_ - one graphical application for many terminal tools producing graphics

## SYNOPSIS

```bash
lisi INPUT-FILENAME ?CMD-LINE?
```

## INSTALLATION

Copy the file `lisi.tcl` as `lisi` to a folder belonging to your PATH variable
and make the file `lisi`  executable using `chmod`. You need to have installed
the packages `oowidgets` and `paul` as Tcl packages as well.

## DESCRIPTION

__lisi__ - is a graphical  application to use many command line applications  which
create  images  using  some type of  declarative  language using a text editor
with a live preview.  It was programmed to consolidate  the oowidgets and paul
megawidget packages by developing an hopefully useful application.


If the argument  `CMD-LINE` is not given it is assumed that in parallel to the
input  file is a file with the same  basename  but ending  with the  extension
`.opt` which contains the required command line arguments.

Here a few  examples  for tools and some  possible  command  lines  where _%i_
stands always for the input file and _%o_ stands for an optional  output file.
The _%o_ can be  omitted  if the file is  automatically  created  based on the
input file name but with the png extension.  Furthermore there is _%b_ for the
input file name without the file extension.

Either the tools can be supported  directly or by using small wrapper  scripts
which are required if the tool can't output  directly the PNG image format. If
the default  output is svg I use usually  cairosvg to convert from svg to png.
In simple cases for two required commands these commands can be conbined using
a single(!) ampersand. See pikchr or abcm2ps for an example:

- Diagram tools:
    - [plantuml](https://plantuml.com) - `plantuml -tpng %i`
    - [GraphViz](https://graphviz.org) - `dot -Tpng %i -o%o`
    - [Pikchr](https://pikchr.org/)  - `fossil pikchr %i  %b.svg&magick -density 72 %b.svg %o`

- Board Game tools:
    - [sgf-render](https://github.com/julianandrews/sgf-render) - GO/Weiqi/Baduk diagrams - `sgf-render %s --format png --outfile %s --width 500 --move-numbers=1`
    - [fen2pgn](https://fen2png.com/) - example on how to use a webservice using a wrapper script

- Music tools
    - [abcm2ps](https://github.com/lewdlime/abcm2ps/) - convert ABC music into svg or postscript, cairosvg required to convert the output to png - `abcm2ps -g %i&cairosvg Out001.svg -f png -o %b.png`
- Statistic tools 
    -  [Rscript](https://www.r-project.org)  -  `Rscript  %i %o` - see  the  R
    section below
- Math tools:
    - [eqn2graph](https://www.man7.org/linux/man-pages//man1/eqn2graph.1.html) -
      create one line equations - `cat %i | eqn2graph -density 300 2>/dev/null > %o`
    -  [latex](https://editor.codecogs.com/)  - convert  equations using a web
    services this as well requires a wrapper script `text2png %i %o` - see below

## WRAPPER SCRIPT EXAMPLES

Some tools  can't  directly  provide  png files or are using even  webservices
where the png file must be  downloaded  locally.  Here are some  examples  for
wrapper    scripts.    

Let's start with a command line application  which can oynl produce svg files.
We need to call a second application, called cairosvg to convert the svg file into
a png file which is then displayed below of the editor window:

```bash
#!/usr/bin/env bash

if [ -z $2 ]; then
    echo "Usage: abc2png ABCFILE PNGFILE"
else
    BN=`basename .abc`
    abcm2ps -qg $1 -O x ${@:3}
    mv x001.svg ${BN}.svg
    cairosvg ${BN}.svg -o $2
fi
```

Let's  assume that the script file was named  `abc2png`,  made  executable  and
moved to some folder belonging to your PATH the syntax to call `lisi` would be:

```bash
lisi examples/music.abc "abc2png %i %o"
```


Let's    continue  with   a    webservice    at
[https://fen2png.com](https://fen2png.com)   which  convert  FEN  chess  board
positions strings into PNG images.  Here the wrapper script:

```bash
#!/usr/bin/env bash

if [ -z $2 ]; then
    echo "Usage: fen2pgn FENFILE OUTFILE"
else
    ## extract the first line from the fen file and replace empty spaces
    FENSTRING=`head -n 1 $1 | sed -E 's/ /%20/g'`
    wget -q "https://fen2png.com/api/?fen=${FENSTRING}&raw=true" -O $2
fi
```

Let's  assume that the script file was named  `fen2png`  made  executable  and
moved to some folder belonging to your PATH the syntax to call `lisi` would be:

```
lisi examples/chess.fen "fen2png %i %o"
```

Now an example for a wrapper  script which  fetches a LaTeX  equation from the
webservice at https://latex.codecogs.com/:

```bash
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
```

## Rscript

If you like to  create  plots  using one  R script  per plot, an  approach  which is
helpful for  instance to deliver the code for your  scientific  article  plots,
your `Rscript` file should have the following outline:

```{.r}
#!/usr/bin/env Rscript
### extract the filename argument for the image file
argv=commandArgs(trailingOnly=TRUE)
pngfile=argv[1]
png(pngfile,width=800,height=600) ### change to your needs
plot(1) ### add your plot command(s) and options
dev.off()
```

Your command line which you have to enter in the entry field or which you have
to give via the command line would then look like this:

```bash
Rscript %i %o
```

## TODO

- Button-Bar from sqlview
- File Save As (done)
- Example: LaTeX equations: https://editor.codecogs.com/?lang=en-en (done)
- Example: Pikchr (done)
- Example: Rscript (done), Gnuplot
