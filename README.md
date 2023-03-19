# oowidgets

Package for creating megawidgets using TclOO (WIP).

**Files:**

- [oowidgets/oowidgets.tcl](oowidgets/oowidgets.tcl) - implementation
- [oowidgets/pkgIndex.tcl](oowidgets/pkgIndex.tcl) - the package file
- [samples/flash.tcl](samples/flash.tcl) - some sample code to create widgets

**Links:**

- [Download](https://github.com/mittelmark/oowidgets/archive/refs/heads/main.zip)
- [Wiki](https://wiki.tcl-lang.org/page/oowidgets)

**Usage:**

```
oowidgets::widget CLASSNAME CODE
```

This will create a command classname where all letters are lower case. The
classname must have at least one uppercase letter to distinguish it from the
Tcl command name. Here an example:

```
package require oowidgets
namespace eval ::flash { }
oowidgets::widget ::flash::Label {
    constructor {path args} {
        my install ttk::label $path -flashtime 200
        my configure {*}$args
    }
    method flash {} {
        set fg [my cget -foreground]
        for {set i 0} {$i < 10} {incr i} {
            my configure -foreground blue
            update idletasks
            after [my cget -flashtime]
            my configure -foreground $fg
            update idletasks
            after [my cget -flashtime]
        }
    }
}
```

This widget can be then used for instance like this:

```
set fl [flash::label .fl -text "FlashLabel" -flashtime 50 -anchor center]
pack $fl -side top -padx 10 -pady 10 -fill both -expand true
$fl flash
```

For more examples, including creating composite widgets, using mixins, see the file [samples/flash.tcl](samples/flash.tcl).

**License:** BSD




