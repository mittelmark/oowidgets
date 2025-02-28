#!/usr/bin/env tclsh
##############################################################################
#
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : MicroEmacs User
#  Created       : 2025-02-06 06:12:50
#  Last Modified : <250228.1019>
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
package require inifile

namespace eval ::lisi { 
    variable lisi
    variable lastdir 
    variable lastfiles
    variable types
    variable ini
    variable inifile
    set inifile [file join $::env(HOME) .config lisi lisi.ini]
    if {[file exists $inifile]} {
        set ini [ini::open $inifile]
    } else {
        if {[file isdirectory [file join $::env(HOME) .config lisi]]} {
            file mkdir [file join $::env(HOME) .config lisi]
            set out [open [file join $::env(HOME) .config lisi lisi.ini] w 0600]
            puts $out ""
            close $out
        }
        set ini [ini::open $inifile]
    }
    set lisi [info script]
    set lastdir [pwd]
    set types {
        {{Music ABC Files}    {.abc} }
        {{GraphViz Dot Files} {.dot} }
        {{Eqn Files}          {.eqn} }        
        {{Pikchr Files}       {.pik} }
        {{Plantuml Files}     {.pml} }
        {{Python Files}       {.py}  }
        {{R Files}            {.R .r}}
        {{GO SGF Files}       {.sgf} }
        {{Tex Files}          {.tex} }        
        {{Text Files}         {.txt} }
        {{All Files}          *      }
    }
    set lastfiles [list]
    
    set sections [ini::sections $ini]
    if {"LAST" in $sections} {
        set lastdir [file dirname [ini::value $ini LAST FILE1 [file join [pwd] test.txt]]]
        for {set i 1} {$i < 11} {incr i 1} {
            if {[ini::exists $ini LAST FILE$i]} {
                set file [ini::value $ini LAST FILE$i]
                if {$file ne "" && [file exists $file]} {
                    lappend lastfiles $file
                }
            }
        }
    }
}
proc ::lisi::file_changed {} {
    global ie
    set file [[$ie text] file_get]
    $ie configure -filename $file
    if {[file exists [file rootname $file].png]} {
        $ie image_display [file rootname $file].png
        $ie optfile_read
    }
    wm title . "Lisi - [file tail $file]"
}
proc ::lisi::usage {app} {
    if {[file tail $app] eq "tclmain"} {
        set app "tclmain -m lisi"
    }
    puts "  Usage: $app ?--help? ?FILENAME? ?CMDLINE?"
    puts "\n  Example: $app schema.pml \"plantuml -tpng %i\"\n"
    destroy .
    exit 0
}
proc ::lisi::help {app argv} {
    puts "Lisi - Graphics made easy - Detlef Groth, University of Potsdam"
    puts "---------------------------------------------------------------"
    puts "\n  Example showcase application for object oriented programming"
    puts "  demonstrating the creation and use of megawidgets using the"
    puts "  oowidgets and paul packages: "
    puts "  See https://github.com/mittelmark/oowidgets\n"
    usage $app
}
proc ::lisi::exit {} {
    variable ini
    global ie
    set lastfiles [$ie text file_recent]
    set i 0
    foreach file $lastfiles {
        incr i
        ::ini::set $ini LAST FILE$i $file
    }
    ::ini::commit $ini
    ::ini::close $ini
}
proc ::lisi::gui {args} { 
    global ie
    variable lastfiles
    set app [::paul::basegui new -style clam -onexit ::lisi::exit]
    $app fontSizeBind ;# for Ctrl-plus / Ctrl-minus for fontsize"
    array set opts [list -commandline "dot -Tpng %i -o %o" -filename ""]
    array set opts $args
    set f [$app getFrame]
    set ie [paul::imedit $f.ie -commandline $opts(-commandline)  \
            -statuslabel [$app message] -pane horizontal -filetypes $::lisi::types]
    oo::objdefine [$ie text] mixin -append paul::txpopup
    oo::objdefine [$ie text] mixin -append paul::txtemplate
    [$ie text] txpopup
    [$ie text] txtemplate    
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
    $mfile insert 6 separator
    $mfile insert 7 cascade -label "Recent Files ..." -menu [$ie text getFileRecentMenu] -underline 0
    [$app getMenu main] insert 2 cascade -label "Edit" -menu [$ie text getEditMenu] -underline 0
    [$app getMenu main] insert 3 cascade -label "Templates" -menu [$ie text getTemplateMenu] -underline 0    
    set mhelp [$app getMenu "Help"]
    $mhelp insert 0 command -command ::lisi::gui_help -label "Help" -underline 0
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
    bind all <<FileChanged>> ::lisi::file_changed
    [$ie text] file_recent $lastfiles
}
proc ::lisi::gui_help {{topic ""}} {
    variable lisi
    if {[winfo exists .help]} {
        wm deiconify .help
    } else {
        toplevel .help
        wm title .help "Lisi - Help"
        paul::htext .help.ht
        .help.ht file_read [file join [file rootname ${lisi}].md]
        pack .help.ht -side top -fill both -expand true
        pack [ttk::button .help.btn -text Dismiss -command [list destroy .help]] \
              -side top -fill x -expand false -padx 20 -pady 10
    }
    if {$topic ne ""} {
        .help.ht show $topic
    }
}
proc ::lisi::main {argv} {
    variable defaults
    if {[llength $argv] == 0} {
        gui
        return
    }
    if {[lsearch $argv --help] > -1} {
        help $::argv0 $argv
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
 
