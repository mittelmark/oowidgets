
if {![package vsatisfies [package provide Tcl] 8.6-]} {return}

package ifneeded oowidgets 0.5.0 [list source [file join $dir oowidgets.tcl]]
package ifneeded tkoo 0.5.0 [list source [file join $dir tkoo.tcl]]

