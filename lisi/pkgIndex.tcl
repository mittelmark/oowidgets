if {![package vsatisfies [package provide Tcl] 8.6-]} {return}

package ifneeded lisi 0.0.2 [list source [file join $dir lisi.tcl]]
