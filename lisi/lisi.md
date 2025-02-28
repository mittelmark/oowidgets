<a name="toc"> </a>
## Table of Contents

* __Lisi application__
    - [Lisi](#Lisi) introduction
    - [Lisi Shortcuts](#shortcuts)
* Filetypes  
    - [GraphViz](#graphviz) graphics
    - [PlantUML](#plantuml) graphics
    - [GO Game](#gogame) board graphics

Formatting: __bold__, _italics_ and `typewriter` can be seen as typewriter and
__bold__ again!

<a name="lisi"></a>
## Lisi - graphics made easy 

An  graphical  application  to use  command  line  tools  which  are  creating
graphics.

The basic outline of the application is as follows:

    +----------------------------------------+
    | Menu                    cEE            |
    +----------------------------------------+     
    | Label  CLI-Entry  Execute-Button       | 
    +----------------------------------------+
    |                                        | 
    |                                        |
    |  tk.Text widget to enter the           |
    |  code for creating the image           |
    |                                        |
    |                                        |
    |                                        |
    +----------------------------------------+ 
    |                                        |
    |                                        |
    | ttk.Label to display the image         |
    |                                        |
    +----------------------------------------+
    | ttk.Label (Statusbar)  ttk.Progressbar |                 
    +----------------------------------------+

The use enters the text into the  _tk.Text_  widget and the  required  command
line to process the code into the command  line  interface  (CLI)  _ttk.Entry_
widget.  Pressing  the  execute  Button  beside  of the CLI entry  widget.  If
everything runs smooth the created image is displayed in the _ttk.Label_  widget
below of the _tk.Text_ widget.

The following place holders for input and output filenames can be used with in
the CLI entry.

* _%i_ - the input filename
* _%o_ - the output filename
* _%b_ - the basename of the input filename

See the next pages for a few examples to process the following file types:

* [GraphViz](#graphviz) dot files
* [PlantUML](#plantuml) pml files
* [GO Game](#gogame) sgf files

Back to [Table of Contents](#toc).

<a name="shortcuts"></a>
## Lisi Shortcuts

Here are the application shortcuts:

Back to [Table of Contents](#toc).

<a name="graphviz"></a>
## GraphViz - diagrams

GraphViz -  https://graphviz.org  - is a set of programs  which can be used to
draw graphs or  flowcharts. To see what tools are available  call the man page
for  graphviz.  Let's  here  shorty  describe  the use of the tool dot to draw
directed graphs. The usual command line for a graphviz dot file is:

     dot -Tpng %i -o%o
  
where _%i_ stands for the current input file and ~%o~ for the output file. You
have to enter this line into the _ttk::entry_ field on top. At the bottom you can
enter  some code for the graph you would  like to render as an image.  Here an
example:

    digraph g {
      rankdir="LR"
      node[shape=box,style=filled,fillcolor=skyblue]
      A -> B -> C
    }

If you enter these  lines, save the file and then press the create  button you
should see the created image at the display label.

Back to [Table of Contents](#toc).

<a name="plantuml"></a>
## PlantUML - diagrams

PlantUML  -  https://www.plantuml.com  - is a Java command line application  which  can be
usually  installed  using  your  package  manager.  It is used to  create  UML
diagrams  for  programs,  database  schemas and much more types. For a list of
diagrams  you should  consult  the  PlantUML  webpage.  If you have  installed
PlantUML properly you usually can call it like this:

    plantuml -tpng %i
  
The output file is automatically chosen based on the input filename.

Back to [Table of Contents](#toc).

<a name="gogame"></a>
## GO Game - board positions

Go / IGo / Baduk / Weiqi is a  several  thousand  year old board  game  famous
mostly in Asia. There are many tools which allow you to create  images of game
positions.   Here  I  show   as  an   example   the   use  of   sgf-render   -
https://github.com/julianandrews/sgf-render  - which  provides  downloads  for
Linux, MacOS and Windows platforms.

It converts  mostly used game record  format for GO into svg or png images. We
use the png output as this can be displayed  without any  conversion  directly
inside of our _ttk::label_ widget. The command would then look like this:

    sgf-render %i --format png --outfile %o \
      --width 500 --move-numbers=1

Back to [Table of Contents](#toc).

