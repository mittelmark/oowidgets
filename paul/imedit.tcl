#!/usr/bin/env tclsh
#' ---
#' title: paul::imedit documentation
#' author: Detlef Groth, University of Potsdam, Germany
#' Date : <250222.0936>
#' tcl:
#'   eval: 1
#' header-includes: 
#' - | 
#'     ```{=html}
#'     <style>
#'     html {
#'       line-height: 1.2;
#'       font-family: Georgia, serif;
#'       font-size: 16px;
#'       color: #1a1a1a;
#'       background-color: #fdfdfd;
#'     }
#'     body { max-width: 1000px; }
#'     pre#license {
#'       background: #fdfdfd;
#'     }
#'     </style>
#'     ```
#' ---
#' 
#' ```{.tcl eval=true echo=false results="asis"}
#' lappend auto_path .
#' include paul/header.html
#' ```
#' 
#' ## NAME
#'
#' **paul::imedit** - imedit widget for Tk applications based on a paul::labentry for entering
#' a command line to create an image, tk::text to write the image cde commands and ttk::label
#' to display the image.
#'
#' ## <a name='toc'></a>Table of Contents
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'  - [EXAMPLE](#example)
#'  - [SEE ALSO](#see)
#'  - [AUTHOR](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'></a>SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path [file join [file dirname [info script]] ..]
#' ```
#' 
#' ```
#' package require paul
#' paul::imedit pathName options
#' pathName labentry entry configure options
#' pathName labentry label configure options
#' pathName text configure options
#' pathName label configure options
#' ```
#'
#' ## <a name='description'></a>DESCRIPTION
#' 
#' **paul::imedit** - is a composite widget consisting of a [paul::labentry](labentry.html) to 
#' allow the user to enter a command line command to create an image using a terminal tool like
#' GraphViz dot, PlantUML etc, a [tk::text](https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm) 
#' widget to enter the graphics creation code and a [[ttk::label](https://www.tcl-lang.org/man/tcl8.6/TkCmd/ttk_label.htm)
#' widget to display that image. It is a proof of principle widget that paul widgets can be used as
#' component of megawidgets, so that we can build megawidgets based on other megawidgets.
#'
#' This is a proof of principle example widget, to demonstrate the composition of a megawidget
#' based on a paul package megawidget and standard Tk widgets. The UML schema for this widget is
#' shown below:
#'
#' ![](https://kroki.io/plantuml/svg/eNp1UFsOwiAQ_OcUG7_Uphfgw1N4AdqSpgHbRrZR03B3eacg8sXM7M7O7sp6wUYOJ1iW1zSMHJX57wTM6yVTKvGwgyaarKlhZZt0tb7OQkqnBx8mDAYNIH_j-RKAZB2XGZrx-TGEsT16RMW7NBDLMpM8y10ckqCg1A52iQNlOddakt2GuMywaziyYb4dkvZv21sRsKb5A5DsGu21bMxlo8fMFSVF_6P5DUhxu2rrr-rgFwpap6o=)
#'
#' ## <a name='command'></a>COMMAND
#'
#' **paul::imedit** *pathName ?options?*
#' 
#' > Creates and configures a new `paul::imedit` widget  using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'></a>WIDGET OPTIONS
#' 
#' The **paul::imedit** widget is a composite widget where the options 
#' are delegated to the original widgets. In addition to the default options the following option(s)
#' are added :
#'
#' - __-commandline__ - the text which should be aded to the entry widget as the command line and which is executed if the 
#'   code in the text widget is saved
#' - __-filename__ - the file which should be opened into the text widget to be edited by the user
#' - __-filetypes__ - the filetypes used for the file open and file save dialogs, default to dot, pml, txt and all files.
#' - __-labeltext__ - the text which should be displayed in the label widget left from the command line entry widget
#' - __-pane__ - orientation of the paned window widget, either horizontal or vertical, default: vertical
#' - __-statuslabel__ - an optional label widget to display status messages
#' 
package require oowidgets
namespace eval ::paul { }
oowidgets::widget ::paul::ImEdit {
    variable lbent
    variable txt
    variable btn
    variable img
    variable img2
    variable lastdir 
    variable pw
    variable defaults 
    variable pw
    variable pw2
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my option -filetypes {
            {{ABC Music Files}  {.abc}        }
            {{Dot Files}        {.dot}        }
            {{Eqn Files}        {.eqn}        }
            {{Pikchr   Files}   {.pik}        }
            {{PlantUML Files}   {.pml}        }
            {{R/Rscript Files}  {.R .r}       }
            {{Go SGF  Files}    {.sgf}        }
            {{Text Files}       {.txt}        }
            {{All Files}        *             }
        }
        my option -labeltext " Command line: "
        array set defaults [list \
                            abc {abcm2ps -g %i&cairosvg Out001.svg -f png -o %b.png} \
                            dot {dot -Tpng %i -o%o} \
                            eqn {cat %i | eqn2graph -density 300 2>/dev/null > %o} \
                            pik {fossil pikchr %i  %b.svg&magick -density 72 %b.svg %o} \
                            pml {plantuml -tpng %i} \
                            r {Rscript %i %o} \
                            sgf {sgf-render sgf-render %s --format png --outfile %s --width 600} \
                            ]

        my install ttk::frame $path -commandline "" -filename "" -statuslabel "" -pane vertical
        set lastdir [pwd]
        set tf [ttk::frame $path.tf]
        set lbent [paul::labentry $path.tf.lbent]
        $lbent entry configure -width 50
        set btn [ttk::button $path.tf.btn -text " Execute " -command [mymethod execute]]
        set pw [ttk::panedwindow $path.pw -width 300]
        set pw2 [ttk::panedwindow $pw.pw2 -orient horizontal -width 300]
        #set tfr1 [ttk::frame $path.pw.fr]
        ## TODO - add scrollbars via guibaseclass autoscroll?
        set txt [tkoo::text $pw2.txt]
        bind $txt <KeyPress-F2> [mymethod ToggleLayout]
        $txt configure -background skyblue
        $txt mixin paul::txindent paul::txfileproc -filetypes [my cget -filetypes] paul::txpopup
        set img [ttk::label $path.pw.img -anchor center -image ::paul::devscreen22]
        set img2 [ttk::label $pw2.img2 -anchor center -image ::paul::devscreen22]        
        $pw add $pw2
        $pw2 add $txt
        #pack $lbent -side top -padx 5 -pady 5
        pack $lbent -side left -fill x -padx 5 -pady 5
        pack $btn -side left -padx 5 -pady 5
        pack $tf -side top -fill x -expand false -anchor center -padx 20
        my configure {*}$args
        if {[my cget -filename] ne ""} {
            my file_open [my cget -filename]
        }
        if {[my cget -pane] eq "vertical"} {
            $pw add $img
        } else {
            $pw2 add $img2
        }
        pack $pw -side top -fill both -expand true -padx 5 -pady 5
    }
    method ToggleLayout {} {
        if {[llength [$pw panes]] > 1} {
            $pw forget [lindex [$pw panes] end]
            $pw2 add $img2
        } else {
            $pw2 forget [lindex [$pw2 panes] end]
            $pw add $img
        }
    }
    #' 
    #' ## <a name='commands'></a>WIDGET COMMANDS
    #' 
    #' Each **paul::imedit** widget supports its own as well via the 
    #' *pathName labentry cmd*, *pathName text cmd*  and *pathName label* syntax 
    #' all the commands of its component widgets.
    #' 
    #' *pathName* **button** *?args?*
    #' 
    #' > Delegates all given methods to the internal ttk::button, if no argument is
    #'   given returns the widget itself
    
    # expose the internal widgets using subcommands
    method button {args} {
        if {[llength $args] == 0} {
            return $btn
        }
        $btn {*}$args
    }
    #'
    #' *pathName* **execute** 
    #'
    #' > Execute the command entered in the entry widget using the text which is written
    #'   into text widget. The commandline entered in the entry widget should contain place holders
    #'   for the input file (%i) and a possible output file (%o). 
    #'   If you need the filename without the file extension you can use %b. 
    #'   If the command does not need an output filename
    #'   because it creates an filename based on the input file with the png extension automatically
    #'   added, then no output filename is required.
    #'
    method execute { } {
        variable lastdir
        my configure -commandline [my labentry entry get]
        my file_save
        set savefile [my cget -filename]
        if {$savefile ne ""} {
            set imgfile [file rootname $savefile].png
            set optfile [file rootname $savefile].opt
            set ocmd [my labentry entry get]
            set cmd [regsub -all {%i} $ocmd $savefile]
            set cmd [regsub -all {%o} $cmd $imgfile]
            set cmd [regsub -all {%b} $cmd [file rootname $imgfile]]
            set command [split $cmd &]
            foreach cmd $command {
                if {[catch {
                     eval exec $cmd
                 }]} {
                   if {[my cget -statuslabel] ne ""} {
                       set status [my cget -statuslabel]
                       $status configure -text [lindex [split $::errorInfo "\n"] 0] -foreground red
                       update idletasks
                       after 2000
                       $status configure -foreground black
                       return
                   }
                }
            }
            image create photo appimg -file $imgfile
            $img configure -image appimg
            $img2 configure -image appimg            
            set out [open $optfile w 0600]
            puts $out $ocmd
            close $out
            if {[my cget -statuslabel] ne ""} {
                [my cget -statuslabel] configure -text "Success: file '[file tail $imgfile]' written!"
            }
            return $imgfile
        }
        return ""
    }
    #' *pathName* **file_new**
    #'
    #' > Creates a new emtpy file, the internal filename will be configured to new.
    #'
    method file_new {} {
        $txt file_new
        my configure -filename new
    }
    #' *pathName* **file_open** *?filename?*
    #'
    #' > Open the given file in the text widget. If no filename is given will either use the configured filename or if this
    #'   is as well not given opens a file dialog for selecting a file.
    #'
    method file_open {{filename ""}} {
        
        if {$filename eq ""} {
            set filename [$txt file_open]
        } else {
            set filename [$txt file_open $filename]
        }
        my configure -filename $filename
        my optfile_read
        if {[my cget -statuslabel] ne ""} {
            [my cget -statuslabel] configure -text "File: '[file tail $filename]' opened!"                   
        }
        if {[file exists [file rootname $filename].png]} {
            my image_display [file rootname $filename].png
        }
        return $filename
    }
    #' 
    #' *pathName* **file_save**  *?filename?*
    #'
    #' > Saves the current file.
    method file_save {{filename ""}} {
        if {($filename eq "" && [my cget -filename] eq "") || [my cget -filename] eq "new"} {
            set filename [$txt file_save_as]
        } elseif {$filename eq ""} {
            set filename [$txt file_save [my cget -filename]]
        } else {
            set filename [$txt file_save $filename]
        }
        my configure -filename $filename
        if {[my cget -statuslabel] ne ""} {
            [my cget -statuslabel] configure -text "File: '[file tail $filename]' saved!"                   
        }
        return $filename
    }
    #' 
    #' *pathName* __file\_save\_as__ *?intialfile?*
    #'
    #' > Ask for a new filename and save the content of the text widget to it.
    #'   If intialfile argument is given sets this as the default for saving.
    #'
    method file_save_as {{initialfile ""}} {
        set filename [$txt file_save_as $initialfile]
        my configure -filename $filename
        my optfile_read [file extension $filename]
        if {[my cget -statuslabel] ne ""} {
            [my cget -statuslabel] configure -text "File: '[file tail $filename]' saved!"                   
        }

        return $filename
    }
    #'
    #'
    #' *pathName* **image_display** *imgfile*
    #' 
    #' > Displays the given image file in the label.
    method image_display {imgfile} {
        variable img
        variable img2
        image create photo appimg -file $imgfile
        $img configure -image appimg
        $img2 configure -image appimg
    }
    #'
    #' *pathName* **label** *?args?*
    #' 
    #' > Delegates all given methods to the internal ttk::label widget, if no argument is
    #'   given returns the widget itself
    # expose the internal widgets using subcommands
    method label {args} {
        variable img
        variable img2
        if {[my cget -pane] eq "vertical"} {
            if {[llength $args] == 0} {
                return $img
            }
            $img {*}$args
        } else  {
            if {[llength $args] == 0} {
                return $img2
            }
            $img2 {*}$args
        }
    }
    #' 
    #' *pathName* **labentry** *?args?*
    #' 
    #' > Delegates all given methods to the internal pauL::labentry widget, if no argument is
    #'   given returns the widget itself
    
    # expose the internal widgets using subcommands
    method labentry {args} {
        if {[llength $args] == 0} {
            return $lbent
        }
        $lbent {*}$args
    }
    #'
    #' *pathName* **optfile_init**
    #'
    #' > Initializes a folder imedit into the user configuation folder, on Unix usually .config
    #'   where for every file extension .dot, .pml, .r, .pik, .sgf etc an file with the extension
    #'  opt is created. These files contain the default command line argument for the given
    #'  file type. Users can place there own defaults in this folder.
    #'
    method optfile_init {} {
        set configfolder [file join $::env(HOME) .config imedit]
        if {![file isdir $configfolder]} {
            file mkdir $configfolder
        }
        foreach key [array names defaults] {
            if {![file exists [file join $configfolder $key.opt]]} {
                set out [open [file join $configfolder $key.opt] w 0600]
                puts $out $defaults($key)
                close $out
            }
        }
        foreach file [glob -nocomplain $configfolder/*] {
            if  {[file extension $file] eq ".opt"} {
                if [catch {open $file r} infh] {
                    return error -code "Cannot open $file: $infh"
                } else {
                    set cmd [string trim [read $infh]]
                    close $infh
                    set ext [file rootname [file tail $file]]
                    set defaults($ext) $cmd
                }
            }
        }
    }
    #' *pathName* **optfile_read** *?ext?*
    #'
    #' > Reads for the current loaded file or for the given extension *ext* the default command line
    #'   arguments and fills with this the entry widget. If no defaults are found for the current
    #'   file type it intializes to `your-command %i %o".
    #'
    method optfile_read {{ext ""}} {
        set opt "your-command %i %o"
        if {$ext ne ""} {
            if {[string range $ext 0 0] eq "."} {
                set ext [string range $ext 1 end]
            }
            if {[info exists defaults($ext)]} {
                set opt $defaults($ext)
            }  
        } else {
            set filename [my cget -filename] 
            if {$filename ne ""} {
                set optfile [file rootname $filename].opt
                set extension [string range [file extension $filename] 1 end]
                if {[file exists $optfile]} {
                    if [catch {open $optfile r} infh] {
                        return error -code "Cannot open $optfile: $infh"
                    } else {
                        set opt [string trim [read $infh]]
                        close $infh
                    }
                } elseif {[info exists defaults($extension)]} {
                    set opt $defaults($extension)
                }
            }
        }
        my labentry entry delete 0 end
        my labentry entry insert 0 $opt
        return $opt
    }
    #' *pathName* **text** *?args?*
    #' 
    #' > Delegates all given methods to the internal tk::text widget, if no argument is
    #'   given returns the widget itself
    method text {args} {
        if {[llength $args] == 0} {
            return $txt
        }
        $txt {*}$args
    }
    
    method configure {args} {
        next {*}$args
        my labentry configure -labeltext [my cget -labeltext]
        my labentry delete 0 end
        my labentry entry insert 0 [my cget -commandline]
    }
    # you could as well delegate all methods to the text widget
    # making it your default widget
    method unknown {args} {
        $txt {*}$args
    } 
}
#' 
#' ## <a name='example'></a>EXAMPLE
#' 
#' ```{.tcl eval=true results="hide"}
#' package require paul
#' wm title . DGApp
#' ttk::label .lb -text "..."
#' pack [paul::imedit .ie -commandline "dot -Tpng %i -o %o" -statuslabel .lb -pane vertical]  \
#'       -side top -fill both -expand yes \
#'  
#' .ie labentry configure -labeltext "Command Line: "
#' .ie text insert 1.0 "digraph g { A -> B } \n"
#' pack .lb -side top -fill x -padx 5 -pady 5
#' update idletasks
#' 
#' #after 10000 exit
#' ```
#' 
#' ## <a name='see'></a>SEE ALSO
#'
#' - [oowidgets](../oowidgets/oowidgets.html)
#' - [paul::labentry](labentry.html)
#' - [ttk::entry](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_entry.htm)
#' - [ttk::label](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_entry.htm)
#' - [ttk::text](https://www.tcl.tk/man/tcl8.6/TkCmd/text.htm)
#'
#' ## <a name='authors'></a>AUTHOR
#'
#' The **paul::imedit** widget was written by Detlef Groth, University of Potsdam, Germany.
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2025  Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' ## <a name='license'></a>LICENSE
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```

if {[info exists argv0] && $argv0 eq [info script] && [regexp imedit $argv0]} {
    lappend auto_path [file join [file dirname [info script]] ..]
    package require paul
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [package version paul]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {
        set code [::paul::getExampleCode [info script]]
        eval $code
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        set code [::paul::getExampleCode [info script]]
        puts $code
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license")} {
        puts [::paul::getLicense [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--markdown")} {
        puts [::paul::getMarkdown [info script]]
        destroy .
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The paul::imedit class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2025  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::labentry class provides a combined label and entry"
        puts "                   widget usually used to label an antry widget with text on the left."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --license : printing the license to the terminal"
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "\n\n      Hint: You can read the documentation like this:\n"
        puts "         tclsh [info script]  --man | pandoc -f Markdown -t plain | less"
        puts "         tclsh [info script]  --man | pandoc -f Markdown -t html | w3m -T text/html -"
        puts ""
    }
}
