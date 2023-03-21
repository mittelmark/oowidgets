# oowidgets

Package for creating megawidgets using TclOO (WIP).

**Files:**

- [oowidgets/oowidgets.tcl](oowidgets/oowidgets.tcl) - implementation
- [oowidgets/pkgIndex.tcl](oowidgets/pkgIndex.tcl) - the package file
- [samples/flash.tcl](samples/flash.tcl) - some sample code to create widgets

**Links:**

- [Tutorial](https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/oowidgets/master/tutorial.html)
- [Manual](https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/oowidgets/master/oowidgets/oowidgets.html)
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

For more examples, including creating composite widgets, using mixins, see the [tutorial](https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/oowidgets/master/tutorial.html)

There is a sample project which uses `TclOO` and `oowidgets` to create mega widgets. Here two example commands:

- [paul::basegui](https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/oowidgets/master/paul/basegui.html) - base class to build Tk applications, [code](paul/basegui.tcl) 
- [paul::statusbar](https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/oowidgets/master/paul/statusbar.html) - composite widget based on a `ttk::frame`, a `ttk::label` and a `ttk::progessbar`, , [code](paul/statusbar.tcl) 

PS: package name inspired by some wiki code about creating megawidgets with TclOO from which a lot of code was "stolen"..

**License:** BSD




