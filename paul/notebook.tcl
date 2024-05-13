#' ---
#' title: paul::notebook - extended notebook tab management
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : <240513.1010>
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
#' > **paul::notebook** - extended ttk::notebook tab management
#'
#' ## <a name='synopsis'></a> SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' package require paul
#' ```
#' 
#' > ```{.tcl}
#' package require paul
#' paul::notebook pathName ?-option value ...?
#' pathName add PAGE args
#' pack pathName
#' > ```
#' 
#' ## COMMAND
#' 
#' <a name="notebook"></a>**paul::notebook** *pathName ?args?*
#' 
#' > Creates a `ttk::notebook` with extended tab management facilities. 
#'   You can use right click context menu do rename tabs, move tabs to the left
#'   or right,
#'
#' ## OPTIONS
#' 
#' > All options of a standard `ttk::notebook` widget are supported. In addition the following options are added:
#' 
#' > - __-closecmd__ _cmdname_  - Invokes the given command _cmdname_ if a notebook page is closed,
#'        the given widget path is appended as argument to the command.
#'   - __-createcmd__ _cmdname_ - Invokes the given command _cmdname_ if a new page is created,
#'        the pathname of the notebook and the page index are added as arguments to the script call. 
#'   - __-movecmd__ _cmdname_ - Invokes the given command _cmdname_ if a notebook page is moved,
#'        the given widget path, the page index amd the direction is appended as argument to the command.
#'   - __-raisecmd__ _cmdname_ - Invokes the given command _cmdname_ if a notebook page is raised,
#'        the given widget path and the page index is appended as argument to the command.
#'   - __-renamecmd__ _cmdname_ - Invokes the given command _cmdname_ if a page is renamed,
#'        the given widget path is appended as argument to the command.
#' 
#' ## METHODS
#' 
#' > All methods of a standard `ttk:notebook` are supported, in addition the command `bind` is added.
#' 
#' ## KEY BINDINGS
#' 
#' > The following key bindings are added by default:
#' 
#' > - _F2_ - popup for moving and renaming tabs
#'   - _Button-3_ - popup for moving and renaming tabs
#'   - _Ctrl-Shift-Left_ - move current tab to the left
#'   - _Ctrl-Shift-Right_ - move current tab to the right
#'   - _Ctrl-w_ - close current tab
#'   - _Ctrl-t_ - create new tab
#' 
#' 
#' ## EXAMPLE
#'
#' > ```{.tcl eval=true results="hide"}
#' package require paul
#' pack [paul::notebook .nb -side top -fill both -expand true]
#'      ### child tab widgets
#'      .nb add [frame .nb.f1] -text "First tab"
#'      ttk::label .nb.f1.lb -text "Right Click notebook labels I" -width 50
#'      pack .nb.f1.lb -side top -fill both -expand true -anchor center -padx 20 -pady 20
#'      .nb add [frame .nb.f2] -text "Second tab"
#'      ttk::label .nb.f2.lb -text "Right Click notebook labels II" -width 50
#'      pack .nb.f2.lb -side top -fill both -expand true -anchor center -padx 20 -pady 20
#' .nb select .nb.f2
#' ttk::notebook::enableTraversal .nb
#' > ``` 
#' 

package require oowidgets

namespace eval ::paul { }

oowidgets::widget ::paul::notebook {
    variable nb
    variable nbw
    variable nbtext
    variable child
    constructor {path args} {
        my install ttk::notebook $path -createcmd "" \
              -raisecmd "" -closecmd "" -renamecmd "" \
              -movecmd ""
        set nb $path
        set nbw ${path}_
        bind $nb <KeyPress-F2> [callback tabRename %x %y]
        bind $nb <Button-3> [callback tabRename %x %y]        
        bind $nb <Control-Shift-Left> [callback tabMove left %W]
        bind $nb <Control-Shift-Right> [callback tabMove right %W]
        bind $nb <Control-w> [callback tabClose %W]   
        bind $nb <Control-t> [callback new %W]        
        bind $nb <Enter> [list focus -force $nb]
        if {[my cget -raisecmd] ne ""} {
            bind $nb <<NotebookTabChanged>>  [callback raise %W]
        }

    }
    method add {page args} {
        $nbw add $page {*}$args
        if {[my cget -createcmd] ne ""} {
            eval [my cget -createcmd] $nb $page
        }

    }
    method raise {w} {
        eval [my cget -raisecmd] $w [$w index current]
    }
    unexport raise
    method new {w} {
        set n [llength [$nb tabs]]
        incr n
        ttk::frame $nb.f$n
        my add $nb.f$n -text "Tab $n"
    }
    unexport new
    method bind {ev script} {
        bind $nb $ev $script
    }
    method tabClose {w} {
        set child [$w select]
        set answer [tk_messageBox -title "Question!" -message "Really close tab [$w tab $child -text] ?" -type yesno -icon question]
        if { $answer } {
            $w forget $child
            destroy $child
            if {[my cget -closecmd] ne ""} {
                eval [my cget -closecmd] $w
            }
        } 
    }
    unexport tabClose
    method tabRename {x y} {
        set nbtext ""
        if {![info exists .rename]} {
            toplevel .rename
            wm overrideredirect .rename true
            #wm title .rename "DGApp" ;# for floating on i3
            set x [winfo pointerx .]
            set y [winfo pointery .]
            entry .rename.ent -textvariable [myvar nbtext]
            pack .rename.ent -padx 5 -pady 5
        }
        wm geometry .rename "180x40+$x+$y"
        set tab [$nb select]
        set nbtext [$nb tab $tab -text]
        focus -force .rename.ent
        bind .rename.ent <Return> [callback doTabRename %W]
        bind .rename.ent <Escape> [list destroy .rename]
        
    }
    unexport tabRename
    method doTabRename {w} {
        set tab [$nb select]
        $nb tab $tab -text $nbtext
        if {[my cget -renamecmd] ne ""} {
            eval [my cget -renamecmd] $nb $tab
        }

        destroy .rename
    }
    unexport doTabRename
    method tabMove {dir w} {
        #puts move$dir
        set idx [lsearch [$nb tabs] [$nb select]]
        #puts $idx
        set current [$nb select]
        if {$dir eq "left"} {
            if {$idx > 0} {
                $nb insert [expr {$idx - 1}]  $current
            }
        } else {
            if {$idx < [expr {[llength [$nb tabs]] -1}]} {
                $nb insert [expr {$idx + 1}] $current
            }
        }
        if {[my cget -movecmd] ne ""} {
            eval [my cget -movecmd] $nb $current $dir
        }

        # how to break automatic switch??
        after 100 [list $nb select $current]
    }
    unexport doTabRename
}


#' ## <a name='see'></a>SEE ALSO
#'
#' - [oowidgets](../oowidgets.html)
#' - [paul::basegui](basegui.html)
#'
#' ## <a name='authors'></a>AUTHOR
#'
#' The **paul::notebook** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2019-2023  Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' ## <a name='license'></a>LICENSE
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```

if {[info exists argv0] && $argv0 eq [info script] && [regexp notebook $argv0]} {
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
        puts "     The paul::notebook class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-2024  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::notebook class provides an extended notebook widget"
        puts "                   with improved tab handling."
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
