#!/usr/bin/env tclsh
##############################################################################
#
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : MicroEmacs User
#  Created       : 2025-02-06 06:12:50
#  Last Modified : <250210.0808>
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
        {{Pikchr Files}       {.pik} }
        {{Plantuml Files}     {.pml} }
        {{R Files}            {.R .r}}
        {{GO SGF Files}       {.sgf} }
        {{Text Files}         {.txt} }
        {{All Files}          *      }
    }
}

proc ::lisi::usage {app} {
    puts "Usage: $app ?--help? ?FILENAME? ?CMDLINE?"
    puts "\n   Example: $::argv0 schema.pml \"plantuml -tpng %i\""
    destroy .
    exit 0
}
proc ::lisi::help {app argv} {
    puts help
}
proc ::lisi::gui {args} { 
    set app [::paul::basegui new -style clam]
    $app fontSizeBind ;# for Ctrl-plus / Ctrl-minus for fontsize"
    array set opts [list -commandline "dot -Tpng %i -o %o" -filename ""]
    array set opts $args
    set f [$app getFrame]
    set ie [paul::imedit $f.ie -commandline $opts(-commandline)  \
            -statuslabel [$app message] -pane horizontal -filetypes $::lisi::types]
    $ie optfile_init
    $ie configure -labeltext "Command Line: "
    pack $ie -side top -fill both -expand true -padx 5 -pady 5
    #$txt fileproc -filetypes $::lisi::types
    set mfile [$app getMenu File]
    $mfile insert 0 command -command [list $ie file_new] -label "New" -underline 0
    $mfile insert 1 separator
    $mfile insert 2 command -command [list $ie file_open] -label "Open ..." -underline 0
    $mfile insert 3 separator    
    $mfile insert 4 command -command [list $ie file_save] -label "Save" -underline 0
    $mfile insert 5 command -command [list $ie file_save_as] -label "Save As ..." -underline 1    
    $app addStatusBar
    set txt [$ie text]
    if {$opts(-filename) eq ""} {
        set content "digraph g { A -> B } \n"
        $txt insert 1.0 $content
    } else {
        $ie file_open $opts(-filename)
        if {[file exists [file rootname $opts(-filename)].png]} {
            $ie image_display [file rootname $opts(-filename)].png
        }
    }
    wm title . "Lisi - [$ie cget -filename]"


}

proc ::lisi::main {argv} {
    variable defaults
    if {[llength $argv] == 0} {
        gui
        return
    }
    set filename [lindex $argv 0]
    if {![file exists $filename]} {
        puts "Error: File '$filename' does not exists!"
        usage $::argv0
    }
    set optfile [file rootname $filename].opt
    set ext [string tolower [string range [file extension $filename] 1 end]]
    if {[llength $argv] == 1 && ![file exists $optfile]} {
        if {[info exists defaults($ext)]} {
            set cmd $defaults($ext)
        } else {
            set cmd "Enter your command line here!"
        }
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
    } else {
        ::lisi::main $argv
    }
}
 
