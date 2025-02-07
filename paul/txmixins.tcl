#' ---
#' title: paul::tx - mixins for the tk::text widget
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : 2024-12-23
#' header-includes: 
#' - | 
#'     ```{=html}
#'     <style>
#'     html {
#'       line-height: 1.2;
#'       font-family: Georgia, serif;
#'       font-size: 16px;
#'       color: #1a1a1a;
#'       background-color: #fdfdfd;
#'     }
#'     body { max-width: 1000px; }
#'     pre#license {
#'       background: #fdfdfd;
#'     }
#'     </style>
#'     ```
#' ---
#' 
#' ```{.tcl eval=true echo=false results="asis"}
#' include paul/header.html
#' ```
#' 
#' ## NAME
#'
#' > **paul::tx** - oo::class mixins for the tk::text widget
#' 
#' > The following mixins are implemented:
#' 
#' > - [paul::txautorep](#txautorep) - abbreviation tool for text widgets
#'   - [paul::txfileproc](#txfileproc) - file-save, file-new, file-open etc procedures for the text widget
#'   - [paul::txindent](#txindent) - automatic indentation for text widgets
#'   - [paul::txmatching](#txmatching) - hilight matching parenthesis, brackets or braces
#'   - [paul::txunicode](#txunicode) - entering Unicode characters
#'
#' ## <a name='synopsis'></a> SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' #package require paul
#' ```
#' 
#' ```
#' package require paul
#' package require tkoo
#' set txt [tkoo::text pathName ?option value ...?
#' oo::objdefine $txt mixin Mixin ?Mixin ...?
#' pack $txt
#' ```
#' 
#' ## <a name='example'></a> EXAMPLE
#'
#' ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txtx -background salmon]
#' oo::objdefine $txt mixin ::paul::txautorep
#' $txt autorep [list (TM) \u2122 (C) \u00A9 (R) \u00AE (K) \u2654]
#' $txt insert end "# Autorep Example\n\n"
#' foreach col [list A B C] { 
#'    $txt insert  end "# Header $col\n\n   Some more text.\n\n"
#' }
#' $txt insert end "  * item 1\n  * item 2\n  * Write (DG) and press enter\n  * "
#' pack $txt -side top -fill both -expand yes
#' set txt [tkoo::text .txty -background skyblue]
#' foreach col [list A B C] { 
#'    $txt insert  end "# Header $col\n\n## Indent example\n\n"
#' }
#' $txt insert end "  * item 1\n  * item 2 (press return here)"
#' oo::objdefine $txt mixin paul::txindent paul::txfileproc
#' $txt indent
#' $txt fileproc 
#' $txt file_open
#' pack $txt -side top -fill both -expand yes
#' ```
#'
#' ## <a name='mixins'></a> MIXINS
#' 
#' <a name="txautorep"></a>**paul::txautorep** -  *oo::objdefine pathName mixin paul::txautorep*
#' 
#' Adds abbreviation support to an existing *tkoo::text* widget, which is a wrapper for the *tk::text* widget using the Tk window id _pathName_ .
#' The widget indents every new line based on the initial indention of the previous line.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/autoreplace started by Richard Suchenwirth.
#'
#' Example:
#' 
#' ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txta -background salmon]
#' oo::objdefine $txt mixin ::paul::txautorep
#' $txt autorep [list (TM) \u2122 (C) \u00A9 (R) \u00AE (K) \u2654]
#' $txt insert end "# Autorep Example\n\n"
#' foreach col [list A B C] { 
#'    $txt insert  end "# Header $col\n\n   Some more text.\n\n"
#' }
#' $txt insert end "  * item 1\n  * item 2\n  * Write (DG) and press enter\n  * "
#' pack $txt -side top -fill both -expand yes
#' ```
#' 

catch { rename ::paul::txautorep {} }

