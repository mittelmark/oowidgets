#!/usr/bin/env tclsh
#' ---
#' title: paul::tv - mixins for the ttk::treeview widget
#' author: Detlef Groth, Schwielowsee, Germany
#' Date : 2025-02-16
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
#' > **paul::tv** - oo::class mixins for the ttk::treeview widget
#' 
#' > The following mixins are implemented:
#' 
#' > - [paul::tvfilebrowser](#tvfilebrowser) - file browser widget
#'
#' ## <a name='synopsis'></a> SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' ```
#' 
#' ```
#' package require paul
#' package require tkoo
#' set tv [tkoo::treeview pathName ?option value ...?
#' oo::objdefine $tv mixin Mixin ?Mixin ...?
#' $tv mixinmethod ?option value ...?
#' pack $tv
#' ```
#' 
#' ## <a name='example'></a> EXAMPLE
#'
#' ```{.tcl eval=true}
#' package require paul
#' proc onClick {fname} {
#'   puts "Clicked $fname"
#' }
#' set tv [tkoo::treeview .tv]
#' oo::objdefine $tv mixin paul::tvfilebrowser
#' $tv tvfilebrowser -browsecmd onClick
#' pack $tv -side top -fill both -expand yes
#' ```
#'
#' ## <a name='mixins'></a> MIXINS
#'
#' <a name="tvfilebrowser"> </a>
#' tkoo::treeview pathName ?-option value ...?*  
#' oo::objdefine pathName mixin **paul::tvfilebrowser**   
#' pathName tvfilebrowser *?-option value ...?*
#' 
#' Creates and configures the *paul::tvfilebrowser*  widget using the Tk window id _pathName_ and the given *options*. 
#'
#' The following option is available:
#'
#' > - *-directory dirName* - starting directory for the filebrowser, default current directory.
#'   - *-browsecmd cmdName* - command to be executed if the users double clicks on a row item or presses the Return key. The widgets *pathName* and the actual row index are appended to the *cmdName* as arguments, default to empty string.
#'   - *-fileimage imgName* - image to be displayed as filename image left of the filename, default is standard file icon.
#'   - *-filepattern pattern* - the filter for the files to be displayed in the widget, default to ".+" i.e. all files
#' 
#' The following method(s) is(are) available:
#' 
#' > - *browseDir dirName* - the directory to be loaded into the *paul::tvfilebrowser* widget.
#' 
#' Example:
#'
#' ```{.tcl eval=true}
#' package require paul
#' proc onClick {fname} {
#'   puts "Clicked $fname"
#' }
#' set tv [tkoo::treeview .tv]
#' oo::objdefine $tv mixin paul::tvfilebrowser
#' $tv tvfilebrowser -browsecmd onClick
#' pack $tv -side top -fill both -expand yes
#' ```

# a file browser widget as widget adaptor
# could be may be better be a snit::widget
# as it is already quite specialized
# however writing it as a adaptor allows nesting
# so banding widget adaptor can go intern
# this is required as in the constructor already 
# browseDir is called

catch { rename ::paul::tvfilebrowser {} }

::oo::class create ::paul::tvfilebrowser {
    variable lastKeyTime
    variable lastKey 
    method tvfilebrowser {args} {
        ttk::style configure Treeview.Item -padding {1 1 1 1}
        set lastKey ""
        my option -filepattern ".*"
        my option -directory "."
        my option -fileimage ::paul::fileImg
        my option -browsecmd ""
        set win [my widget]
        $win configure -columns [list Name Size Modified] -show [list tree headings]
        $win heading Name -text Name -anchor w
        $win heading Size -text Size -anchor center
        $win heading Modified -text Modified -anchor w
        $win column Name -width 60 
        $win column Size -width 40
        $win column Size -width 40
        $win column #0 -width 35 -anchor w -stretch false
        bind $win <Double-1> [mymethod fbOnClick %W %x %y]
        bind $win <Return> [mymethod fbReturn %W]
        bind $win <Key-BackSpace> [mymethod browseDir ..]
        $win tag configure hilight -foreground blue
        set LastKeyTime [clock seconds]
        my browseDir [my cget -directory]
        my configure {*}$args
    }
    method fbReturn {w} {
        set win [my widget]
        set row [$win selection]
        $win tag remove hilight
        $win tag add hilight $row 
        set fname [lindex [$win item $row -values] 0]
        if {[file isdirectory $fname]} {
            my browseDir $fname
        }  else {
            if {[my cget -browsecmd] ne ""} {
                [my cget -browsecmd] $fname
            }
        }
    }
    method fbOnClick {w x y} {
        set win [my widget]
        set row [$win identify item $x $y]
        $win tag remove hilight
        $win tag add hilight $row 
        set fname [lindex [$win item $row -values] 0]
        if {[file isdirectory $fname]} {
            my browseDir $fname
        }  else {
            if {[my cget -browsecmd] ne ""} {
                [my cget -browsecmd] $fname
            }
        }

    }
    method browseDir {{dir "."}} {
        set win [my widget]
        if {[llength [$win children {}]] > 0} {
            $win delete [$win children {}]
        }
        if {$dir ne "."} {
            cd $dir
            my configure -directory [pwd]
        }
        $win insert {} end -values [list ".."  " " [clock format [file mtime ..] -format "%Y-%m-%d %H:%M"]] -image ::paul::clsdFolderImg
        foreach dir [lsort -dictionary [glob -types d -nocomplain [file join [my cget -directory] *]]] {
            $win insert {} end -values [list [file tail $dir]  " " \
                                        [clock format [file mtime [file tail $dir]] -format "%Y-%m-%d %H:%M"]] -image ::paul::clsdFolderImg
        }
        
        foreach file [lsort -dictionary [glob -types f -nocomplain [file join [my cget -directory] *]]] {
            if {[regexp [my cget -filepattern] $file]} {
                $win insert {} end -values [list [file tail $file] \
                                            [format "%3.2fMb" [expr {([file size $file] /1024.0)/1024.0}]] \
                                             [clock format [file mtime [file tail $file]] -format "%Y-%m-%d %H:%M"]] \
                      -image [my cget -fileimage]
            }
        }
        $win focus [lindex [$win children {}] 0]
        $win selection set  [lindex [$win children {}] 0]
        focus -force $win
        foreach header [$win cget -columns] {
            $win heading $header -image ::paul::arrowBlank
        }
    }

    
}

#' ## <a name='see'></a> SEE ALSO
#'
#' - [oowidgets](../oowidgets/oowidgets.html)
#' - [paul::basegui.tcl](basegui.html)
#'
#' ## <a name='authors'></a> AUTHOR
#'
#' The **paul::tv** mixins were written by Detlef Groth, University of Potsdam, Germany.
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


if {[info exists argv0] && $argv0 eq [info script] && [regexp tvmixins $argv0]} {
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
        puts "     The paul::tvmixins class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2021-2025  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
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
