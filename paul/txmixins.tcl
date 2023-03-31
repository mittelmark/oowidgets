#' ---
#' title: paul::tx - mixins for the tk::text widget
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : 2023-03-31 08:01
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
#' > **paul::tx** - oo::class mixins for the tk::text widget
#' 
#' > The following mixins are implemented:
#' 
#' > - [paul::txautorep](#txautorep) - abbreviation tool for text widgets
#'   - [paul::txindent](#txindent) - automatic indentation for text widgets
#'   - [paul::txunicode](#txunicode) - entering Unicode characters
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
#' package require tkoo
#' set txt [tkoo::text pathName ?option value ...?
#' oo::objdefine $txt mixin Mixin ?Mixin ...?
#' pack $txt
#' ```
#' 
#' ## MIXINS
#' 
#' <a name="txautorep"></a>**paul::txautorep** -  *oo::objdefine pathName mixin paul::txautorep*
#' 
#' Adds abbreviation support to an existing *tkoo::text* widget, which is a wrapper for the *tk::text* widget using the Tk window id _pathName_ .
#' The widget indents every new line based on the initial indention of the previous line.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/auto-indent started by Richard Suchenwirth.
#'
#' Example:
#' 
#' > ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txt2 -background salmon]
#' oo::objdefine $txt mixin ::paul::txautorep
#' $txt autorep [list (TM) \u2122 (C) \u00A9 (R) \u00AE (K) \u2654]
#' $txt insert end "# Autorep Example\n\n"
#' foreach col [list A B C] { 
#'    $txt insert  end "# Header $col\n\n   Some more text.\n\n"
#' }
#' $txt insert end "  * item 1\n  * item 2\n  * Write (DG) and press enter\n  * "
#' pack $txt -side top -fill both -expand yes
#' > ```
#' 

::oo::class create ::paul::txautorep {
    variable automap 
    method autorep {{abbrev ""}} {
        set w [my widget]
        set automap [list (DG) {Detlef Groth\nUniversity of Potsdam}]
        array set opts $abbrev 
        foreach key [array names opts] {
            lappend automap $key
            lappend automap $opts($key)
        }
        bind $w <KeyRelease-parenright> [mymethod Autochange %W]
    }
    method Autochange {win} {
        variable textw
        set w $win
        foreach {abbrev value} $automap {
            puts $abbrev
            set n [string length $abbrev]
            if {[$w get "insert-$n chars" insert] eq $abbrev} {
                $w delete "insert-$n chars" insert
                $w insert insert [regsub -all {\\n} $value "\n"]
                break
            }
        }
    }
}
#'
#' <a name="txindent"></a>**paul::txindent** -  *oo::objdefine pathName mixin paul::txindent*
#' 
#' Adds indenting capabilities to an existing *tkoo::text* widget, which is a wrapper for the *tk::text* widget using the Tk window id _pathName_ .
#' The widget indents every new line based on the initial indention of the previous line.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/auto-indent started by Richard Suchenwirth.
#'
#' Example:
#' 
#' > ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txt -background skyblue]
#' foreach col [list A B C] { 
#'    $txt insert  end "# Header $col\n\n   Some more text.\n\n"
#' }
#' $txt insert end "  * item 1\n  * item 2 (press return here)"
#' oo::objdefine $txt mixin paul::txindent
#' $txt indent
#' pack $txt -side top -fill both -expand yes
#' > ```
#' 

::oo::class create ::paul::txindent {
    method indent {} {
        set w [my widget]
        bind $w <Return> "[mymethod iindent]; break"
    }
    method iindent {{extra "    "}} {
        set w [self]
        puts "w is $w"
        set lineno [expr {int([$w index insert])}]
        set line [$w get $lineno.0 $lineno.end]
        regexp {^(\s*)} $line -> prefix
        if {[string index $line end] eq "\{"} {
            tk::TextInsert $w "\n$prefix$extra"
        } elseif {[string index $line end] eq "\}"} {
            if {[regexp {^\s+\}} $line]} {
                $w delete insert-[expr [string length $extra]+1]c insert-1c
                tk::TextInsert $w "\n[string range $prefix 0 end-[string length $extra]]"
            } else {
                tk::TextInsert $w "\n$prefix"
            }
        } else {
            tk::TextInsert $w "\n$prefix"
        }
    }
    #unexport iindent
}

#'
#' <a name="txunicode"></a>**paul::txunicode** -  *oo::objdefine pathName mixin paul::txtunicode*
#' 
#' Adds the capability to enter Unicode symbols to an existing *tkoo::text* widget, which is a wrapper for the *tk::text* widget using the Tk window id _pathName_ .
#' If the user presses the default Keystroke Control-u he/she can enter after typing the four Unicode numbers
#' Unicode characters.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/Entering+Unicode+characters+in+a+widget
#'
#' Example:
#' 
#' > ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txtu -background grey80 -font "Courier 18"]
#' $txt insert  end "Press Ctrl-Shift-u and then therafter 4 numbers like 2602\n\n"
#' oo::objdefine $txt mixin paul::txunicode
#' $txt unicode Control-Key-U
#' pack $txt -side top -fill both -expand yes
#' > ```
#' 
namespace eval ::paul::unicode { 
    variable uc_keys
}

proc ::paul::unicode::enable_unicode_entry {widget} {
    variable uc_keys
    set uc_keys($widget) {}
    puts enabled
}

proc ::paul::unicode::disable_unicode_entry {widget} {
    variable uc_keys
    unset -nocomplain uc_keys($widget)
}
proc ::paul::unicode::handle_uc_key {widget key} {
    variable uc_keys
    if {![info exists uc_keys($widget)]} {
        return
    }
    
    upvar 0 uc_keys($widget) keys
    switch -glob -- [string toupper $key] {
        {[0-9A-F]} {
            append keys $key
            if {[string length $keys] >= 4} {
                $widget insert insert [subst \\u$keys]
                disable_unicode_entry $widget
            }
            return -code break
        }
        default {
            $widget insert insert $keys
            disable_unicode_entry $widget
        }      
    }        
}


::oo::class create ::paul::txunicode {
    method unicode {{keypress Control-Key-u}} {
        set w [my widget]
        bindtags $w [list $w UnicodeEntry Text . all]
        bind UnicodeEntry <$keypress> [list ::paul::unicode::enable_unicode_entry %W]
        bind UnicodeEntry <Key> [list ::paul::unicode::handle_uc_key %W %A]
    }
}


if {false} {
    package require Tk
    package require oowidgets
    package require tkoo

    set txt [tkoo::text .t -background salmon]
    oo::objdefine $txt mixin paul::txindent paul::txautorep 
    $txt indent
    pack $txt -side top -fill both -expand true
    $txt autorep [list (TM) \u2122]
}

#' ## <a name='see'></a> SEE ALSO
#'
#' - [oowidgets](../oowidgets.html)
#' - [paul::basegui.tcl](basegui.html)
#'
#' ## <a name='authors'></a> AUTHOR
#'
#' The **paul::tx** mixins were written by Detlef Groth, Schwielowsee, Germany.
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