::oo::class create ::paul::txautorep {
    variable automap 
    method autorep {{abbrev ""}} {
        set w [my widget]
        set automap [list (DG) {Detlef Groth\nUniversity of Potsdam}]
        array set opts $abbrev 
        foreach key [array names opts] {
            lappend automap $key
            lappend automap $opts($key)
        }
        bind $w <KeyRelease-parenright> [mymethod Autochange %W]
    }
    method Autochange {win} {
        variable textw
        set w $win
        foreach {abbrev value} $automap {
            set n [string length $abbrev]
            if {[$w get "insert-$n chars" insert] eq $abbrev} {
                $w delete "insert-$n chars" insert
                $w insert insert [regsub -all {\\n} $value "\n"]
                break
            }
        }
    }
}

#' <a name="txfileproc"></a>**paul::txfileproc** -  *oo::objdefine pathName mixin paul::txfileproc*
#' 
#' Adds methods to load and save the content of the text widget from and to files. The following methods are available
#' 


catch { rename ::paul::txfileproc {} }
::oo::class create ::paul::txfileproc {
    variable lastfile
    variable lastfiles
    variable lastdir
    variable options
    variable win
    #' - _cmdName_ - __fileproc__ _?args?_ 
    #' 
    #' > initialize the fileproc mixin with the given arguments the following arguments are supported:
    #'
    #' > - _filecallback_ - the command  executed if a file is loaded or saved, default: empty string
    #'   - _filetypes_ - the default file type list for opening and saving files
    #'   - _filename_ - the file to load per default, if the string new is given, will create a new empty file 
    #'
    #' Example:
    #' 
    #' ```{.tcl eval=true}
    #' package require paul
    #' set txt [tkoo::text .txtfp -background salmon]
    #' oo::objdefine $txt mixin ::paul::txfileproc
    #' $txt fileproc
    #' $txt file_open
    #' pack $txt -side top -fill both -expand yes
    #' ```
    #' 
    method fileproc {args} {
        set win [my widget]
        array set options [list -filecallback "" -filetypes { {{Text Files} {.txt}} {{All Files} {*.*}} } \
                           -filename new]
        foreach {key val} $args {
            set options($key) $val
        }
        set lastfile $options(-filename)
        if {$lastfile eq "new"} {
            set lastdir [pwd]
        } else {
            set lastdir [file dirname $lastfile]
        }
        set lastfiles [list]
        bind $win <Destroy> [mymethod file_exit]
    }
    #' - _cmdName_ - **file_exit** 
    #' 
    #' > Asks the user to save the file if it was modified in the text widget.
    #'   then exits the application.
    #'   If there is no file name set until now, a file dialog will be displayed
    #'   to allow the user to select its file.
    #'
    method file_exit {} {
        my variable win
        if {$lastfile in [list "*new*" "new"]} {
            my file_save_as
        }
        if {[$win edit modified]} {
            set answer [tk_messageBox -title "File modified!" -message "Do you want to save changes?" -type yesnocancel -icon question]
            switch -- $answer  {
                yes  {
                    my file_save
                }
                cancel { return }
            }
        } 
        #exit 0
    }
    #' - _cmdName_ - **file_get**
    #' 
    #' > Returns the  filename of the currently loaded file.
    #'
    method file_get {} {
        return $lastfile
    }
    #' - _cmdName_ - **file_new**
    #' 
    #' > Creates a new emtpy file. If the current file was modified the 
    #'   uuser is asked to save the file before loading a new file.
    #'
    method file_new {} {
        if {[$win edit modified]} {
            set answer [tk_messageBox -title "File modified!" -message "Do you want to save changes?" -type yesnocancel -icon question]
            switch -- $answer  {
                yes  {
                    my file_save
                }
                cancel { return }
            }
        } 
        $win delete 1.0 end       
        set lastfile "*new*"
        if {$options(-filecallback) ne ""} {
            eval $options(-filecallback) new $lastfile
        }
        event generate $win <<FileChanged>>
        return "*new*"
    }
    #' - _cmdName_ - **file_open** *?filename?*
    #' 
    #' > Opens a new file which is selected by the user. If the current file was modified the 
    #'   user is asked to save the file before loading the file. If there is no file name given
    #'   the a file dialog will be displayed to allow the user to select its file.
    #'
    method file_open {{filename ""}} {
        if {[$win edit modified]} {
            set answer [tk_messageBox -title "File modified!" -message "Do you want to save changes?" -type yesnocancel -icon question]
            switch -- $answer  {
                yes  {
                    $self file_save
                }
                cancel { return }
            }
        } 
        if {$filename eq ""} {
            set filename [tk_getOpenFile -filetypes $options(-filetypes) -initialdir $lastdir]
            
        }
        if {$filename ne ""} {
            if [catch {open $filename r} infh] {
                tk_messageBox -title "Info!" -icon info -message "Cannot open $filename: $infh" -type ok
            } else {
                $win delete 1.0 end
                while {[gets $infh line] >= 0} {
                    $win insert end "$line\n"
                }
                close $infh
                set lastfile $filename
                set lastdir [file dirname $filename]
                $win edit modified false
                if {$options(-filecallback) ne ""} {
                    eval $options(-filecallback) open $lastfile
                }
                my PushFile
                event generate $win <<FileChanged>>
            }
        }
        return $filename
    }
    #' - _cmdName_ - **file_recent** 
    #' 
    #' > Returns a list of the recently edited files.
    #'
    method file_recent {} {
        my variable lastfiles
        set t {}
        foreach i $lastfiles {if {[lsearch -exact $t $i]==-1} {lappend t $i}}
        set lastfiles $t
        return $t
    }
    
    #' - _cmdName_ - **file_save**
    #' 
    #' > Saves  the content of the text widget into the currently loaded file.
    #'   If there is no file name set until now, a file dialog will be displayed
    #'   to allow the user to select its file.
    #'
    method file_save {} {
        my variable lastfile
        my variable lastdir
        my variable options
        my variable win
        if {$lastfile in [list "*new*" "new"]} {
            unset -nocomplain savefile
            set file [tk_getSaveFile -filetypes $options(-filetypes) \
                      -initialdir $lastdir]
        } else {
            set file $lastfile
        }
        if {$file != ""} {
            set out [open $file w 0600]
            puts $out [$win get 1.0 end]
            close $out
            set lastfile $file
            set lastdir [file dirname $lastfile]
            $win edit modified false
            if {$options(-filecallback) ne ""} {
                eval $options(-filecallback) save $lastfile
            }
            my  PushFile
            event generate $win <<FileSaved>> 
        }
        return $file
    }
    #' - _cmdName_ - <b>file\_save\_as</b>
    #' 
    #' > Saves  the content of the text widget into the file selected by the user.
    #'
    method file_save_as {} {
        my variable lastdir
        my variable lastfile
        my variable options
        unset -nocomplain savefile
        set filename [tk_getSaveFile -filetypes $options(-filetypes) -initialdir $lastdir]
        if {$filename != ""} {
            set out [open $filename w 0600]
            puts $out [$text get 1.0 end]
            close $out
            set lastfile $filename
            set lastdir [file dirname $file]
            $win edit modified false
            if {$options(-filecallback) ne ""} {
                eval $options(-filecallback) saveas $lastfile
            }
            my PushFile
            event generate $win <<FileChanged>>
            event generate $win <<FileSaved>>
        }
        return $filename
    }
    method PushFile {} {
        my variable lastfiles
        my variable lastfile
        set lastfiles [linsert $lastfiles 0 $lastfile]
    }
}
#'
#' <a name="txindent"></a>**paul::txindent** -  *oo::objdefine pathName mixin paul::txindent*
#' 
#' Adds indenting capabilities to an existing *tkoo::text* widget, which is a wrapper for the *tk::text* widget using the Tk window id _pathName_ .
#' The widget indents every new line based on the initial indention of the previous line.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/auto-indent started by Richard Suchenwirth.
#'
#' Example:
#' 
#' ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txti -background skyblue]
#' foreach col [list A B C] { 
#'    $txt insert  end "# Header $col\n\n   Some more text.\n\n"
#' }
#' $txt insert end "  * item 1\n  * item 2 (press return here)"
#' oo::objdefine $txt mixin paul::txindent
#' $txt indent
#' pack $txt -side top -fill both -expand yes
#' ```
#' 

