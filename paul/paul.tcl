package require Tk
package require TclOO
package provide paul 0.1

# some generic utilities

namespace eval ::paul {
    # styles
    ttk::style layout ToolButton [ttk::style layout TButton]
    ttk::style configure ToolButton [ttk::style configure TButton]
    ttk::style configure ToolButton -relief groove
    ttk::style configure ToolButton -borderwidth 2
    ttk::style configure ToolButton -padding {2 2 2 2} 
    ttk::style configure Treeview -background white
    option add *Text.background    white
}


# simple timer
oo::class create ::paul::Timer {
    variable time
    constructor {} {
        set time [clock seconds]
    }
    method seconds {} {
        set now [clock seconds]
        return [expr {$now-$time}]
    }
    method reset {} {
        set time [clock seconds]
    }
}

# not required for Tcl 8.7 very likely
if {![package vsatisfies [package provide Tcl] 8.7]} {
    proc ::oo::Helpers::callback {method args} {
        list [uplevel 1 {namespace which my}] $method {*}$args
    
    }
}

source [file join [file dirname [info script]] statusbar.tcl] 
source [file join [file dirname [info script]] basegui.tcl] 
source [file join [file dirname [info script]] dlabel.tcl] 

