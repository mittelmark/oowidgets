#!/usr/bin/env tclsh
#' ---
#' title: paul::history 
#' author: Detlef Groth, University of Potsdam, Germany
#' date: 2025-02-25
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
#  Created By    : Dr. Detlef Groth
#  Created       : Mon Nov 5 07:21:48 2018
#  Last Modified : <250225.1036>
#
#' ## NAME
#'
#' **paul::history** - an oo class history command.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [OPTIONS](#options)
#'  - [METHODS](#commands)
#'  - [EXAMPLE](#example)
#'  - [TODO](#todo)
#'  - [AUTHOR](#author)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require paul
#' ::paul::history create cmd ?option value?
#' cmd back 
#' cmd canBackward
#' cmd canForward
#' cmd canFirst
#' cmd canLast
#' cmd cget option
#' cmd configure option value
#' cmd current
#' cmd first
#' cmd forward
#' cmd getHistory
#' cmd home
#' cmd insert value
#' cmd last
#' cmd resetHistory
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#'
#' The **paul::history** command provides a data structure to allow
#' the storage of text strings in a history. 
#' This can be useful to store for instance a browser history or a
#' move history in a board game like Chess or Go.
#'
#' ## <a name='options'>OPTIONS</a>
#'


namespace eval ::paul {}
catch {rename ::paul::history ""}
oo::class create ::paul::history {
    #' __-home__ value
    #'
    #' > The value which is set as the home, it is stored in principle
    #' as the first item in the history. Defaults to an empty string.
    variable index -1
    variable history
    variable options
    variable index
    constructor {args} {
        array set options [list -home ""]
        #puts $args
        array set options $args
        set history [list]
        set index -1
        set history [list]
    }
    #' 
    #' ## <a name='commands'>METHODS</a>
    #' 
    #' The **paul::history** class supports a few methods to navigate in a history list.
    #'
    
    #' *cmd* **back** 
    #' 
    #' > Walks back in history one step and retrieves the value of the history at this position.
    #' 
    
    method back {} {
        incr index -1
        return [lindex $history $index]
    }
    #' *cmd* **canBackward** 
    #' 
    #' > Returns true if the current position in history is not the first value in history
    #'   and if the length of history is greater than 1.
    #'
    method canBackward {} {
        if {$index > 0} {
            return true
        } else {
            return false
        }
    }
    #' *cmd* **canFirst** 
    #' 
    #' > Returns true if the current position in history is not the first value in history
    #'   and if history length is greater than 1.
    #'
    method canFirst {} {
        if {$index == 0} {
            return false
        } else {
            return true
        }
        
    }
    #' *cmd* **canForward** 
    #' 
    #' > Returns true if the current position in history is not the last value in history.
    #'
    method canForward {} {
        if {[llength $history] > [expr {$index+1}]} {
            return true
        } else {
            return false
        }
    }
    #' *cmd* **canLast** 
    #' 
    #' > Returns true if the current position in history is not the last value in history.
    #'
    method canLast {} {
        if {$index == [expr {[llength $history] -1}]} {
            return false
        } else {
            return true
        }
    }
    #' *cmd* **cget** *option*
    #' 
    #' > Retrieves the given option value for the shistory type. Curently only the *-home* 
    #'   option is available for *cget*.
    #'
    method cget {option} {
        if {[info exists options($option)]} {
            return $options($option)
        } else {
            error "Error: option $option does not exists. Available options are [join ærray names options ,]"
        }
    }
    #' *cmd* **configure** *option value ?option value ...?*
    #' 
    #' > Configures the given option for the shistory type. 
    #' Curently only the *-home* option is available for *configure*.
    #'
    method configure {args} {
        foreach {option value} {*}$args {
            if {[info exists options($option)]} {
                set options($option) $value
            } else {
                error "Error: option $option does not exists. Available options are [join ærray names options ,]"
            }
        }
    }
    #' *cmd* **current** 
    #' 
    #' > Retrieves the current value of the history.
    #'
    method current {} {
        return [lindex $history $index]
    }
    
    #' *cmd* **first** 
    #' 
    #' > Jumps to the first entry in history and returns it.
    #'
    method first {} {
        set index 0
        return [lindex $history $index]
    }
    #' *cmd* **forward** 
    #' 
    #' > Gos one step forward in history and returns the value there.
    #'
    method forward {} {
        # to check if possible
        incr index +1
        return [lindex $history $index]
    }
    #' *cmd* **getHistory** 
    #' 
    #' > Returns the history, a list of text entries.
    #'
    method getHistory {} {
        return $history
    }
    
    #' *cmd* **insert**  *value*
    #' 
    #' > Inserts the value in the history at the actual index.
    #'
    method insert {item} {
        set item [regsub {/$} $item ""]
        if {$item ne [lindex $history $index]} {
            incr index
            if {$item ne [lindex $history $index]} {
                set history [linsert $history $index $item]
            } else {
                incr index -1
            }
        }
        return $item
    }
    
    #' *cmd* **home** 
    #' 
    #' > Returns the home index value which was set using the _-home_ option.
    #'
    method home {} {
        return $options(-home)
    }
    
    method resetHistory {} {
        set index -1
        set history [list]

    }
    #' *cmd* **last** 
    #' 
    #' > Jumps to the last value in history and returns the value there.
    #'
    method last {} {
        set index [llength $history]
        incr index -1
        return [lindex $history $index]
    }
}


