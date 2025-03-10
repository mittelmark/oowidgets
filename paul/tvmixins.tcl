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
#' > - [paul::tvband](#tvband) - adding stripes to treeview widget
#' > - [paul::tvedit](#tvedit) - editable cells for a treeview widget
#' > - [paul::tvfilebrowser](#tvfilebrowser) - file browser widget
#' > - [paul::tvksearch](#tvksearch) - bind home and end as well as typing navigation
#' > - [paul::tvsortable](#tvsortable) - a sortable treeview
#' > - [paul::tvtooltip](#tvtooltip) - tool tips for the treeviewwidget
#' > - [paul::tvtree](#tvtree) - a tree widget with icon support
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
#' $tv mixin mixiname ?-option value ... mixinname -option value ...?
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
#' $tv mixin paul::tvfilebrowser -browsecmd onClick paul::tvksearch
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
#' set tree [tkoo::treeview .tree \
#'      -height 15 -show tree -selectmode browse]
#' $tree mixin paul::tvtree -icon folder paul::tvtooltip
#' foreach txt {first second third} {
#'    set id [$tree insert {} end -text " $txt item" -open 1]
#'    for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
#'        set child [$tree insert $id 0 -text " child $i"]
#'        for {set j [expr {int(rand()*3)}]} {$j > 0} {incr j -1} {
#'           $tree insert $child 0 -text " grandchild $i"
#'        }
#'    }
#' }
#' pack $tree -side top -fill both -expand true
#' pack [::ttk::label .msg -font "Times 12 bold" -textvariable ::msg -width 20 \
#'       -background salmon -borderwidth 2 -relief ridge] \
#'       -side top -fill x -expand false -ipadx 5 -ipady 4
#' bind $tree <<RowEnter>> { set ::msg "  Entering row %d"}
#' bind $tree <<RowLeave>> { set ::msg "  Leaving row %d"}
#' ```
#'
#' ## <a name='mixins'></a> MIXINS
#'
#' 
#' <a name="tvband"> </a> 
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

