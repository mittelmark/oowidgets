
if {![package vsatisfies [package provide Tcl] 8.6]} {return}

package ifneeded paul 0.2.2 [list source [file join $dir paul.tcl]]

