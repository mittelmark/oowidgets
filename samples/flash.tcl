lappend auto_path [file join [file dirname [info script]] ..]
package require oowidgets

# Examples 

namespace eval ::flash {}
# create the wrapper function - creates proc flash::button
oowidgets::new ::flash::Button 

# implementation of a sample widget

oo::class create ::flash::Button {
    superclass oowidgets::BaseWidget

    constructor {path args} {
          my install ttk::button $path -flashtime 500
          my configure {*}$args
    }
    method flash {} {
        set ot [my cget -text]
        set ft [my cget -flashtime]
        for {set i 0} {$i < 5} {incr i} {
            my configure -text "......"
            update idletasks
            after $ft
            my configure -text $ot
            update idletasks
            after $ft
        }
        puts flashed
        my configure -text $ot
    }

}

#oowidgets::new ::flash::Label

oowidgets::widget ::flash::Label {
    constructor {path args} {
        my install ttk::label $path -flashtime 500
        my configure {*}$args
    }
    method flash {} {
        set fg [my cget -foreground]
        for {set i 0} {$i < 10} {incr i} {
            my configure -foreground blue
            update idletasks
            after [my cget -flashtime]
            my configure -foreground $fg
            update idletasks
            after [my cget -flashtime]
        }
        puts labelflashed
    }
}
# now a composite widget pack both widgets into a frame

oowidgets::widget ::flash::LabEntry {
    variable ent
    variable lab
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my install ttk::frame $path -labeltext "Testlabel"
        set lab [ttk::label $path.lab]
        set ent [ttk::entry $path.ent]
        pack $lab -side left -padx 5 -pady 5
        pack $ent -side left -padx 5 -pady 5
        my configure {*}$args
    }
    # expose if desired the internal widgets using subcommands
    method label {args} {
        $lab {*}$args
    }
    method entry {args} {
        $ent {*}$args
    }
    method configure {args} {
       if {[llength $args] < 2 || [expr {[llength $args]%2}] == 1} {
           return [next {*}$args]
       } 
       next {*}$args
       array set opts $args
       if {[info exists opts(-labeltext)]} {
            my label configure -text $opts(-labeltext)
       }
    }
    # delegate all methods to the entry widget
    method unknown {args} {
        $ent {*}$args
    }
}
# simpler approach using only delegation

oowidgets::widget ::flash::LEntry {
    variable ent
    variable lab
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my install ttk::frame $path 
        set lab [ttk::label $path.lab]
        set ent [ttk::entry $path.ent]
        pack $lab -side left -padx 5 -pady 5
        pack $ent -side left -padx 5 -pady 5
        my configure {*}$args
    }
    # expose the internal widgets using subcommands
    method label {args} {
        $lab {*}$args
    }
    method entry {args} {
        $ent {*}$args
    }
}
# mixin test

# keep standard widgets as classes
namespace eval ::oow { } 
oowidgets::widget ::oow::Label {
    constructor {path args} {
        my install ttk::label $path
        my configure {*}$args
    }
}   

oo::class create ::oow::LblFlash {
    method flash {{flashtime 300}} {
        set fg [my cget -foreground]
        for {set i 0} {$i < 5} {incr i} {
            my configure -foreground green
            update idletasks
            after $flashtime
            my configure -foreground $fg
            update idletasks
            after $flashtime
        }
        puts "Mixin for label flashed" 
    }
}

oo::define oow::Label { mixin ::oow::LblFlash }

set lbl [oow::label .lbl -text "Hello" -foreground blue]
pack  $lbl -side top 
set btn [ttk::button .btn  -text "Exit" -command exit]
pack $btn -side top
$lbl flash
set fb [flash::button .fb -text "Exit" -flashtime 100 -command exit]
pack $fb -side top -pady 10 -pady 10 -fill both -expand true

if {true} {
    set fl [flash::label .fl -text "FlashLabel" -flashtime 50 -anchor center]
    pack $fl -side top -padx 10 -pady 10 -fill both -expand true
    set le [flash::labentry .le -relief ridge -borderwidth 5 -labeltext "Label 2:"]
    
    #$le label configure -text " Label 1:"
    $le entry insert end "Entryvalue"
    $le delete 0 5
    pack $le -side bottom -fill x -expand false
    puts "label value: [$le cget -labeltext]"
    $le configure -labeltext "Hello"
    puts [$le configure]
    set le2 [flash::lentry .le2 -relief ridge -borderwidth 5]
    $le2 label configure -text "LEntry Example" -width 20
    $le2 entry configure -show *
    $le2 entry insert 0 "password"
    puts "le2: [$le2 entry get]"
    pack $le2 -side bottom -fill x -expand false
    
    $fb flash
    puts "done 1"
    .fb flash
    puts "done 2"
    .fl flash
    $fl flash
    $fb invoke
}
