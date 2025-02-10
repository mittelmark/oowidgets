#!/usr/bin/env tclsh
#' ---
#' title: paul::statusbar documentation
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : <250210.0849>
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
#' include paul/header.html
#' ```
#' 
#' ## NAME
#'
#' **paul::statusbar** - statusbar widget for Tk applications based on a ttk::label and a ttk::progressbar widget
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
#' paul::statusbar pathName options
#' pathName configure -textvariable varname
#' pathName configure -variable varname
#' pathName clear 
#' pathname progress value
#' pathName set message value
#' ```
#'
#' ## <a name='description'></a>DESCRIPTION
#' 
#' **paul::statusbar** - is a composite widget consisiting of a ttk::label and a ttk::progressbar widget. 
#' It should be normally packaged at the bottom of an application.
#' The text and the numerical progress value can be displayed either directly 
#' using the widget commands or via the *-textvariable* and *-variable* options which  will be given at initialization time, 
#' but these options can be also redefined at a later point.

#'
#' ## <a name='command'></a>COMMAND
#'
#' **paul::statusbar** *pathName ?options?*
#' 
#' > Creates and configures a new paul::statusbar widget  using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'></a>WIDGET OPTIONS
#' 
#' The **paul::statusbar** widget is a composite widget where the options 
#' are delegated to the original widgets.

package require Tk
package require oowidgets

namespace eval ::paul {}

oowidgets::widget ::paul::Statusbar {
    #' 
    #'   __-maximum__ _value_ 
    #' 
    #'  > A floating point number specifying the maximum -value. Defaults to 100. 
    #'
    #'   __-textvariable__ _varname_ 
    #' 
    #'  > delegate the variable _varname_ to the ttk::label
    #' 
    #'   __-variable__ _varname_ 
    #' 
    #'  > delegate the variable _varname_ to the ttk::progressbar. Note that the maximum value is 100. 
    #'    So you have to calculate the
    variable pbar
    variable lab
    constructor {path args} {
        my install ttk::frame $path -maximum 100 -textvariable "" -variable "" -text ""
        set lab [::ttk::label $path.lab -relief sunken -anchor w -width 50 -padding 4]
        set pbar [::ttk::progressbar $path.pb -length 60 -mode determinate]
        pack $lab -side left -fill x -expand true -padx 4 -pady 2
        pack $pbar -side right -fill none -expand false -padx 4 -pady 2
        my configure {*}$args
    }
    #' 
    #' ## <a name='commands'></a>WIDGET COMMANDS
    #' 
    #' Each **paul::statusbar** widget supports its own as well via the *pathName label cmd* and *pathName progressbar cmd* syntax all the commands of its component widgets.
    #' 
    #' *pathName* **clear** *message ?value?*
    #' 
    #' > Removes the message from the label and sets to progressbar to zero.
    method clear {} {
        my set "" 0
        update idletasks
    }
    #' 
    #' *pathName* **label** *cmd ?option value ...?*
    #' 
    #' > Allows access to the commands of the embedded ttk::label widget. 
    #'   Via configure and cget you can as well configure this internal widget. 
    #'   For details on the available methods and options have a look at the 
    #'   ttk::label manual page.
    #' 
    #' *pathName* **progress** *value*
    #' 
    #' > Sets the progressbar to the given value.
    method progress {value} {
        $pbar configure -value $value
        update idletasks
    }
    #' 
    #' *pathName* **set** *message ?value?*
    #' 
    #' > Displays the given message and value. If the value is not given it
    #'   is set to zero.
     method set {msg {value 0}} {
        $lab configure -text $msg
        if {$value > 0} {
            my progress $value
        }
        update idletasks
    }
    method configure {args} {
        if {[llength $args] < 2} {
            return [next {*}$args]
        } else {
            #next {*}$args
            array set opts $args
            foreach key [array names opts] {
                if {$key in [list "-foreground" "-textvariable" "-text"]} {
                    $lab configure $key $opts($key)
                } elseif {$key in [list "length" "-mode" "-value" "-maximum" "-variable"]} {
                    $pbar configure $key $opts($key)
                }
            }
        }
    }
}

#' 
#' ## <a name='example'></a>EXAMPLE
#' 
#' ```{.tcl eval=true results="hide"}
#' package require paul
#' wm title . DGApp
#' pack [text .txt] -side top -fill both -expand yes
#' set stb [paul::statusbar .stb]
#' pack $stb -side top -expand false -fill x
#' $stb progress 50
#' $stb set Connecting....
#' after 1000
#' $stb set "Connected, logging in..."
#' $stb progress 50
#' after 1000
#' $stb set "Login accepted..." 
#' $stb progress 75
#' after 1000
#' $stb set "Login done!" 90
#' after 1000
#' $stb set "Cleaning!" 95
#' after 1000
#' $stb set "" 100
#' set msg completed
#' set val 90
#' $stb configure -textvariable msg
#' $stb configure -variable val
#' update idletasks
#' after 1000 exit
#' ```
#'
#' ## <a name='see'></a>SEE ALSO
#'
#' - [oowidgets](../oowidgets/oowidgets.html)
#' - [ttk::progressbar](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_progressbar.htm)
#'
#' ## <a name='authors'></a>AUTHOR
#'
#' The **paul::statusbar** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2019-2024  Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' ## <a name='license'></a>LICENSE
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```
if {[info exists argv0] && $argv0 eq [info script] && [regexp statusbar $argv0]} {
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
        puts "     The paul::statusbar class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-2024  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::statusbar class provides a combined label and progressbar"
        puts "                   widget usually displayed at bottom of your application."
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