#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' ```{.tcl eval=true}
#' lappend auto_path .
#' package require paul
#' ### using create cmd args
#' ::paul::history create hs -home i
#' hs insert x
#' puts "hs: last [hs last]"
#' ### using new args 
#' set sh [::paul::history new -home h]
#' $sh insert a
#' $sh insert a ;# should not give duplicates
#' $sh insert a
#' $sh insert b
#' puts "canback: [$sh canBackward]"
#' puts "canforw: [$sh canForward]"
#' $sh back
#' $sh insert z
#' puts "getHistory: [$sh getHistory]"
#' puts "home: [$sh home]"
#' puts "last: [$sh last]"
#' ```
#'
#' ## <a name='todo'>TODO</a>
#'
#' * move tests to tests directory
#'
#' ## <a name='author'>AUTHOR</a>
#'
#' The **paul::history** class was written Detlef Groth, University of Potsdam, Germany.
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2018-2025  Detlef Groth, E-mail: dgroth(at)uni(minus)potsdam(dot)de
#' 
#' ## <a name='license'></a>LICENSE 
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```


if {[info exists argv0] && $argv0 eq [info script] && [regexp history $argv0]} {
    lappend auto_path [file join [file dirname [info script]] ..]
    package require paul
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [package version paul]
        destroy .
    } elseif {[llength $argv] >= 1 && [lindex $argv 0] eq "--demo"} {
        set section ""
        if {[llength $argv] == 2} {
            set section [lindex $argv 1]
        } 
        set code [::paul::getExampleCode [info script] $section]
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
        puts "     The paul::history class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2021-2025  Detlef Groth, E-mail: dgroth(at)uni(minus)potsdam(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::history class provides a data structure to manage"
        puts "history entries."
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
return
if {[info exists argv0] && $argv0 eq [info script] && [regexp {shistory} $argv0]} {
    set dpath dgtools
    set pfile [file rootname [file tail [info script]]]
    package require dgtools::dgtutils
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgtools::getVersion [info script]]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgtools::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgtools::install [info script]
    } else {
        puts "\n    -------------------------------------"
        puts "     The dgtools::[file rootname [file tail [info script]]] package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe dgtools::[file rootname [file tail [info script]]] package provides a list with text entries which can used as" 
        puts "history data structure for programmers of the Tcl/Tk Programming language"
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install shistory as Tcl module"        
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "        --markdown: printing the man page in simple markdown to the terminal"
        puts "        --html    : printing the man page in html code to the terminal"
        puts "                    if the Markdown package from tcllib is available"
        puts "        --version : printing the package version to the terminal"        
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [file tail [info script]] --man | pandoc -t html -s > temp.html\n"
        
    }

}
