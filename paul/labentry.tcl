#!/usr/bin/env tclsh
#' ---
#' title: paul::labentry documentation
#' author: Detlef Groth, University of Potsdam, Germany
#' Date : <250206.0548>
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
#' **paul::labentry** - labendtry widget for Tk applications based on a ttk::label and a ttk::entryr widget.
#' This is a proof of principle example widget, kept as easy as possible.
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
#' paul::labentry pathName options
#' pathName label configure -textvariable varname
#' pathName entry configure -textvariable varname
#' ```
#'
#' ## <a name='description'></a>DESCRIPTION
#' 
#' **paul::labentry** - is a composite widget consisiting of a ttk::label and a ttk::entry.
#' It should serve as an illustration for a simple composite widget based on two widgets packed
#' into a ttk::frame. It as well illustrated create new configure options, here --labeltext.
#' which are delegated to one of the widgets and adding subwidget commands, here _label_ abd _entry_.
#' One of  the widgets is the main widget where all methods are delegated to.
#'
#' ## <a name='command'></a>COMMAND
#'
#' **paul::labentry** *pathName ?options?*
#' 
#' > Creates and configures a new paul::labentry widget  using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'></a>WIDGET OPTIONS
#' 
#' The **paul::labentry** widget is a composite widget where the options 
#' are delegated to the original widgets. In addition to the default options the following option(s)
#' are added:
#'
#' __-labeltext__ - the text which should be displayed on the label:
package require oowidgets
namespace eval ::paul { }
oowidgets::widget ::paul::LabEntry {
    variable ent
    variable lab
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my install ttk::frame $path -labeltext ""
        set lab [ttk::label $path.lab]
        set ent [ttk::entry $path.ent]
        pack $lab -side left -padx 5 -pady 5
        pack $ent -side left -padx 5 -pady 5
        my configure {*}$args
    }
    #' 
    #' ## <a name='commands'></a>WIDGET COMMANDS
    #' 
    #' Each **paul::labentry** widget supports its own as well via the 
    #' *pathName label cmd* and *pathName entry cmd* syntax all the commands of its component widgets.
    #' 
    #' *pathName* **label** *?args?*
    #' 
    #' > Delegates all given methods to the internal label widget, if no argument is
    #'   given returns the widget itself
    
    # expose the internal widgets using subcommands
    method label {args} {
        if {[llength $args] == 0} {
            return $lab
        }
        $lab {*}$args
    }
    #' *pathName* **entry** *?args?*
    #' 
    #' > Delegates all given methods to the internal entry widget, if no argument is
    #'   given returns the widget itself
    method entry {args} {
        if {[llength $args] == 0} {
            return $ent
        }
        return [$ent {*}$args]
    }
    method configure {args} {
        next {*}$args
        my label configure -text [my cget -labeltext]
    }
    # you could as well delegate all methods to the entry widget
    # making it your default widget
    method unknown {args} {
        $ent {*}$args
    } 
}
#' 
#' ## <a name='example'></a>EXAMPLE
#' 
#' ```{.tcl eval=true results="hide"}
#' package require paul
#' proc getEntry { } {
#'    puts "text in entry:[.le entry get]"
#' }
#' wm title . DGApp
#' pack [paul::labentry .le] -side top -fill both -expand yes
#' .le label configure -text "Label: "
#' .le entry insert 0 hello
#' pack [ttk::button .btn -command getEntry -text "Check Entry Text"] -side top -padx 10 -pady 10 -fill x 
#' update idletasks
#' after 3000 exit
#' ```
#' 
#' ## <a name='see'></a>SEE ALSO
#'
#' - [oowidgets](../oowidgets/oowidgets.html)
#' - [ttk::entry](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_entry.htm)
#' - [ttk::label](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_entry.htm)
#'
#' ## <a name='authors'></a>AUTHOR
#'
#' The **paul::labentry** widget was written by Detlef Groth, University of Potsdam, Germany.
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2019-2025  Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' ## <a name='license'></a>LICENSE
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```

if {[info exists argv0] && $argv0 eq [info script] && [regexp labentry $argv0]} {
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
        puts "     The paul::labentry class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-2025  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
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
