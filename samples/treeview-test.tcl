lappend auto_path [file join [file dirname [info script]] ..]
package require oowidgets
namespace eval ::test { }
oowidgets::widget ::test::Treeview {
    constructor {path args} {
        my install ttk::treeview $path
        my configure {*}$args
    }
}

test::treeview .tree -columns [list Row1 Row2] -displaycolumns [list Row2 Row1]
.tree heading Row1 -text "row1" -anchor center
.tree heading Row2 -text "row2" -anchor center
pack .tree
