#!/usr/bin/env tclsh
##############################################################################
#
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : MicroEmacs User
#  Created       : 2025-02-06 06:12:50
#  Last Modified : <250207.0622>
#
#  Description	 :
#
#  Notes         :
#
#  History       :
#	
##############################################################################
#
#  Copyright (c) 2025 MicroEmacs User.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from MicroEmacs User.
#
##############################################################################
package require paul
package provide lisi 0.0.2

namespace eval ::lisi { 
    variable lisi
    variable lastdir 
    variable types
    set lisi [info script]
    set lastdir [pwd]
    set types {
        {{Music ABC Files}    {.abc} } 
        {{GraphViz Dot Files} {.dot} }                
        {{Plantuml Files}     {.pml} }        
        {{GO SGF Files}       {.sgf} }                
        {{Text Files}         {.txt} }
        {{All Files}          *      }
    }

}

proc ::lisi::usage {app} {
    puts "Usage $app ?--help? FILENAME ?CMDLINE?"
    destroy .
    exit 0
}
proc ::lisi::help {app argv} {
    puts help
}
proc ::lisi::gui {args} { 
    set app [::paul::basegui new -style clam]
    array set opts [list -commandline "dot -Tpng %i -o %o" -filename ""]
    array set opts $args
    parray opts
    set f [$app getFrame]
    set ie [paul::imedit $f.ie -commandline $opts(-commandline)  \
            -statuslabel [$app message] -pane horizontal]
    $ie labentry configure -labeltext "Command Line: "
    set txt [$ie text] 
    $txt configure -background skyblue
    oo::objdefine  $txt mixin paul::txindent paul::txfileproc
    pack $ie -side top -fill both -expand true -padx 5 -pady 5
    $txt fileproc -filetypes $::lisi::types
    set mfile [$app getMenu File]
    $mfile insert 0 command -command [list $txt file_new] -label "New" -underline 0
    $mfile insert 1 separator
    $mfile insert 2 command -command [list $txt file_open] -label "Open ..." -underline 0
    $mfile insert 3 separator    
    $mfile insert 4 command -command [list $txt file_save] -label "Save" -underline 0
    $mfile insert 5 command -command [list $txt file_save_as] -label "Save As ..." -underline 1    
    $app addStatusBar
    if {$opts(-filename) eq ""} {
        set content "digraph g { A -> B } \n"
        $txt insert 1.0 $content
    } else {
        $txt file_open $opts(-filename)
    }


}

proc ::lisi::main {argv} {
    set filename [lindex $argv 0]
    if {![file exists $filename]} {
        puts "Error: File '$filename' does not exists!"
        usage $::argv0
    }
    set optfile [file rootname $filename].opt
    if {[llength $argv] == 1 && ![file exists $optfile]} {
        set cmd "Enter your command line here!"
    } elseif {[llength $argv] == 1} {
        if [catch {open $optfile r} infh] {
            return -code error "Cannot open $optfile: $infh"
        } else {
            set cmd [string trim [read $infh]]
            close $infh
        }
    } else {
        set cmd [lindex $argv 1]
    }
    if {![winfo exists .f]} {
        gui -filename $filename -commandline $cmd
        ## \u262F Yin Yang
        wm title . "Lisi - graphics made easy"
    }
}
if {[info exists argv0] && $argv0 eq [info script]} {
    if {[lsearch -regex $argv {(-h|--help)}] > -1} {
        ::lisi::help $argv0 $argv
    } elseif {[llength $argv] < 1} {
        ::lisi::usage $argv0
    } else {
        ::lisi::main $argv
    }
}
 
