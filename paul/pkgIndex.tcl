
if {![package vsatisfies [package provide Tcl] 8.6]} {return}

package ifneeded paul 0.1 [list source [file join $dir paul.tcl]]

