set auto_path [linsert $auto_path 0  [file join [file dirname [info script]] ..]]
package require Tk
package require oowidgets

namespace eval ::comp {}
oowidgets::widget ::comp::Button {
    constructor {path args} {
          my install ttk::button $path -comptext text
          my configure {*}$args
    }
}

puts [info commands ::comp::*]
set fb1 [comp::button .fb1 -comptext test -width 20 \
    -text "Button1" ]
pack $fb1 -side top -padx 10 -pady 10 -ipady 20 -ipadx 20
puts "1: [$fb1 configure] \n"
