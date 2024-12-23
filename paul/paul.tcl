package require Tk
package require TclOO
package require tkoo
package provide paul 0.2.2

# some generic utilities

namespace eval ::paul {
    # styles
    ttk::style layout ToolButton [ttk::style layout TButton]
    ttk::style configure ToolButton [ttk::style configure TButton]
    ttk::style configure ToolButton -relief groove
    ttk::style configure ToolButton -borderwidth 2
    ttk::style configure ToolButton -padding {2 2 2 2} 
    ttk::style configure Treeview -background white
    catch {
        option add *Text.background    white
    }
}

catch { rename ::paul::Timer "" }
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

proc ::paul::getLicense {filename} {
    set filename [file join [file dirname [info script]] LICENSE]
    set lic ""
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
    } else {
        append lic [read $infh]
        close $infh
    }
    return $lic
}
proc ::paul::getMarkdown {filename} {
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        set docu ""
        while {[gets $infh line] >= 0} {
            if {[regexp {^#' } $line]} {
                append docu "[string range $line 3 end]\n"
            } elseif {[regexp {^#'} $line]} {
                append docu "\n"
            }
        }
        close $infh
        return $docu
    }
}
            
    
proc ::paul::getExampleCode {filename} {
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        set flag -1
        set code ""
        while {[gets $infh line] >= 0} {
            if {[regexp {^#' ## .*EXAMPLE} $line]} {
                set flag 0
            } elseif {$flag == 0 && [regexp {^#' >? ?```} $line]} {
                set flag 1
            } elseif {$flag == 1 && [regexp {^#' >? ?```} $line]} {
                break
            } elseif {$flag == 1 && [regexp {^#' } $line]} {
                append code [string range $line 3 end]
                append code "\n"
            }
        }
        close $infh
        #file operations
        return $code
    }
    
}

source [file join [file dirname [info script]] statusbar.tcl] 
source [file join [file dirname [info script]] basegui.tcl] 
source [file join [file dirname [info script]] dlabel.tcl] 
source [file join [file dirname [info script]] rotext.tcl] 
source [file join [file dirname [info script]] notebook.tcl] 
source [file join [file dirname [info script]] txmixins.tcl] 

