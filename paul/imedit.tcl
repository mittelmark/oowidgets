#!/usr/bin/env tclsh
#' ---
#' title: paul::imedit documentation
#' author: Detlef Groth, University of Potsdam, Germany
#' Date : <250202.0824>
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
#' This is a proof of principle example widget, to demonstrate the composition of a megawidget
#' based on a paul package megawidget and standard Tk widgets. The UML schema for this widget is
#' shown below:
#'
#' ![](https://kroki.io/plantuml/svg/eNptT1sOwiAQ_OcUG7_Uhgvw4Sm8ALakIaAlskZN07uXd7pN-WJnZmdnnOyNHBWcYJq-ehgV-vCfGYTXW-l9w2GGhS3MtQUnPzZpsy6OQuinGjQWgw5Q_fB8KYOVD2XJ9ML3PwDBdutRmezSQZURE5rlbjZJ0AgRD6fEBYpYWi01WivOb7uzR1yuxUhHft0vUjrwNckB0wKtKzJ6QQ==)
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
package require oowidgets
namespace eval ::paul { }
oowidgets::widget ::paul::ImEdit {
    variable lbent
    variable txt
    variable img
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my install ttk::frame $path -commandline "" -labeltext ""
        set lbent [paul::labentry $path.lbent]
        set pw [ttk::panedwindow $path.pw]
        set txt [tk::text $path.pw.txt]
        set img [tk::text $path.pw.img]
        $pw add $txt
        $pw add $img
        pack $lbent -side top -padx 5 -pady 5
        pack $pw -side top -fill both -expand true -padx 5 -pady 5
        my configure {*}$args
    }
    #' 
    #' ## <a name='commands'></a>WIDGET COMMANDS
    #' 
    #' Each **paul::imedit** widget supports its own as well via the 
    #' *pathName labentry cmd*, *pathName text cmd*  and *pathName label* syntax 
    #' all the commands of its component widgets.
    #' 
    #' *pathName* **label* *?args?*
    #' 
    #' > Delegates all given methods to the internal ttk::label widget, if no argument is
    #'   given returns the widget itself
    
    # expose the internal widgets using subcommands
    method label {args} {
        if {[llength $args] == 0} {
            return $img
        }
        $img {*}$args
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
#' pack [paul::imedit .ie -commandline "dot -Tpng %i -o %o"] -side top -fill both -expand yes 
#' .ie labentry configure -labeltext "Command Line: "
#' .ie text insert 1.0 "digraph g { A -> B } \n"
#' update idletasks
#' after 3000 exit
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
