#' ---
#' title: paul::dlabel - label with dynamic font size
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : <240513.0946>
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
#' > **paul::dlabel** - label with fontsize adaptation
#'
#' ## <a name='synopsis'></a> SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' package require paul
#' ```
#' 
#' ```
#' package require paul
#' paul::dlabel pathName -text TEXT ?-option value ...?
#' pack cmdName
#' ```
#' 
#' ## COMMAND
#' 
#' <a name="dlabel"></a>
#' **paul::dlabel** *pathName*
#' 
#' > Creates a ttk::label where the font size is dynamically adjusted to the widget size.
#'
#' ## OPTIONS
#' 
#' All options of a standard ttk::label are supported.
#' 
#' ## METHODS
#' 
#' All methods of a standard ttk::label are supported.
#' 
#' ## EXAMPLE
#'
#' > ```{.tcl eval=true}
#' package require paul
#' wm title . DGApp
#' set app [paul::basegui new]
#' font create title -family Helvetica -size 10
#' puts [winfo children .]
#' set frame [$app getFrame]
#' set txt " Some Title "
#' set dlab [paul::dlabel $frame.l -text $txt]
#' pack  $dlab -expand 1 -fill both
#' wm geometry . 400x300+0+0
#' > ```
#' 

package require oowidgets

namespace eval paul { }

oowidgets::widget  ::paul::Dlabel {
    variable label
    constructor {path args} {
        my install ttk::label $path \
              -font [font create {*}[font configure TkDefaultFont]] \
              -text Default
        my configure {*}$args
        set label $path
        bind  $label <Configure> [callback ConfigureBinding %W %w %h] 
    }
    method AdjustFont {width height} {
        set cw [font measure [my cget -font] [my cget -text]]
        set ch [font metrics [my cget -font]]
        set size [font configure [my cget -font] -size]
        # shrink
        set shrink false
        while {true} {
            set cw [font measure [my cget -font] [my cget -text]]
            set ch [font metrics [my cget -font]]
            set size [font configure [my cget -font] -size]

            if {$cw < $width && $ch < $height} {
                break
            }
            incr size -2
            font configure [my cget -font] -size $size
            set shrink true
        }
        # grow
        while {!$shrink} {
            set cw [font measure [my cget -font] [my cget -text]]
            set ch [font metrics [my cget -font]]
            set size [font configure [my cget -font] -size]
            if {$cw > $width || $ch > $height} {
                incr size -2 ;#set back
                font configure [my cget -font] -size $size
                break
            }
            incr size 2
            font configure [my cget -font] -size $size
        }
    }
    method ConfigureBinding {mwin width height} {
        bind $mwin <Configure> {}
        my AdjustFont $width $height
        after idle [list bind $mwin <Configure> [callback ConfigureBinding %W %w %h]]
    }
}

#' ## <a name='see'></a> SEE ALSO
#'
#' - [oowidgets](../oowidgets.html)
#' - [paul::basegui.tcl](basegui.html)
#'
#' ## <a name='authors'></a> AUTHOR
#'
#' The **paul::statusbar** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2021-2023  Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' ## <a name='license'></a>LICENSE 
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```

if {[info exists argv0] && $argv0 eq [info script] && [regexp dlabel $argv0]} {
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
        puts "     The paul::dlabel class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-2024  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::dlabel class provides a label widget which resizes dynamically"
        puts "                   the font size based on the available space."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --license : printing the license to the terminal"
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "\n\n      Hint: You can read the documentation like this:\n"
        puts "         tclsh paul/basegui.tcl  --man | pandoc -f Markdown -t plain | less"
        puts "         tclsh paul/basegui.tcl  --man | pandoc -f Markdown -t html | w3m -T text/html -"
        puts ""
    }
}


