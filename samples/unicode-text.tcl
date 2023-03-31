package require oowidgets
# wrapper widget

namespace eval ::sample {}
oowidgets::widget ::sample::Text {
    constructor {path args} {
        my install tk::text $path
        my configure {*}$args
    }
}

namespace eval ::sample::unicode { 
    variable uc_keys
}

proc ::sample::unicode::enable_unicode_entry {widget} {
    variable uc_keys
    set uc_keys($widget) {}
}

proc ::sample::unicode::disable_unicode_entry {widget} {
    variable uc_keys
    unset -nocomplain uc_keys($widget)
}
proc ::sample::unicode::handle_uc_key {widget key} {
    variable uc_keys
    if {![info exists uc_keys($widget)]} {
        return
    }
    
    upvar 0 uc_keys($widget) keys
    switch -glob -- [string toupper $key] {
        {[0-9A-F]} {
            append keys $key
            if {[string length $keys] >= 4} {
                $widget insert insert [subst \\u$keys]
                disable_unicode_entry $widget
            }
            return -code break
        }
        default {
            $widget insert insert $keys
            disable_unicode_entry $widget
        }      
    }        
}


::oo::class create ::sample::txunicode {
    method unicode {{keypress Control-Key-u}} {
        set w [my widget]
        bindtags $w [list $w UnicodeEntry Text . all]
        bind UnicodeEntry <$keypress> [list ::sample::unicode::enable_unicode_entry %W]
        bind UnicodeEntry <Key> [list ::sample::unicode::handle_uc_key %W %A]
    }
}

set txt [sample::text .txtu -background grey80 -font "Courier 18"]
$txt insert  end "Press Ctrl-Shift-u and then therafter 4 numbers like 2602\n\n"
oo::objdefine $txt mixin sample::txunicode
$txt unicode Control-Key-U
pack $txt -side top -fill both -expand yes
