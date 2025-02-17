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
#' > - [paul::tvband](#tvband) - adding stripes to treeview widgets
#' > - [paul::tvfilebrowser](#tvfilebrowser) - file browser widget
#' > - [paul::tvsortable](#tvsortable) - a sortable treeview
#'
#' ## <a name='synopsis'></a> SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' ```
#' 
#' ```
#' package require paul
#' set tv [tkoo::treeview pathName ?option value ...?
#' $tv mixin method ?option value ...?
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
#' $tv mixin paul::tvfilebrowser -browsecmd onClick
#' pack $tv -side top -fill both -expand yes
#' set tv2 [tkoo::treeview .fb -columns [list A B C] \
#'        -show headings]
#' $tv2 mixin ::paul::tvsortable -sorttypes [list A real B real C integer] \
#'     paul::tvband  -bandcolors [list #FFFFFF #FFEECC]
#' foreach col [list A B C] { $tv2 heading $col -text $col }
#' for {set i 0} {$i < 20} {incr i 1} {
#'    $tv2 insert {} end -values [list  [expr {int(rand()*100)}] \
#'                   [expr {int(rand()*1000)}] [expr {int(rand()*1000)}]]
#' }
#' pack $tv2 -side top -fill both -expand yes
#' update idletasks
#' after 3000
#' $tv2 configure -bandcolors [list salmon white]
#' ```
#'
#' ## <a name='mixins'></a> MIXINS
#'
#' 
#' <a name="tvband">**dgw::tvband**</a> 
#' *pathName mixin* **tvband** *?-option value ...?*
#' 
#' > Creates and configures the mixin *paul::tvband* for a *tkoo::treeview* using the Tk window id _pathName_ and the given *options*. 
#'
#' > Please note that this adaptor might have performace issues and that the 
#'   *ttk::treeview* widget of Tk 8.7 / 9.0
#'   probably will have a configure option *-striped* and *-stripedbackgroundcolor* which can replace this adaptor.
#'
#' > The following option is available:
#'
#' > - *-bandcolors* *list*  - list of the two colors to be displayed alternatively.
#' 
#' > Example:
#' 
#' ```
#' # demo: tvband
#' set tvband [tkoo::treeview .tv4 -columns [list A B C] -show headings]
#' $tvband mixin paul::tvband
#' foreach col [list A B C] { $tvband heading $col -text $col }
#' for {set i 0} {$i < 20} {incr i 1} {
#'    $tvband insert {} end -values [list  [expr {int(rand()*100)}] \
#'                   [expr {int(rand()*1000)}] [expr {int(rand()*1000)}]]
#' }
#' pack $tvband -side top -fill both -expand yes
#' ```

# widget adaptor which does a banding of the ttk::treeview 
# widget automatically after each insert command
package require oowidgets
catch { rename ::paul::tvband {} }

