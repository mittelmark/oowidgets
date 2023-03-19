
if {![package vsatisfies [package provide Tcl] 8.4]} {return}

package ifneeded oowidgets 0.1 [list source [file join $dir oowidgets.tcl]]

