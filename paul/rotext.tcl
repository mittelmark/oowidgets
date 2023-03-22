#' ---
#' title: paul::rotext - readonly text widget 
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : <230322.0606>
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
#' > **paul::rotext** - read only text widget
#'
#' ## <a name='synopsis'></a> SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' package require paul
#' ```
#' 
#' > ```{.tcl}
#' package require paul
#' paul::rotext pathName ?-option value ...?
#' pathName ins TEXT
#' pack pathName
#' > ```
#' 
#' ## COMMAND
#' 
#' <a name="rotext"></a>**paul::rotext** *pathName*
#' 
#' > Creates a `tk::text` widget which is readonly, text can be only inserted and deleted using the `ins` and `del` methods but not the
#'   using 'insert' or 'delete' and as well not with the users keybord.
#'
#' ## OPTIONS
#' 
#' > All options of a standard `tk::text` widget are supported.
#' 
#' ## METHODS
#' 
#' > All methods of a standard tk::text are supported except for 'insert' and 'delete' which are replaced by 'ins' and 'del'.
#' 
#' ## EXAMPLE
#'
#' > ```{.tcl eval=true}
#' package require paul
#' wm title . DGApp
#' paul::rotext .text
#' .text ins end "This is some readonly text\nYou can't edit the text!"
#' pack .text -side top -fill both -expand true
#' wm geometry . 400x300+0+0
#' > ```
#' 

package require oowidgets
namespace eval ::paul { }

::oowidgets::widget ::paul::Rotext {
    variable textw
    constructor {path args} {
        # we need the real widget
        set textw ${path}_
        # Create the text widget; turn off its insert cursor
        my install tk::text $path -insertwidth 0 -border 5 -relief flat
        my configure {*}$args
    }
    # Disable the text widget's insert and delete methods
    # to make this readonly even if the user writes text.
    method insert {args} { } 
    method delete {args} { }
    # programmatically we can still insert and delete ...
    method ins {args} { $textw insert {*}$args  }
    method del {args} { $textw delete {*}$args  }
}
#' ## <a name='see'></a>SEE ALSO
#'
#' > - [oowidgets](../oowidgets.html)
#'   - [paul::basegui.tcl](basegui.html)
#'
#' ## <a name='authors'></a>AUTHOR
#'
#' > The **paul::rotext** widget was written by Detlef Groth, Schwielowsee, Germany.
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


