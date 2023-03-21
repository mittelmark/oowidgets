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
    method new {w} {
        frame $nb.f[llength [$nb tabs]]
        $self add $nb.f[llength [$nb tabs]] -text "Tab [expr {[llength [$nb tabs]] + 1}]"
    }
    method bind {ev script} {
        bind $nb $ev $script
    }
    method tabClose {w} {
        set child [$w select]
        set answer [tk_messageBox -title "Question!" -message "Really close tab [$w tab $child -text] ?" -type yesno -icon question]
        if { $answer } {
            $w forget $child
            destroy $child
        } 
    }
    method tabRename {x y} {
        set nbtext ""
        if {![info exists .rename]} {
            toplevel .rename
            wm overrideredirect .rename true
            #wm title .rename "DGApp" ;# for floating on i3
            set x [winfo pointerx .]
            set y [winfo pointery .]
            entry .rename.ent -textvariable [myvar nbtext]
            # [namespace qualifiers [namespace which my]]::nbtext
            pack .rename.ent -padx 5 -pady 5
        }
        wm geometry .rename "180x40+$x+$y"
        set tab [$nb select]
        set nbtext [$nb tab $tab -text]
        focus -force .rename.ent
        bind .rename.ent <Return> [callback doTabRename %W]
        bind .rename.ent <Escape> [list destroy .rename]
        
    }
    method doTabRename {w} {
        set tab [$nb select]
        $nb tab $tab -text $nbtext
        if {[my cget -renamecmd] ne ""} {
            eval [my cget -renamecmd] $nb $tab
        }

        destroy .rename
    }
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
}


pack [paul::notebook .nb]
	.nb add [frame .nb.f1] -text "First tab"
	.nb add [frame .nb.f2] -text "Second tab"
	.nb select .nb.f2
        ttk::notebook::enableTraversal .nb