catch { rename ::paul::txindent {} }
::oo::class create ::paul::txindent {
    method indent {} {
        set w [my widget]
        bind $w <Return> "[mymethod iindent]; break"
    }
    method iindent {{extra "    "}} {
        set w [self]
        set lineno [expr {int([$w index insert])}]
        set line [$w get $lineno.0 $lineno.end]
        regexp {^(\s*)} $line -> prefix
        if {[string index $line end] eq "\{"} {
            tk::TextInsert $w "\n$prefix$extra"
        } elseif {[string index $line end] eq "\}"} {
            if {[regexp {^\s+\}} $line]} {
                $w delete insert-[expr [string length $extra]+1]c insert-1c
                tk::TextInsert $w "\n[string range $prefix 0 end-[string length $extra]]"
            } else {
                tk::TextInsert $w "\n$prefix"
            }
        } else {
            tk::TextInsert $w "\n$prefix"
        }
    }
    #unexport iindent
}
#'
#' <a name="txmatching"></a>**paul::txmatching** -  *oo::objdefine pathName mixin paul::txmatching*
#' 
#' Adds a matching parenthesis, brackets or braces behaviour.
#' If the user enters an unmatched parenthesis, bracket or brace it is highlighted,
#' if the matching closing character is entered it the region between these two characters
#' is shortly highlighted and thereafter the higlighting is removed.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/Tk+Text+Window+Brace+Parenthesis%2C+and+Bracket+Matching
#'
#' Example:
#' 
#' ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txtm -background salmon -font "Courier 18"]
#' $txt insert  end "Start typing some text containing\n" 
#' $txt insert end "* parenthesis ( and )\n"
#' $txt insert end "* brackets    \[ and \]\n"
#' $txt insert end "* braces      { and }\n\n"
#' $txt insert end "Unicode adding works as well\nPress Ctrl-Shift-u and then write 4 digits ...\n\n"
#' oo::objdefine $txt mixin paul::txmatching paul::txunicode
#' $txt matchbrace
#' $txt matchparen
#' $txt matchbracket
#' $txt unicode Control-Key-U
#' pack $txt -side top -fill both -expand yes
#' ### adding your own additional bindings is still possible
#' bind $txt <KeyRelease> +[list puts "now pressed %K"]
#' ```
#' 

