#!/usr/bin/env tclsh
#' ---
#' title: paul::cb - mixin(s) for the ttk::combobox
#' author: Detlef Groth, University of Potsdam, Germany
#' Date : 2025-02-21
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
#' > **paul::cb** - mixins for the ttk::combobox
#' 
#' ## MIXINS
#'
#' > The following mixins are implemented:
#' 
#' > - [paul::cbfilter](#cbfilter) - filters the available entries by the entered text
#'
#' ## SYNOPSIS
#'
#' ```
#' package require paul
#' tkoo::combobox pathName ?-option value ...?
#' pathName paul::cbfilter
#' ```
#'
##############################################################################

package require Tk
package require oowidgets

namespace eval ::paul {}
catch { rename ::paul::cbfilter {} }
#' ## <a name='mixins'></a> MIXINS
#'
#' 
#' <a name="cbfilter"> </a> 
#' *pathName mixin* **cbfilter** 
#' 
#' > Adds the mixin *paul::cbfilter* for a *tkoo::combombox* using the Tk window id _pathName_.
#'
#' > This mixin filters the given values for the listbox by the already entered text and only
#'   displays matching entries.
#' 
#' > Example:
#' 
#' ```{.tcl eval=true}
#' # demo: combobox
#' lappend auto_path .
#' package require paul
#' wm title . "DGApp"
#' pack [label .l0 -text "standard combobox"]
#' ttk::combobox .c0 -values [list  done1 done2 dtwo dthree four five six seven]
#' pack .c0 -side top
#' pack [label .l1 -text "Mixin combobox"]
#' tkoo::combobox .c1 -values [list  done1 done2 dtwo dthree four five six seven]
#' .c1 mixin paul::cbfilter
#' pack .c1 -side top
#' ```

::oo::class create ::paul::cbfilter {
    variable Values
    variable win
    method cbfilter {} {
        set win [my widget]
        set Values [my cget -values]
        my configure -postcommand [mymethod Filter $win]
        ### not sure why we need to catch the click event
        ## as we got an error for some non existing variable w
        bind $win <Button-1> [mymethod Click %W %x %y]
    }
    method Click {w x y} {
        catch {ttk::combobox::Press 1 ${w} $x $y} result
        return -code break
    }
    method Filter {win} {
        set values $Values
        set text [string map [list {[} {\[} {]} {\]}] [$win get]]
        ${win} configure -values [lsearch -all -inline $Values $text*]
    }
    onconfigure -values value {
        set Values $value
        set options(-values) $value
        if {[winfo exists $win]} {
            ${win} configure -values $Values
        }
    }
    ### currently not used, just use Down to post the listbox
    method Post {win key} {
        if {$key in [list "Return" "Right"]} { return }
        if {[llength [my cget -values]] > 0} {
            ::ttk::combobox::Post $win
            foreach child [winfo children $win] {
                puts "$win $child"
            }
        } else {
            return
        }
        return
        if {$key ne "Down" && [llength [$win cget -values]] > 1} {
            after 100 [list focus $win]
        } elseif {$key eq "Down"} {
            set lb $win.popdown.f.l
            if {[winfo exists $lb]} {
                after 100 [list focus $lb]
            }
        }
    }
}
#' <a name='example'> </a>
#' ## EXAMPLE
#'
#' ```
#' # demo: combobox
#' package require paul
#' wm title . "DGApp"
#' pack [label .l0 -text "standard combobox"]
#' ttk::combobox .c0 -values [list  done1 done2 dtwo dthree four five six seven]
#' pack .c0 -side top
#' pack [label .l1 -text "Mixin combobox"]
#' tkoo::combobox .c1 -values [list  done1 done2 dtwo dthree four five six seven]
#' .c1 mixin paul::cbfilter
#' pack .c1 -side top
#' update idletasks
#' after 2000
#' ```
#'
#' ## <a name='see'></a> SEE ALSO
#'
#' - [oowidgets](../oowidgets/oowidgets.html)
#' - [paul::basegui.tcl](basegui.html)
#'
#' ## <a name='authors'></a> AUTHOR
#'
#' The **paul::cb** mixin(s) were written by Detlef Groth, University of Potsdam, Germany.
#' Much of the code was taken from the [Tclers Wiki](https://wiki.tcl-lang.org/) and made usuable in real applications
#' by myself by reorganizing the code and fixing possible issues.
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


if {[info exists argv0] && $argv0 eq [info script] && [regexp combobox $argv0]} {
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
        puts here
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
        puts "     The paul::combobox widget for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2021-2025  Detlef Groth, E-mail: dgroth(at)uni(minus)potsdam(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::combobox widget provides a ttk::combobox"
        puts "with a dropdown filter list."
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
