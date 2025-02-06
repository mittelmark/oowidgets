#!/usr/bin/env tclsh
#' ---
#' title: paul::imedit documentation
#' author: Detlef Groth, University of Potsdam, Germany
#' Date : <250206.0547>
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
#' - __-labeltext__ - the text which should be displayed in the label widget left from the command line entry widget
#' - __pane__ - orientation of the paned window widget, either horizontal or vertical, default: vertical
#' - __-statuslabel__ - an optional label widget to display status messages
#' 
package require oowidgets
namespace eval ::paul { 
    image create photo ::paul::devscreen22 -data {
        R0lGODlhFgAWAIcAAPwCBAQCBPTy9PTu9Ozq7OTi5Nze3OTe5Nza3NzW3NTS
        1MzOzMzKzMzGzMTCxMTGxOzm7AwGDBQOFBQSFCQeHCwmLCwuLDQyNDw6PERC
        RFROVEQ+RDQ2NLy+vKSipISChGxqbExKTOzu7OTm5Pz+/GRiZMS+xLy6vBQW
        FLy2vCwiHFQ+NMSmfNSyhIxmTDwuLJx+bLS2tCwmHMyyhMyqfPTqpPzyvLSW
        bLSWfPzitIx+ZDw2PAwKDCQiJGxWRPTmrPTerMyuhPzqtPz63PTWnPz6zNy+
        nIRiVDQuLKyWbOTanPz21NS2jNS6lDQqJHRaTPzmrPTSnPzyxOTClPz2xNSu
        hPTqxPzuvOzSpAQGDOTKnMy2jOzSrPTu1NzKnOzOnBwWHJRuXLSWdPTatPzq
        vNzClCwmJOzSnOTOnPTuxOzKlOzerOzarOzitJR6ZNTO1IxmXPTWrNSyjPzO
        jPTSpLSehHRqZOzirOTCjPS+fPzGhOy6bOzKhGROPMy2lPz+1PzmtKRyRHRi
        NNTCdPz+zNzCjEQ2NKySdDQmJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAWABYAAAj/AAEIHEiwoMGB
        ARIqXMhQIUIBAwYQIFCggIEDCBIoULBgAYMGDgIIDEBAwMSKBRBk3NjxAciQ
        IwdACBBBwgQKFSxcwJBBwwYMHBx0EAmA5EwPH0CEsCChoYgOQ0cSGCHhA4kS
        S5syJGDiBNEAFVGUKKEBAwWFFM6SNJHi64gDFEKE4FBBggoKK1i0cPECxokY
        Xw0gsECYggQZM2jAqGHjBo4cOtqOxLhDAg8ePXz8ABJEyBAWRIoYOfJipEoM
        CZEkuaFkSAslS5jUGJKkSRAnRREo0JDwCZQoTKQAmUKlihQrVa5gKZ1lI+oA
        K7QM2cJlSZMuU4Z4+TJEx0iNOwKAggkjZkyOFmS8kClzpcUQLRRGbjRD4MgZ
        NEzSqKG+ZgobI2248dUbDDDwABzcxSEHEFpgEcUcdMRRhx1fFejAAx0cgcYd
        SxiBRx566LEHH0d8QFRRNC3Uhx985CHEH0MAEkhCBxWkgiCDFEFIEYUYUmON
        MhyCRxVH/PgjBYioYJAdAQEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8g
        dmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRz
        IHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
    }
}
oowidgets::widget ::paul::ImEdit {
    variable lbent
    variable txt
    variable btn
    variable img
    variable img2
    variable types
    variable lastdir 
    variable pw
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my install ttk::frame $path -commandline "" -labeltext "" -filename "" -statuslabel "" -pane vertical
        set types {
            {{Dot Files}        {.dot}        }
            {{PlantUML Files}   {.pml}        }                
            {{Text Files}       {.txt}        }
            {{All Files}        *             }
        }
        set lastdir [pwd]
        set tf [ttk::frame $path.tf]
        set lbent [paul::labentry $path.tf.lbent]
        $lbent entry configure -width 50
        set btn [ttk::button $path.tf.btn -text " Execute " -command [mymethod execute]]
        set pw [ttk::panedwindow $path.pw]
        set pw2 [ttk::panedwindow $path.pw2 -orient horizontal]
        #set tfr1 [ttk::frame $path.pw.fr]
        ## TODO - add scrollbars via guibaseclass autoscroll?
        set txt [tk::text $pw.txt]
        set peer [$txt peer create $pw2.text]
        
        set img [ttk::label $path.pw.img -anchor center -image ::paul::devscreen22]
        set img2 [ttk::label $path.pw2.img2 -anchor center -image ::paul::devscreen22]        
        $pw add $txt
        $pw add $img
        $pw2 add $peer
        $pw2 add $img2
        #pack $lbent -side top -padx 5 -pady 5
        pack $lbent -side left -fill x -padx 5 -pady 5
        pack $btn -side left -padx 5 -pady 5
        pack $tf -side top -fill x -expand false -anchor center -padx 20
        my configure {*}$args
        if {[my cget -filename] ne ""} {
            my file_open
        }
        if {[my cget -pane] eq "vertical"} {
            pack $pw -side top -fill both -expand true -padx 5 -pady 5
        } else {
            pack $pw2 -side top -fill both -expand true -padx 5 -pady 5
        }

    }
    #' 
    #' ## <a name='commands'></a>WIDGET COMMANDS
    #' 
    #' Each **paul::imedit** widget supports its own as well via the 
    #' *pathName labentry cmd*, *pathName text cmd*  and *pathName label* syntax 
    #' all the commands of its component widgets.
    #' 
    #' *pathName* **button* *?args?*
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
    #'   for the input file (%i) and a possible output file (%o). If the command does not need an output filename
    #'   because it creates an filename based on the input file with the png extension automatically
    #'   added, then no output filename is required.
    #'
    method execute { } {
        my configure -commandline [my labentry entry get]
        variable types
        variable lastdir
        set savefile [my cget -filename]
        if {$savefile eq ""} {
            unset -nocomplain savefile
            set savefile [tk_getSaveFile -filetypes $types -initialdir $lastdir]
        }
        if {$savefile != ""} {
            set content [my text get 1.0 end]
            set out [open $savefile w 0600]
            puts $out $content
            close $out
            my configure -filename $savefile
            set lastdir [file dirname $savefile]
            set imgfile [file rootname $savefile].png
            set optfile [file rootname $savefile].opt
            set ocmd [my labentry entry get]
            set cmd [regsub -all {%i} $ocmd $savefile]
            set cmd [regsub -all {%o} $cmd $imgfile]
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
            [my label] configure -image appimg
            set out [open $optfile w 0600]
            puts $out $ocmd
            close $out
            if {[my cget -statuslabel] ne ""} {
                [my cget -statuslabel] configure -text "Success: file '[file tail $imgfile]' written!"
            }
        }
    }
    #' *pathName* **file_open** *?filename?*
    #'
    #' > Open the given file in the text widget. If no filename is given will either use the configured filename or if this
    #'   is as well not given opens a file dialog for selecting a file.
    #'
    method file_open {{filename ""}} {
        variable txt
        variable lastdir
        $txt delete 1.0 end
        if {$filename eq "" && [my cget -filename] == ""} {
            set filename [tk_getOpenFile -filetypes $types -initialdir $lastdir]
        }
        if {$filename != ""} {
            if {[catch {open $filename r} infh]} {
                return -code error "File $fielname can't be opened!"
            } else {
                
                $txt insert 1.0 [read $infh]
                close $infh
            }
            set lastdir [file dirname $filename]
            my configure -filename $filename
        }
    }
    #' *pathName* **label* *?args?*
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
    #' *pathName* **labentry* *?args?*
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
#' pack [paul::imedit .ie -commandline "dot -Tpng %i -o %o" -statuslabel .lb -pane horizontal]  \
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