puts [info commands ::oo::Helpers::*]
::oo::class create ::paul::tvband {
    variable win
    method tvband {args} {
        my option -bandcolors [list #FFFFFF #DDEEFF]
        my configure {*}$args
        $win tag configure band0 -background [lindex [my cget -bandcolors] 0]
        $win tag configure band1 -background [lindex [my cget -bandcolors] 1]
        trace add execution $win leave [mymethod wintrace]
        # new line
        bind $win <<SortEnd>> [mymethod band]
        my band
    }
    # new method
    method band {} {
        set i 0
        foreach item [$win children {}] {
            set t [expr { [incr i] % 2 }]
            $win tag remove band0 $item 
            $win tag remove band1 $item
            $win tag add band$t $item
        }
    }
    method configure args {
        next {*}$args
        if {[lindex $args 0] eq "-bandcolors"} {
            $win tag configure band0 -background [lindex [my cget -bandcolors] 0]
            $win tag configure band1 -background [lindex [my cget -bandcolors] 1]
        }
    }
    method wintrace {args} {
        set path [lindex [lindex $args 0] 0]
        set meth [lindex [lindex $args 0] 1]
        if {$meth eq "insert"} {
            set parent [lindex [lindex $args 0] 2]
            set index [lindex [lindex $args 0] 3]
            set item [lindex [$path children $parent] $index]
            if {$index eq "end"} {
                set i [llength [$path children $parent]]
            } else {
                set i $index
            }
            set t [expr { $i % 2 }]
            $path tag remove band0 $item 
            $path tag remove band1 $item
            $path tag add band$t $item
        }
    }
}
#'
#' <a name="tvfilebrowser"> </a>
#' *pathName mixin* **tvfilebrowser** *?-option value ...?*
#' 
#' > Creates and configures the mixin *paul::tvfilebrowser* for a *tkoo::treeview* using the Tk window id _pathName_ and the given *options*. 
#'
#' > The following option is available:
#'
#' > - *-directory dirName* - starting directory for the filebrowser, default current directory.
#' - *-browsecmd cmdName* - command to be executed if the users double clicks on a row item or presses the Return key. The widgets *pathName* and the actual row index are appended to the *cmdName* as arguments, default to empty string.
#' - *-fileimage imgName* - image to be displayed as filename image left of the filename, default is standard file icon.
#' - *-filepattern pattern* - the filter for the files to be displayed in the widget, default to ".+" i.e. all files
#' 
#' > The following method(s) is(are) available:
#' 
#' > - *browseDir dirName* - the directory to be loaded into the *paul::tvfilebrowser* widget.
#' 
#' > Example:
#'
#' ```{.tcl eval=true}
#' package require paul
#' proc onClick {fname} {
#'   puts "Clicked $fname"
#' }
#' set tv [tkoo::treeview .tv3]
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

#'
#' <a name="tvsortable"></a> 
#' *pathName mixin* **paul::tvsortable** *?-option value ...?*
#'
#' > Creates and configures the mixin *paul::tvsortable* for a *tkoo::treeview* using the Tk window id _pathName_ and the given *options*. 
#'
#' > The following option is available:
#'
#' > - *-sorttypes* the options for the *lsort* command for each of the columns, 
#'     such as dictionary, ascii, real etc. Default: autocheck for dictionary or real. 
#'     The values are given as a list of key-value pairs where the key is 
#'     the column name. In addition to the standard *lsort* options as well 
#'     the option *directory* can be given if the widget contains results of a 
#'     directory listening with filenames and directory names. 
#'     In this case the directories are always sorted above the filenames.
#' 
#' > The following methods are available which should be used usually on internally:
#'
#' > - *sortBy* *colId decreasing* - sort widget by column with the given *colId* and in decreasing order if true or *increasing* if false.
#'   - *reSort* redo the last sorting again, useful if the data in the widget where changed either interactively for instance using the *tvedit* adaptor or programmatically.
#' 
#' > The widget further provides the following event:
#' 
#' > - <<*SortEnd*\>> - with the following symbols *%W* (widget path) and *%d* (column id)
#' 
#' > Example:
#' 
#' ```
#' # demo: tvsortable
#' tkoo::treeview .tvs -columns [list A B C] \
#'        -show headings]
#' .tvs mixin tvsortable -sorttypes [list A real B real C integer]
#' foreach col [list A B C] { .tvs heading $col -text $col }
#' for {set i 0} {$i < 20} {incr i 1} {
#'    .tvs insert {} end -values [list  [expr {int(rand()*100)}] \
#'                   [expr {int(rand()*1000)}] [expr {int(rand()*1000)}]]
#' }
#' pack .tvs -side top -fill both -expand yes
#' update idletasks
#' after 3000
#' ```
#'
catch { rename ::paul::tvsortable {} }

::oo::class create ::paul::tvsortable {
    variable sortOpt
    variable lastCol ""
    variable lastDir ""
    variable win
    method tvsortable {args} {
        set win [my widget]
        my option -sorttypes [list]
        my configure {*}$args
        array set sortOpt [my cget -sorttypes]
        set headers [$win cget -columns]
        set x 0
        foreach col $headers {
            $win heading $col -image ::paul::arrowBlank \
                  -command [mymethod sortBy $col 0] 
        }

    }
    method sortBy {col direction} {
        set lastCol $col
        set lastDir $direction
        #set mtimer [Timer %AUTO%]
        set ncol [lsearch -exact [$win cget -columns] $col]
        if {![info exists sortOpt($col)]} {
            set fchild [lindex [$win children ""] 0]
            set fvalues [$win item $fchild -values]
            set i 0
            foreach heading [$win cget -columns] {
                if {[$win heading $heading -text] eq "$col"} {
                    set val [lindex $fvalues $i]
                    break
                }
                incr i
            }
            if {[string is double $val]} {
                set stype real
            } else {
                set stype dictionary
            }
        } else {
            set stype $sortOpt($col)
        }
        set dir [expr {$direction ? "-decreasing" : "-increasing"}]
        if {[lsearch [array get sortOpt] directory] > -1} {
            set hasDir true
            foreach key [array names sortOpt] {
                if {$sortOpt($key) eq "directory"} {
                    set cname $key
                    set i 0
                    foreach heading [$win cget -columns] {
                        if {[$win heading $heading -text] eq "$cname"} {
                            set didx $i
                            break
                        }
                        incr i
                    }
                    break
                }
            }
        } else {
            set hasDir false
        }
        
        set l [list]
        foreach child [$win children {}] {
            set val [lindex [$win item $child -values] $ncol]
            if {$stype eq "directory"} {
                # ensure that ..  is always on top
                # and thereafter sorted directories
                # and only then sorted files
                if {$val eq ".." && $direction} {
                    set val "Z$val"
                } elseif {$val eq ".."} {
                    set val "A$val"
                } elseif {[file isdirectory $val] && $direction} {
                    set val "O$val"
                } elseif {[file isdirectory $val]} {
                    set val "D$val"
                } else {
                    set val "F$val"
                }
                lappend l [list $val $child]
            } elseif {$hasDir} {
                set val [lindex [$win item $child -values] $ncol]
                set fname [lindex [$win item $child -values] $didx]
                if {$fname eq ".."} {
                    set letter A
                } elseif {[file isdirectory $fname]} {
                    set letter D
                } else {
                    set letter F
                }
                lappend l [list $val $child $letter]
            } else {
                lappend l [list $val $child]
            }
        }
        if {$hasDir && ($stype eq "real" || $stype eq "integer")} {
            set l  [lmap x $l { list [regsub -all {[^0-9\.]} [lindex $x 0] "0"] [lindex $x 1] [lindex $x 2] }]
        } elseif {$stype eq "real" && $stype eq "integer"} {
            set l  [lmap x $l { list [regsub -all {[^0-9]} [lindex $x 0] ""] [lindex $x 1] }]
        }
        #set idx [lsort -$stype -indices -index 0 $dir $l]
        if {$stype eq "directory"} {
            set l [lsort -dictionary -index 0 $dir $l]
        } elseif {$hasDir} {
            #puts $l
            set l [lsort -dictionary -index 2 -increasing [lsort -$stype -index 0 $dir $l]]
            #puts $l
        } else {
            set l [lsort -$stype -index 0 $dir $l]
        }
        for {set i 0} {$i < [llength $l]} {incr i 1} {
            set item [lindex [lindex $l $i] 1]
            $win move $item {} $i
        }
        set idx -1
        foreach ccol [$win cget -columns] {
            incr idx
            set img ::paul::arrowBlank
            if {$ccol == $col} {
                set img ::paul::arrow($direction)
            }
            $win heading $idx -image $img
        }
        set cmd [mymethod sortBy $col [expr {!$direction}]]
        $win heading $col -command $cmd
        # new event
        event generate $win <<SortEnd>> -data $col
    }
    method reSort {} {
        if {$lastCol ne ""} {
            my sortBy $lastCol $lastDir
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