namespace eval ::paul::matching {
    # return -1 if  idx1 if before idx2
    # return 1 if idx1 is after idx2
    # return 0 if idx1 is same as idx2 
    proc idxCompare { idx1 idx2 } {
        if { "$idx1" eq "$idx2" } { return 0 } 
        lassign [split $idx1 . ] r1 col1
        lassign [split $idx2 . ] r2 col2
        if { $r1 < $r2 } { return -1; }
        if { $r1 > $r2 } { return 1; }
        if { $col1 < $col2 } { return -1; }
        return 1;
    }
    
    
    proc markUnBalanced { w char matchChar tag2apply } {
        set matched {}
        set unmatched {}
        set unmatchedEnd {}
        $w tag remove $tag2apply 1.0 end
        set tempCharIndexs  [ $w search -forward  -all "\\$char" 1.0 ]
        set tempMatchIndexs [ $w search -forward -all "\\$matchChar" 1.0]
        set charIndexs  [ $w search -forward -all $char 1.0 ]
        set matchIndexs [ $w search -forward  -all $matchChar 1.0 ]
        
        foreach idx $tempCharIndexs {
            set rIdx [ lsearch $charIndexs [ $w index $idx+1c ] ]
            if { $rIdx >= 0 } {
                set charIndexs [lreplace $charIndexs $rIdx $rIdx ]
            }
        }
        foreach idx $tempMatchIndexs {
            set rIdx [ lsearch $matchIndexs  [ $w index $idx+1c ] ]
            if { $rIdx >= 0 } {
                set matchIndexs [lreplace $matchIndexs $rIdx $rIdx ]
            }
        }
        if { [llength $charIndexs ] == 0 } {
            set unmatchedEnd $matchIndexs
        } elseif { [llength $matchIndexs ] == 0 } {
            set unmatched $charIndexs
        } elseif { [llength $charIndexs ] == 1 && [llength $matchIndexs ] == 0  } { 
            if { [idxCompare [lindex $charIndexs 0  ] [lindex $matchIndexs0  ]  ] > 0 } {
                set matchedEnd [lindex $matchIndexs0  ] 
                set unmatched [lindex $charIndexs 0  ]
            }
        } else {
            foreach endIdx $matchIndexs {
                set c 0
                while { $c < [llength $charIndexs ]  &&  [idxCompare [lindex $charIndexs $c ] $endIdx ] < 0 } {
                    incr c ;
                }
                incr c -1;
                if {  $c >= [llength $charIndexs ] ||  $c < 0 } {
                    lappend unmatchedEnd $endIdx
                } else {
                    lappend matched [list [lindex $charIndexs $c ] $endIdx ]
                    set charIndexs [lreplace $charIndexs $c $c ]
                }
            }
            set unmatched $charIndexs
        }
        if { [llength $unmatched ] } {
            foreach idx $unmatched {
                $w tag add $tag2apply $idx $idx+1c
            }
        }
        if { [llength $unmatchedEnd ] } {
            foreach idx $unmatchedEnd  {
                $w tag add $tag2apply $idx  $idx+1c
            }
        }
        return $matched
    }
    proc genericHandler { w inputChar  char matchChar matchtag unmatchtag } {
        set matched  [ markUnBalanced $w $char $matchChar $unmatchtag ]
        set idx "" 
        if { "$inputChar" eq $matchChar  ||  [$w get insert-1c insert ] eq $matchChar } {
            set idx [$w index insert-1c ]
        } elseif { [$w get insert insert+1c] eq $matchChar  } {
            set idx [$w index insert ]
        } 
        if { $idx ne "" } {
            set matchpair [ lsearch -inline -index 1 $matched $idx ]
            if { [llength $matchpair ] } { 
                $w tag add $matchtag {*}$matchpair+1c
                after 1000 [list $w tag remove $matchtag {*}$matchpair+1c ]
            }
        }
        
        if { "$inputChar" eq $char  ||  [$w get insert-1c insert ] eq $char } {
            set idx [$w index insert-1c ]
        } elseif { [$w get insert insert+1c] eq $char  } {
            set idx [$w index insert ]
        } 
        if { $idx ne "" } {
            set matchpair [ lsearch -inline -index 0 $matched $idx ]
            if { [llength $matchpair ] } { 
                $w tag add $matchtag {*}$matchpair+1c
                after 1000 [list $w tag remove $matchtag {*}$matchpair+1c   ]
            }
        }
    }
    proc handleBracket { w input matchtag unmatchtag } {
        genericHandler $w $input "\[" "\]" $matchtag $unmatchtag
    }
    proc handleParenthesis { w input matchtag  unmatchtag } {
        genericHandler $w $input "\(" "\)" $matchtag $unmatchtag
    }
    proc handleBrace { w input matchtag  unmatchtag } {
        genericHandler $w $input "\{" "\}" $matchtag $unmatchtag
    }
}

