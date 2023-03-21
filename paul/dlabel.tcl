#' ---
#' title: paul::dlabel - label with dynamic font size
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : <230321.1505>
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
#' > **paul::dlabel** - label with fonts ize adaptation
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
#' <a name="dlabel">**paul::dlabel** *pathName*</a>
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

#' ## <a name='see'>SEE ALSO</a>
#'
#' - [oowidgets](../oowidgets.html)
#' - [paul::basegui.tcl](basegui.html)
#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **paul::statusbar** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2021-2023  Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' ## <a name='license'>LICENSE</a>
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```