::oo::class create ::paul::tvband {
    variable win
    method tvband {args} {
        set win [my widget]
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
    unexport wintrace
}

#'
#' <a name="tvedit"> </a>
#' *pathName mixin* **paul::tvedit* *?-option value ...?*
#' 
#' > Creates and configures the mixin *paul::tvedit* for a *tkoo::treeview* widget using the Tk window id _pathName_ and the given *options*. 
#'   This widget adaptor allows to do in place edits of the text within the ttk::treeview widget. The code is largly based on the wiki code in [Inplace edit in ttk::treeview](https://wiki.tcl-lang.org/page/Inplace+edit+in+ttk%3A%3Atreeview). Note: Currently only tabular, non hierarchical *ttk::treeview* widget's can be edited.
#'
#' > The following optiosn are available:
#'
#' The following options are available:
#'
#' > - *-edittypes* *list*  - list of key values pairs where the key is the colummn name and 
#'       the values are pssible data types or lists of available values. The following data types are available
#'   1. *bool* provides a boolean value selection of true and false using a check box
#'   1. *int* a integer range of values must be given as: *int [list start end]*
#'   1. *list* list of possible values must be given with the values such as: *list [list A B C D E]*
#'   1. the default if no type is provided for a column name is a text entry with free text edition available
#' 
#' > - *-editdefault* *type* the default edit is a entry text field, if you set this to an empty string only columns listed in the *-edittypes* options can be edited.
#' 
#' > - *-editendcmd* *commandName* the command to be executed after the value was changed. 
#'     The widget path, the data type, the row id, the old and the new value are added as command arguments. This method can be used to validate the input as well and to perform some actions after the entry was edited.
#' 
#' > The widget provides the follwing events:
#' 
#' >  - <<*TreeviewEditEnd*\>> which is fired if a entry in the *ttk::treeview* widget
#'     is changed.  The following event symbols are available: *%d* a list of the row index and the column name which was changed, *%W* (widget).
#' 
#' > Bindings:
#' 
#' > - *<KeyPress-F2>* - edit current row entries
#' - *<KeyPress-Escape>* - cancel edits
#' - *<KeyPress-Return>* - save edit and end current edits
#' - *<KeyPress-Tab>* - switch to the next edit field
#' - *<KeyPress-Shift-Tab>* - switch to the previous edit field
#' 
#' > Example:
#' 
#' ```
#' # demo: tvedit
#' proc editDone {args} {
#'       puts "done: $args"
#' }
#' set tve [tkoo::treeview .tve -columns {bl in li st} -show {headings} \
#'    -selectmode extended -yscrollcommand {.sb set}]
#' $tve mixin paul::tvband paul::tvedit  -edittypes [list \
#'                      bl bool \
#'                      in [list int 0 100] \
#'                      li [list list "Letter A" "Letter B" "Letter C" "Letter D"] \
#'                      st string] \
#'    -editdefault "" -editendcmd editDone
#' pack $tve -fill both -expand true -side left
#' pack [ttk::scrollbar .sb -orient v -command ".tve yview"] -fill y -side left
#' $tve insert {} end -values {true 15 {Letter B} world}
#' $tve insert {} end -values {true 35 {Letter D} world}
#' for {set i 0} {$i<20} {incr i} {
#'      .tve insert {} end -values [list true $i {Letter B} hello]
#' }
#' 
#' ```
#' 
#' > Acknowledgment Code: [Tcler Wiki](https://wiki.tcl-lang.org/page/Inplace+edit+in+ttk%3A%3Atreeview)

catch { rename ::paul::tvedit {} }

::oo::class create ::paul::tvedit {
    variable edittypes
    variable curfocus
    variable win
    method tvedit {args} {
        my option -edittypes [list]
        my option -editdefault entry
        my option -editendcmd ""
        set win [my widget]
        my configure {*}$args
        # intercept all the events changing focus
        #bind $win <<TreeviewSelect>> +[mymethod checkFocus %W]
        bind $win <KeyPress-F2> +[mymethod checkFocus %W %x %y]
        #bind $win <KeyRelease> +[mymethod  checkFocus %W]
        bind $win <ButtonPress-4> +[list after idle [mymethod updateWnds %W]]
        bind $win <ButtonPress-5> +[list after idle [mymethod updateWnds %W]]
        bind $win <MouseWheel> +[list after idle [mymethod updateWnds %W]]
        bind $win <B1-Motion> +[list if {$ttk::treeview::State(pressMode)=="resize"} { [mymethod updateWnds %W] }]
        bind $win <Configure> +[list after idle [mymethod updateWnds %W]]
        bind all <KeyPress-Return> +[mymethod _clear $win %d]
        #bind all <KeyPress-Escape> +[mymethod _clear $win %d]
        bind $win <<TreeviewInplaceEdit>> [mymethod InplaceEdit %d %v] 
        array set edittypes [my cget -edittypes]
    }
    method InplaceEdit {d v} {
        if {[$win children [lindex $d 1]]==""} {
            set col [lindex $d 0] 
            if {$col eq "#0"} {
                my _inplaceEntry $win {*}$d 
            } elseif {[info exists edittypes($col)]} {
                if {$edittypes($col) eq "bool"} {
                    my _inplaceCheckbutton $win {*}$d true false
                } elseif {[lindex $edittypes($col) 0] eq "int"} {
                    my _inplaceSpinbox $win {*}$d [lindex $edittypes($col) 1] [lindex $edittypes($col) 2] 1
                } elseif {[lindex $edittypes($col) 0] eq "list"} {
                    my _inplaceList $win {*}$d [lrange $edittypes($col) 1 end]
                } else {
                    my _inplaceEntry $win {*}$d
                }
            } else {
                if {[my cget -editdefault] eq "entry"} {
                    $win _inplaceEntry $win {*}$d
                }
            }
        } elseif {[lindex $d 0]=="list"} {
            # did not work yet
            $win _inplaceEntryButton $win {*}$d [list set %$v "tree: $win, column,item=$d"]
        }
    }
    # check, if focus has changed
    method checkFocus {w {X {}} {Y {}} } {
        if {![info exists curfocus($w)]} {
            set changed 1
        } elseif {$curfocus($w)!=[$w focus]} {
            my _clear $w $curfocus($w)
            set changed 1
        } else {
            set changed 0
        }
        set newfocus [$w focus]
        if {$changed} {
            if {$newfocus!=""} {
                my _focus $w $newfocus
                if {$X!=""} {
                    set col [$w identify column $X $Y]
                    if {$col!=""} {
                        if {$col!="#0"} {
                            set col [$w column $col -id]
                        }  
                    }  
                    catch {focus $w.$col}
                }  
            }        
            set curfocus($w) $newfocus
            my updateWnds $w 
        }
    }
    # update inplace edit widgets positions
    method updateWnds {w} {
        if {![info exists curfocus($w)]} { return }
        set item $curfocus($w)
        if {$item==""} { return }
        foreach col [concat [$w cget -columns] #0] {
            set wnd $w.$col
            if {[winfo exists $wnd]} {
                set bbox [$w bbox $item $col]
                if {$bbox==""} { 
                    place forget $wnd
                } else {
                    place $wnd -x [lindex $bbox 0] -y [lindex $bbox 1] -width [lindex $bbox 2] -height [lindex $bbox 3]
                }
            }
        }
    }
    # remove all inplace edit widgets
    method _clear {w {item ""}} {
        foreach col [concat [$w cget -columns] #0] {
            set wnd $w.$col
            if {[winfo exists $wnd]} { 
                destroy $wnd
            }
        }
    }
    # called when focus item has changed
    method _focus {w item} {
        set cols [$w cget -displaycolumns]
        if {$cols=="#all"} { 
            set cols [concat #0 [$w cget -columns]]
        }
        foreach col $cols {
            event generate $w <<TreeviewInplaceEdit>> -data [list $col $item]
            if {[winfo exists $w.$col]} {
                bind $w.$col <Key-Tab> {focus [tk_focusNext %W]}
                bind $w.$col <Shift-Key-Tab> {focus [tk_focusPrev %W]}
            }
        }
    }
    # helper functions for inplace edit
    method _get_value {w column item} {
        if {$column=="#0"} {
            return [$w item $item -text]
        } else {
            return [$w set $item $column]
        }
    }
    method _set_value {w column item value} {
        if {$column=="#0"} {
            $w item $item -text $value
        } else {
            $w set $item $column $value
        }
    }
    method _cancel_value {w column item} {
        set value [my _get_value $w $column $item]
        set curfocus($w,$column) $value
        my _clear $w
        focus -force $w
    }

    method _update_value {w column item} {
        set value [my _get_value $w $column $item]
        set newvalue $curfocus($w,$column)
        if {$value!=$newvalue} {
           my _set_value $w $column $item $newvalue
       }
       if {[my cget -editendcmd] ne ""} {
           [my cget -editendcmd] $w $column $item $value $newvalue
       }
       focus -force $w
       event generate $w <<TreeviewEditEnd>> -data [list $item $column]
    }
    # these functions create widgets for in-place edit, use them in your in-place edit handler
    method _inplaceEntry {w column item} {
        set wnd $w.$column 
        ttk::entry $wnd -textvariable [myvar curfocus($w,$column)] -width 3
        set curfocus($w,$column) [my _get_value $w $column $item]
        bind $wnd <Destroy> [mymethod _update_value $w $column $item]
        bind $wnd <KeyPress-Escape> [mymethod _cancel_value $w $column $item]
    }
    method _inplaceEntryButton {w column item script} {
        set wnd $w.$column
        ttk::frame $wnd
        pack [ttk::entry $wnd.e -width 3 -textvariable [myvar curfocus($w,$column)]] -side left -fill x -expand true
        pack [ttk::button $wnd.b -style Toolbutton -text "..." -command [string map [list %v [myvar curfocus($w,$column)]] $script]] -side left -fill x 
        set curfocus($w,$column) [my _get_value $w $column $item]
        bind $wnd <Destroy> [mymethod _update_value $w $column $item]
        bind $wnd <KeyPress-Escape> [mymethod _cancel_value $w $column $item]
    }
    method _inplaceCheckbutton {w column item {onvalue 1} {offvalue 0} } {
        set wnd $w.$column 
        ttk::checkbutton $wnd -variable [myvar curfocus($w,$column)] -onvalue $onvalue -offvalue $offvalue
        set curfocus($w,$column) [my _get_value $w $column $item]
        bind $wnd <Destroy> [mymethod _update_value $w $column $item]
        bind $wnd <KeyPress-Escape> [mymethod _cancel_value $w $column $item]
    }
    method _inplaceList {w column item values} {
        set wnd $w.$column 
        ttk::combobox $wnd -textvariable [myvar curfocus($w,$column)] -values $values -state readonly 
        set curfocus($w,$column) [my _get_value $w $column $item]
        bind $wnd <Destroy> [mymethod _update_value $w $column $item]
        bind $wnd <KeyPress-Escape> [mymethod _cancel_value $w $column $item]
    }
    method _inplaceSpinbox {w column item min max step} {
        set wnd $w.$column 
        spinbox $wnd -textvariable [myvar curfocus($w,$column)] -from $min -to $max -increment $step
        set curfocus($w,$column) [my _get_value $w $column $item]
        bind $wnd <Destroy> [mymethod _update_value $w $column $item]
        bind $wnd <KeyPress-Escape> [mymethod _cancel_value $w $column $item]
    }
}


#'
#' <a name="tvfilebrowser"> </a>
#' *pathName mixin* **tvfilebrowser** *?-option value ...?*
#' 
#' > Creates and configures the mixin *paul::tvfilebrowser* for a *tkoo::treeview* using the Tk window id _pathName_ and the given *options*. 
#'
#' > The following options are available:
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
#' # demo: tvfilebrowser
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
    unexport fbReturn fbOnClick
    
}

#'
#' <a name="tvksearch"></a>
#' *pathName mixin* **paul::tvksearch** 
#'
#' > Adds the mixin *paul::tvksearch* for a *tkoo::treeview* using the Tk window id _pathName_. 
#'
#' > With this widget you can use the Home and End keys for navigation and further letter
#'   typing starts searching in the first column shifting focus and display to the current matching entry.
#'
#' > There are currently no options or methods available for this widget.
#'
#' > Example:
#' 
#' ```
#' # demo: tvksearch
#' set tvk [tkoo::treeview .tvk]
#' $tvk mixin paul::tvfilebrowser paul::tvksearch
#' pack $tvk -side top -fill both -expand yes
#' ```
#' 
# widget adaptor which allows forward searching in a ttk::treeview 
# using the starting letters matchinf entries in column 1
# with typing beginning letters 
# further has bindings of Home and End key
catch { rename ::paul::tvksearch {} }

::oo::class create ::paul::tvksearch {
    variable LastKeyTime ""
    variable LastKey ""
    variable win
    method tvksearch {args} {
        set win [my widget]
        bind $win <Key-Home>  [mymethod SetSelection 0]
        bind $win <Key-End>   [mymethod SetSelection end]
        bind $win <Any-Key> [mymethod ListMatch %A]
        set LastKeyTime [clock seconds]
        my configure {*}$args
        ## should be only called once
    }
    method SetSelection {index} {
        my focus [lindex [my children {}] $index]
        my selection set  [lindex [my children {}] $index]
        focus -force $win
        my see [lindex [my selection] 0]
    }
    method ListMatch {key} {
        if [regexp {[-A-Za-z0-9]} $key] {
            set ActualTime [clock seconds]
            if {[expr {$ActualTime-$LastKeyTime}] < 3} {
                set ActualKey "$LastKey$key"
            } else {
                set ActualKey $key
            }

            set n 0
            foreach i [$win children {}] {
                set name [lindex [$win item $i -value] 0]
                if [string match $ActualKey* $name] {
                    $win selection remove [$win selection]
                    $win focus $i 
                    $win selection set  $i
                    focus -force $win
                    $win see $i
                    set LastKeyTime [clock seconds]
                    set LastKey $ActualKey
                    break
                } else {
                    incr n
                }
            }
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
#' tkoo::treeview .tvs -columns [list A B C] -show headings
#' .tvs mixin paul::tvsortable -sorttypes [list A real B real C integer]
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
    unexport reSort sortBy

}
#'
#' <a name="tvtooltip"> </a>
#' *pathName mixin* **paul::tvtooltip** *?-option value ...?*
#'
#' > Creates and configures the mixin *paul::tvtooltip* for a *tkoo::treeview* using the Tk window id _pathName_ and the given *options*. 
#'
#' > There are currently no options available.
#' 
#' > The widget provides the following events:
#' 
#' > - <<RowEnter\>> with the following symbols: %d the row index, and the standards %W (widget), %x (widgetX), %y (widgetY), %X (rootx), %Y (rootY)
#'   - <<RowLeave\>> with the following symbols: %d the row index, and the standards %W (widget), %x (widgetX), %y (widgetY), %X (rootx), %Y (rootY)
#'
#' > Example:
#' 
#' ```
#' # demo: tvtooltip
#' set tt [tkoo::treeview .fp2]
#' $tt mixin ::paul::tvtooltip ::paul::tvfilebrowser \
#'          -directory . -fileimage movie \
#'          -filepattern {\.(3gp|mp4|avi|mkv|mp3|ogg)$}
#' 
#' pack $tt -side top -fill both -expand yes
#' pack [::ttk::label .msg -font "Times 12 bold" -textvariable ::msg -width 20 \
#'       -background salmon -borderwidth 2 -relief ridge] \
#'       -side top -fill x -expand false -ipadx 5 -ipady 4
#' bind $tt <<RowEnter>> { set ::msg "  Entering row %d"}
#' bind $tt <<RowLeave>> { set ::msg "  Leaving row %d"}
#' ```
#' 

# https://wiki.tcl-lang.org/page/TreeView+Tooltips
catch { rename ::paul::tvtooltip {} }

::oo::class create ::paul::tvtooltip {
    variable LAST 
    variable AFTERS 
    variable win
    method tvtooltip {args} {
        set win [my widget]
        my configure {*}$args
        array set LAST [list $win ""]
        array set AFTERS [list $win ""]
        bind $win <Motion> [mymethod OnMotion %W %x %y %X %Y]
    }
    method OnMotion {W x y rootX rootY} {
        set id [$W identify row $x $y]
        set lastId $LAST($W)
        set LAST($W) $id
        if {$id ne $lastId} {
            after cancel $AFTERS($W)
            if {$lastId ne ""} {
                event generate $W <<RowLeave>> \
                      -data $lastId -x $x -y $y -rootx $rootX -rooty $rootY
            }
            if {$id ne ""} {
                set AFTERS($W) \
                      [after 300 event generate $W <<RowEnter>> \
                       -data $id -x $x -y $y -rootx $rootX -rooty $rootY]
            }
        }
    }
}


#'
#' <a name="tvtree"> </a>
#' *pathName mixin* **paul::tvtree** *?-option value ...?*
#'
#' > Creates and configures the mixin *paul::tvtree* for a *tkoo::treeview* using the Tk window id _pathName_ and the given *options*. 
#'
#' > The following option is available:
#' 
#' - *-icon* - the icon type, which can be currently either book or folder. To provide your own icons you must create two image icons \<name\>open16 and \<name\>close16. Support for icons of size 22 will be added later.
#' 
#' > The widget provides the following event:
#' 
#' - <<InsertItem\>> which is fired if a item is inserted into the *tvtree* widget, there are the following event symbols available: _%d_ the row index, and the standard _%W_ (widget pathname).
#'
#' > Example:
#' 
#' ```{.tcl eval=true}
#' # demo: tvtree
#' set tree [tkoo::treeview .tree2 \
#'      -height 15 -show tree -selectmode browse]
#' $tree mixin paul::tvtree -icon folder
#' foreach txt {first second third} {
#'    set id [$tree insert {} end -text " $txt item" -open 1]
#'    for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
#'        set child [$tree insert $id 0 -text " child $i"]
#'        for {set j [expr {int(rand()*3)}]} {$j > 0} {incr j -1} {
#'           $tree insert $child 0 -text " grandchild $i"
#'        }
#'    }
#' }
#' pack $tree -side top -fill both -expand true
#' ```
#' 
catch { rename ::paul::tvtree {} }

::oo::class create ::paul::tvtree {
    variable win
    method tvtree {args} {
        set win [my widget]
        my option -icon ::paul::book
        
        my configure {*}$args
        trace add execution $win leave [mymethod tvwintrace]
                      bind $win <<TreeviewOpen>> [mymethod TreeviewUpdateImages true]
        bind $win <<TreeviewClose>> [mymethod TreeviewUpdateImages false]
        bind $win <<InsertItem>> [mymethod InsertItem %d]
    }
    method tvwintrace {args} {
        set path [lindex [lindex $args 0] 0]
        set meth [lindex [lindex $args 0] 1]
        if {$meth eq "insert"} {
            set parent [lindex [lindex $args 0] 2]
            set index [lindex [lindex $args 0] 3]
            set item [lindex [$path children $parent] $index]
            event generate $win <<InsertItem>> -data $item
        }
    }
    method InsertItem {item} {
        set parent [$win parent $item]
        $win item $item -image ::paul::file16
        if {$parent eq {}} {
            $win item $item -image ::paul::file16
        } else {
            if {[$win item $parent -open]} {
                $win item $parent -image ::paul::[my cget -icon]open16
            } else {
                $win item $parent -image ::paul::[my cget -icon]close16
            }
        }
    }

    method TreeviewUpdateImages {open} {
        # event fires before 
        # the children are indeed displayed or hided
        set item [$win focus]
        if {$open} {
            if {[llength [$win children $item]] > 0} {
                $win item $item -image ::paul::[my cget -icon]open16
            }
        } else {
            if {[llength [$win children $item]] > 0} {
                $win item $item -image ::paul::[my cget -icon]close16
            }
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
#' A lot of code was taken from the [Tclers Wiki]() and made usuable in real applications
#' by myself by reorganizing the code and fixing possible issues.
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
    } elseif {[llength $argv] >= 1 && [lindex $argv 0] eq "--demo"} {
        set section ""
        if {[llength $argv] == 2} {
            set section [lindex $argv 1]
        } 
        set code [::paul::getExampleCode [info script] $section]
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