catch { rename ::paul::txmatching {} }
::oo::class create ::paul::txmatching {
    method matchparen {{cols {#b3ccff #ff3333}}} {
        set w [my widget]
        $w tag configure matchingParen   -background [lindex $cols 0]
        $w tag configure unmatchingParen -background [lindex $cols 1]
        bind $w <KeyRelease> {
            %W handleTags %W %A
        }
        bind $w <ButtonRelease> {
            %W handleTags %W %A
        }
    }
    method matchbrace {{cols {#ffccff #ff704d}}} {
        set w [my widget]
        $w tag configure matchingBrace   -background [lindex $cols 0]
        $w tag configure unmatchingBrace -background [lindex $cols 1]
        bind $w <KeyRelease> {
            %W handleTags %W %A
        }
        bind $w <ButtonRelease> {
            %W handleTags %W %A
        }
    }
    method matchbracket {{cols {#ccffdd #ff704d}}} {
        set w [my widget]
        $w tag configure matchingBracket   -background [lindex $cols 0]
        $w tag configure unmatchingBracket -background [lindex $cols 1]
        bind $w <KeyRelease> {
            %W handleTags %W %A
        }
        bind $w <ButtonRelease> {
            %W handleTags %W %A
        }
    }
    method handleTags {w a} {
        set tnames [$w tag names]
        if {[lsearch $tnames matchingParen] > -1} {
            ::paul::matching::handleParenthesis $w $a matchingParen unmatchingParen
        }
        if {[lsearch $tnames matchingBrace] > -1} {
            ::paul::matching::handleBrace $w $a matchingBrace unmatchingBrace
        }
        if {[lsearch $tnames matchingBracket] > -1} {
            ::paul::matching::handleBracket $w $a matchingBracket unmatchingBracket
        }
    }
        
}

#'
#' <a name="txunicode"></a>**paul::txunicode** -  *oo::objdefine pathName mixin paul::txunicode*
#' 
#' Adds the capability to enter Unicode symbols to an existing *tkoo::text* widget, which is a wrapper for the *tk::text* widget using the Tk window id _pathName_ .
#' If the user presses the default Keystroke Control-u he/she can enter after typing the four Unicode numbers
#' Unicode characters.
#' Based on code in the Wiki page https://wiki.tcl-lang.org/page/Entering+Unicode+characters+in+a+widget
#'
#' Example:
#' 
#' ```{.tcl eval=true}
#' package require paul
#' set txt [tkoo::text .txtu -background grey80 -font "Courier 18"]
#' $txt insert  end "Press Ctrl-Shift-u and then therafter 4 numbers like 2602\n\n"
#' oo::objdefine $txt mixin paul::txunicode
#' $txt unicode Control-Key-U
#' pack $txt -side top -fill both -expand yes
#' ```
#' 
namespace eval ::paul::unicode { 
    variable uc_keys
}

proc ::paul::unicode::enable_unicode_entry {widget} {
    variable uc_keys
    set uc_keys($widget) {}
}

proc ::paul::unicode::disable_unicode_entry {widget} {
    variable uc_keys
    unset -nocomplain uc_keys($widget)
}
proc ::paul::unicode::handle_uc_key {widget key} {
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

catch { rename ::paul::txunicode {} }
::oo::class create ::paul::txunicode {
    method unicode {{keypress Control-Key-u}} {
        set w [my widget]
        bindtags $w [list $w UnicodeEntry Text . all]
        bind UnicodeEntry <$keypress> [list ::paul::unicode::enable_unicode_entry %W]
        bind UnicodeEntry <Key> [list ::paul::unicode::handle_uc_key %W %A]
    }
}


if {false} {
    package require Tk
    package require oowidgets
    package require tkoo

    set txt [tkoo::text .t -background salmon]
    oo::objdefine $txt mixin paul::txindent paul::txautorep 
    $txt indent
    pack $txt -side top -fill both -expand true
    $txt autorep [list (TM) \u2122]
}

#' ## <a name='see'></a> SEE ALSO
#'
#' - [oowidgets](../oowidgets/oowidgets.html)
#' - [paul::basegui.tcl](basegui.html)
#'
#' ## <a name='authors'></a> AUTHOR
#'
#' The **paul::tx** mixins were written by Detlef Groth, University of Potsdam, Germany.
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2021-2025  Detlef Groth, E-mail: dgroth(at)uni(minus)potsdam(dot)de
#' 
#' ## <a name='license'></a>LICENSE 
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```


if {[info exists argv0] && $argv0 eq [info script] && [regexp txmixins $argv0]} {
    lappend auto_path [file join [file dirname [info script]] ..]
    package require paul
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [package version paul]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {
        set code [::paul::getExampleCode [info script]]
        eval $code
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        set code [::paul::getExampleCode [info script]]
        puts $code
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license")} {
        puts [::paul::getLicense [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--markdown")} {
        puts [::paul::getMarkdown [info script]]
        destroy .
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The paul::txmixins class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-2024  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::txmixins class provides widget"
        puts "                   mixins to be added to the default tk::text widget."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --license : printing the license to the terminal"
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "\n\n      Hint: You can read the documentation like this:\n"
        puts "         tclsh [info script]  --man | pandoc -f Markdown -t plain | less"
        puts "         tclsh [info script]  --man | pandoc -f Markdown -t html | w3m -T text/html -"
        puts ""
    }
}
