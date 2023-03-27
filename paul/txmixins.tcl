#' 
#' <a name="txindent">**dgw::txindent**</a> *[tk::text pathName] ?-option value ...?*
#' 
#' Creates and configures the *dgw::txindent*  widget using the Tk window id _pathName_ and 
#' the given *options*. All options are delegated to the standard text widget. 
#' The widget indents every new line based on the initial indention of the previous line.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/auto-indent started by Richard Suchenwirth.
#'
#' Example:
#' 
#' > ```
#' # demo: txindent
#' dgw::txindent [tk::text .txt]
#' foreach col [list A B C] { 
#'    .txt insert  end "# Header $col\n\nSome text\n\n"
#' }
#' .txt insert end "  * item 1\n  * item 2 (press return here)"
#' pack .txt -side top -fill both -expand yes
#' > ```


::oo::class create ::paul::txindent {
    method indent {{extra "    "}} {
        set w [self]
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
}

::oo::class create ::paul::txautorep {
    variable automap 
    method installautorep {w args} {
        set automap [list (DG) {Detlef Groth\nUniversity of Potsdam}]
        array set opts $args 
        foreach {key value} $args {
            lappend automap [list $key $value] 
        }
        bind $w <KeyRelease-parenright> [mymethod autochange %W]
        puts $automap
    }
    method autochange {win} {
        variable textw
        puts "hello"
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

package require Tk
package require oowidgets
package require tkoo

set txt [tkoo::text .t -background salmon]
oo::objdefine $txt mixin paul::txindent paul::txautorep 

bind $txt <Return> "$txt indent; break"
pack $txt -side top -fill both -expand true
$txt installautorep $txt
#oo::objdefine $txt { mixin  } 
