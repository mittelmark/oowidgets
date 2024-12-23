#' ---
#' title: paul::basegui base class for building Tk applications
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
#' > **paul::basegui** - starting point class for writing Tk applications
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [TYPE OPTIONS](#options)
#'  - [TYPE COMMANDS](#commands)
#'  - [EXAMPLE](#example)
#'  - [INHERITANCE](#inheritance)
#'  - [SEE ALSO](#see)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' package require paul
#' ```
#' 
#' ```
#' package require paul
#' paul::basegui cmdName
#' cmdName addStatusBar
#' cmdName getFrame
#' cmdName getMenu
#' cmdName splash imgfile ?-delay milliseconds -message textmessage?
#' cmdName status msg ?value?
#' cmdName timer mode
#' ```

package require Tk
package require paul

#' ## <a name='description'>DESCRIPTION</a>
#'
#' The **paul::basegui** application class serves as building block for writing  Tk applications. 
#' It can be used for new applications as starting point providing for instance a ready to use menubar, a mainframe,
#' a statusbar and splash screen or facility to center a window on the screen. 
#'
#' ## <a name='command'>COMMAND</a>
#'
#' **paul::basegui** *cmdName ?options?*
#' 
#' > Creates and configures a new paul::basegui application  using the main Tk window id _._ and the given *options*. 
#'  

namespace eval paul { }

#' ## <a name='options'>CLASS OPTIONS</a>
#' 
#' The **paul::basegui** class supports the following options:

catch {rename ::paul::basegui ""}
oo::class create ::paul::basegui {
    #' 
    #'   __-style__ _styleName_ 
    #' 
    #'  > Configures the ttk style for all widgets within the application. 'clam' and 'default' should be supported on all platforms. 
    #'    Use `ttk::style theme names` within an interactive wish session to find out which themes are available on your machine. Default: clam
    #' 
    #' ## <a name='method'>CLASS METHODS</a>
    #' 
    #' The **paul::basegui** command supports the following public methods to be used
    #' within inheriting applications to extend the basic application.
    #' Alternatively widgets can be added to existing applications as well.
    #' > The following methods are available:
    #' 
    #' >  - [about](#about)
    #'    - [addStatusBar](#addStatusBar)
    #'    - [autoscroll](#autoscroll)
    #'    - [balloon](#balloon)
    #'    - [cballoon](#cballoon)
    #'    - [center](#center)
    #'    - [cget](#cget)
    #'    - [configure](#configure)
    #'    - [console](#console)
    #'    - [exit](#exit)
    #'    - [getFrame](#getFrame)
    #'    - [getMenu](#getMenu)    
    #'    - [splash](#splash)
    #'    - [timer](#timer)
    #' 
    variable var
    variable gui
    variable x
    variable top
    variable console 
    variable timer
    variable options
    constructor {args} { 
        array set options [list -style clam {*}$args]
        set timer [::paul::Timer new]
        set path .
        set top $path ;# $path
        my Init
        my Gui
    }
    # main private methods
    method Init {} {
        set var(appname) BaseGuiApp
        set var(author) "Detlef Groth"
        set var(revision) [package version paul]
        set var(year) 2023
        if {[info exists ::starkit::topdir]} {
            set var(helpfile) [file join $::starkit::topdir lib app-$var(appname) html-$var(appname) index.html]
            set var(iconfile) [file join $::starkit::topdir lib app-$var(appname) $var(appname).ico]
        } else {
            set var(helpfile) [file join [file dirname [info script]] html-$var(appname) index.html]
            set var(iconfile) [file join [file dirname [info script]] $var(appname).ico]
        }
    }
    method Gui {} {
        wm protocol $top WM_DELETE_WINDOW [callback  exit]
        wm title $top "$var(appname), $var(revision), by @ $var(author), $var(year)"
        if {$top eq "."} {
            set t ""
        } else {
            set t $top
        }
        
        
        menu $t.mbar
        $top configure -menu $t.mbar
        menu $t.mbar.fl -tearoff 0
        menu $t.mbar.hlp -tearoff 0
        $t.mbar add cascade -menu $t.mbar.fl -label File  -underline 0
        $t.mbar add cascade -menu $t.mbar.hlp -label Help  -underline 0

        $t.mbar.fl add separator
        $t.mbar.fl add command -label Exit -command [callback exit] -underline 1
        
        $t.mbar.hlp add command -label About -command [callback about] -underline 0
        set var(menu,file) $t.mbar.fl
        set var(menu,help) $t.mbar.hlp
        set gui(frame) [ttk::frame $t.frame]
        pack $gui(frame) -side top -fill both -expand yes
        set gui(sep) [ttk::separator $t.sep -orient horizontal]
        set gui(statusbar) [::paul::statusbar $t.stb]
    }
    # public methods
    #' <a name="about"> </a>
    #' *cmdName*  **about** 
    #' 
    #' > Shows an about box with information about application.
    #' 
    method about {} {
        tk_messageBox -title "Info!" -icon info -message \
              "$var(appname)\n@$var(author)\n$var(year)" -type ok
    }
    #' 
    #' <a name="addStatusBar"> </a>
    #' *cmdName* **addStatusBar** 
    #' 
    #' > Packs and displays the statusbar widget at the bottom of the application. 
    #' If not called the statusbar will be invisible.

    method addStatusBar {} {
        pack $gui(sep) -side top -expand false -fill x
        pack $gui(statusbar) -side top -expand false -fill x
    }
    #'
    #' <a name="autoscroll"></a>
    #' *cmdName* **autoscroll**  *pathname*
    #' 
    #' > For the widget belonging to *pathname* add horizontal and vertical scrollbars, shown only when needed.
    #'   Please note, that the widget in *pathname* must be the only child of a `tk::frame` or a `ttk::frame` widget created already.
    #'    The widget *pathname* is then managed by grid, don't pack or grid the widget in *pathname* yourself. Handle it's geometry
    #'   via its parent frame. See the following example:
    #'
    #' ```{.tcl}
    #' package require paul
    #' set app [::paul::basegui new -style clam]
    #' set f [$app getFrame]
    #' set tf [ttk::frame $f.tframe]
    #' set t [text $tf.text -wrap none]
    #' $app autoscroll $t
    #' for {set i 0} {$i < 30} {incr i} {
    #'     $t insert end "Lorem ipsum dolor sit amet, ....\n\n"
    #' }
    #' pack $tf -side top -fill both -expand yes
    #' destroy .app
    #' ```
    #'
    method autoscroll {w} {
        set frame [winfo parent $w]
        grid $w -in $frame -row 0 -column 0 -sticky nsew
        grid rowconfigure $frame $w -weight 1
        grid columnconfigure $frame $w -weight 1
        ttk::scrollbar $frame.vsb -command "$w yview"       
        grid $frame.vsb -row 0 -column 1 -sticky ns
        ttk::scrollbar $frame.hsb -orient horizontal -command "$w xview"       
        grid $frame.hsb -row 1 -column 0 -sticky ew 
        $w configure -yscrollcommand [callback ScrollSet $frame.vsb] \
              -xscrollcommand [callback ScrollSet $frame.hsb]
        grid propagate $w true
    }
    # private method
    method ScrollSet {w lo hi} {
        if {$lo <= 0.0 && $hi >= 1.0} {
            grid remove $w
        } else {
            grid $w
        }
        $w set $lo $hi
    }
    #-- A simple balloon, modified from Bag of Tk algorithms:  
    #'
    #' <a name="balloon"></a>
    #' *cmdName* **balloon**  *pathname message ?display?* 
    #' 
    #' > For the widget belonging to *pathname* displays for around three seconds a small tooltip 
    #'   using the given *message*. The boolean variable *display* can be used to unregister the tooltip 
    #'   at a later point. See as well [cballoon](#cballoon) for tooltip on canvas tags.
    
    method balloon {w msg {display false}} {
        if {$display} {
            set top .balloon
            catch {destroy $top}
            toplevel $top -bd 1
            wm overrideredirect $top 1
            wm geometry $top +[expr {[winfo pointerx $w]+5}]+[expr {[winfo pointery $w]+5}]
            pack [message $top.txt -aspect 10000 -bg lightyellow \
                  -borderwidth 0 -text $msg -font {Helvetica 9}]
            bind  $top <1> [list destroy $top]
            raise $top
            after 3000 destroy $top
        } else {
            bind $w <Enter> [callback balloon $w $msg true]
            bind $w <Leave> { catch destroy .balloon }
        }
    }
    
    #-- A simple balloon for canvas items, https://wiki.tcl-lang.org/image/WikiDbImage+cballoon
    #-- https://wiki.tcl-lang.org/page/Canvas+balloon+help?R=0
    #'
    #' <a name="cballoon"></a>
    #' *cmdName* **cballoon**  *pathname tag message*
    #' 
    #' > For the widget belonging to *pathname* display for the canvas items labeled with *tag* the 
    #'   given message. See as well [balloon](#balloon) for standard tooltips for widgets.

    method cballoon {w tag text} {
        $w bind $tag <Enter> [callback CballoonMake $w $text]
        $w bind all  <Leave> [list after 1 $w delete cballoon]
    }
    # private method
    method CballoonMake {w text} {
        foreach {- - x y} [$w bbox current] break
        if [info exists y] {
            set id [$w create text $x $y -text $text -tag cballoon]
            foreach {x0 y0 x1 y1} [$w bbox $id] break
            $w create rect $x0 $y0 $x1 $y1 -fill lightyellow -tag cballoon
            $w raise $id
            after 3000 [list $w delete cballoon]
        }
    }
    #'
    #' <a name="center"></a>
    #' *cmdName* **center** *window*
    #' 
    #' > Centers a toplevel window on the screen.
    
    method center {w} {
        wm withdraw $w
        set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
               - [winfo vrootx [winfo parent $w]]]
        set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
               - [winfo vrooty [winfo parent $w]]]
        wm geom $w +$x+$y
        wm deiconify $w
    }
    
    #'
    #' <a name="cget"></a>
    #' *cmdName* **cget** *option*
    #' 
    #' > Returns the current value of the configuration option given by option. Option may have any of the values accepted by the paul::basegui command. 
    
    method cget {option} {
        return $options($option)
    }
    #' 
    #' <a name="configure"></a>
    #' *cmdName* **configure** *?option? ?value option value ...?*
    #' 
    #' > Query or modify the configuration options of the class. 
    method configure {args} {
        if {[llength $args] = 0} {
            return [array get options]
        } else if {[llength $args] == 1} {
            set key $args
            if {[info exists options($key)]} {
                return $options($key)
            }
        } else {
            array set opts $args
            foreach key [array names opts] {
                if {$key eq "-style"} {
                    if {$opts($key) ne ""} {
                        ttk::style theme use $value
                    }
                }
            }
        }
    }
    #-------    
    #-- A simple console, modified from https://wiki.tcl-lang.org/page/A+minimal+console
    #'
    #' <a name="console"></a>
    #' *cmdName* **console** *?pathname?*
    #' 
    #' > Displays a simple console in a toplevel if the target *pathname* is not given, or within the application if the given *pathname*
    #'  is a valid widget path within an existing toplevel. This console can be used to debug applications and
    #'   to inspect variables, commands etc. Based on wiki code in [A minimal console](https://wiki.tcl-lang.org/page/A+minimal+console). The *puts* commands entered within the *console* widget are displayed within the widget.
    
    method console {{target ".console"}} {
        if {$target eq ".console"} {
            catch {
                destroy $target
            }
            toplevel .console
        } 
        frame $target.fr
        text $target.fr.cmd -wrap word
        set console $target.fr.cmd
        $self autoscroll $console
        bind $console <Return> [callback EvalConsoleCmd]
        bind $console <Return> +break
        $console tag configure success -foreground \#008800
        $console tag configure failure -foreground red
        $console tag configure terminal -foreground blue
        $console insert end "% " terminal 
        pack $target.fr -side top -fill both -expand true
        
    }
    # private method
    method EvalConsoleCmd {} {
        set c $console
        if {[$c compare {insert + 1 lines} < end]} then {
            set l [$c get {insert linestart} {insert lineend}]
            $c insert {end - 1 chars} \n[string trimright $l]
            $c mark set insert end
            $c see insert
        } else {
            set code [$c get end-1lines+2chars end-1chars]
            # direct puts to terminal
            set start [string range $code 0 4]
            if {$start eq "puts "} {
                set code "set temphjkil [string range $code 5 end]"
                if {[catch {
                     set result [uplevel #0 "$code"]
                } err]} then {
                     $c insert end \n {"} $err failure \n
                } else {
                    $c insert end \n {} $result success \n
                }
            } else {
                if {[catch {
                     set result [uplevel #0 [$c get end-1lines+2chars end-1chars]]
                } err]} then {
                     $c insert end \n {"} $err failure \n
                } else {
                    $c insert end \n {} $result success \n
                }
            }
            $c insert end "% " terminal 
        }
    }
    #' 
    #' <a name="exit"> </a>
    #' *cmdName* **exit** *?ask?*
    #' 
    #' > Exit the application, if ask is true (default), displays a conformation message.
    #' 
    method exit {{ask true}} {
        if {$ask} {
            set answer [tk_messageBox -title "Question!" -message "Really quit application ?" -type yesno -icon question]
            if { $answer } {
                exit 0
            } 
        }

    }
    #'
    #' *cmdName* **getFrame**  
    #' 
    #' > Returns the mainframe of the application.
    #'   This function allows adding more widgets to the interior of the application in inheriting applications or at a later point.

    method getFrame {} {
        return $gui(frame)
    }
    #'
    #' *cmdName* **getMenu** *menuName ?option value ...?*  
    #' 
    #' > Returns the menu entry belonging to the given *menuName* or creates a new cascade with this *menuName* 
    #'   in the application menubar. 
    #'   This function allows adding more menu points in inheriting applications or at a later point to the application.
    #'   At creation time or therafter additional configuration options can be given such as *-underline 0* for instance. Here an example for inserting new menu points  
    #'
    #' 
    #' ```{.tcl}
    #' set app [::paul::basegui new -style clam]
    #' set fmenu [$app getMenu "File"]
    #' $fmenu insert 0 command -label Open -underline 0 -command { puts Opening }
    #' ```
    #'  

    method getMenu {name args} {
        set wpath [string tolower [regsub -all { } $name ""]]
        if {$top eq "."} {
            set t ""
        } else {
            set t $top
        }
        if {[info exists var(menu,$wpath)]} {
            if {[llength $args] > 0} {
                if {$wpath eq "file"} {
                    set idx 1
                } elseif {$wpath eq "help"} {
                    set idx end
                } else {
                    set idx $var(menuidx,$wpath)
                }
                $t.mbar entryconfigure $idx {*}$args
            }
            return $var(menu,$wpath)
        } else {
            set idx [$t.mbar index end]
            menu $t.mbar.$wpath -tearoff 0
            $t.mbar insert $idx cascade -menu  $t.mbar.$wpath -label $name
            set var(menu,$wpath) $t.mbar.$wpath
            set var(menuidx,$wpath) $idx
            if {[llength $args] > 0} {
                $t.mbar entryconfigure $idx {*}$args
            }
            return $var(menu,$wpath)
        }
    }
    
    #'
    #' *cmdName* **message**  *msg*
    #' 
    #' > Displays the text of *msg* in the statusbar. 
    #'    Only useful if statusbar is displayed using the *addStatusBar* command.
    
    method message {msg} {
        $gui(statusbar) set $msg
    }
    #'
    #' *cmdName* **progress**  *value* 
    #' 
    #' > Displays the given *value* within the progressbar in the statusbar widget. 
    #'    Only useful if statusbar is displayed using the *addStatusBar* command.
    method progress {value} {
        $gui(statusbar) progress $value
    }
    #' **setAppname** *appname revision author year*
    #' 
    #' > Sets meta information about the application, useful to change the about message.
    #' 
    method setAppname {appname revision author year} {
        set var(appname) $appname
        set var(revision) $revision
        set var(author) $author
        set var(year) $year
        wm title $top "$var(appname), $var(revision), by @ $var(author), $var(year)"
    }
    #'
    #' <a name="splash"></a>
    #' *cmdName* **splash**  *imgfile ?-delay milliseconds -message textmessage?* 
    #' 
    #' > Hides the main application and shows the given image in *imgfile* as well as some 
    #'   textmessage given with the option -message. The splash screen destroys itself after the given delay, default 2500. 
    #'   If delay is given as zero (0), the splash widget is not destroyed. If the *imgfile* variable is given as `update` 
    #'   then additional messages can be given to the splash widget. To destroy the splash method should be called with the
    #'   imgfile argument `destroy`. See below for an example. 
    #'   The pathname of the splash toplevel is `.splash`.
    #'
    #' > Example with a simple single message splash:
    #' 
    #' ```
    #' $app splash splash.png -delay 2000 -message "Loading editor application ..."
    #' ```
    #' 
    #' > Example with multiple messages:
    #' 
    #' ```
    #' $app splash splash.png -delay 0 -message "Loading editor application ..."
    #' after 2000 { app splash update -message "Loading data for editor application ..." }
    #' after 4000 { app splash destroy }
    #' ```
    method splash {imgfile args} {
        array set arg [list -delay 0 -message "Loading application ..."]
        array set arg $args
        if {$imgfile eq "destroy"} {
            destroy .splash
             wm deiconify .
        } elseif {$imgfile ne "update"} {
            if {[catch {image create photo splash -file $imgfile}]} {
                error "image $imgfile not found"
            }
            wm withdraw .
            toplevel .splash
            wm overrideredirect .splash 1
            canvas .splash.c -highlightt 0 -border 0
            
            .splash.c create image 0 0 -anchor nw -image splash
            foreach {- - width height} [.splash.c bbox all] break
            .splash.c config -width $width -height $height
            pack .splash.c
            pack [ttk::label .splash.label -text $arg(-message) -font 16] -padx 20 -pady 10 -side top
            pack [ttk::progressbar .splash.pb -mode indeterminate]  -padx 10 -pady 20 -side top
            set wscreen [winfo screenwidth .splash]
            set hscreen [winfo screenheight .splash]
            set x [expr {($wscreen - $width) / 2}]
            set y [expr {($hscreen - $height) / 2}]
            
            wm geometry .splash +$x+$y
            raise .splash
            .splash.pb start
            update idletasks
        } else {
            puts update
            .splash.label configure -text $arg(-message)
            update
        }
        if {$arg(-delay) > 0} {
            update
            after $arg(-delay) {destroy .splash; wm deiconify .}
        }
    }    
    #'
    #' <a name="status"></a>
    #' *cmdName* **status**  *msg ?value?* 
    #' 
    #' > Displays the text of *msg* as message and the optional value within the progressbar in the statusbar widget. 
    #'    Only useful if statusbar is displayed using the *addStatusBar* command.
    
    method status {msg {value 0}} {
        $gui(statusbar) set $msg $value
    }
    #'
    #' <a name="timer"></a>
    #' *cmdName* **timer**  *mode*
    #' 
    #' > Simple timer procedure to measure execution time in the GUI. 
    #' The two modes are *reset* and *time*, the first measured time is initialized at *paul::basegui* initialization:
    #'
    #' > - *reset* - resets the time to the current time
    #'   - *time*  - gets the execution time after the last reset, this is the default.
    #'
    #' ```{.tcl eval=false}
    #'   set app [paul::basegui new]
    #'   puts "Startup in [$app timer time] seconds!"
    #'   $app timer reset
    #'   after 1500
    #'   puts "After time [$app timer time] seconds!"
    #' ```
    #' 
    method timer {{mode time}} {
        if {$mode eq "time"} {
            return [$timer seconds]
        } elseif {$mode eq "reset"} {
            $timer reset
        }
    }
}
#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' The following example demonstrates a few features for creating new standalone applications using the faciltities of 
#' of the *paul::basegui* snit type. The code can be executed directly using the *--demo* commandline switch.
#' 
#' ```{.tcl eval=true}
#' set app [::paul::basegui new]
#' puts "Startup in [$app timer time] seconds!"
#' $app timer reset
#' set fmenu [$app getMenu "File"]
#' $fmenu insert 0 command -label Open -underline 0 -command { puts Opening }
#' $app addStatusBar
#' $app progress 10
#' $app message "starting ..."
#' after 1000
#' $app status progressing... 50
#' after 1000
#' $app status finished 100
#' set f [$app getFrame]
#' set btn [ttk::button $f.btn -text "Hover me!"]
#' $app balloon $btn "This is the hover message!\nNice ?"
#' pack $btn -side top
#' set tf [ttk::frame $f.tframe]
#' set t [text $tf.text -wrap none]
#' $app autoscroll $t
#' for {set i 0} {$i < 30} {incr i} {
#'     $t insert end "Lorem ipsum dolor sit amet, consectetur adipiscing elit, 
#'   sed do eiusmod tempor 
#'      incididunt ut labore et dolore magna aliqua. 
#'    Ut enim ad minim veniam, quis nostrud exercitation 
#'      ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\n"
#' }
#' pack $tf -side top -fill both -expand yes
#' pack [canvas $f.c] -side top -fill both -expand true
#' set id [$f.c create oval 10 10 110 110 -fill red]
#' $app cballoon $f.c $id "This is a red oval"
#' $f.c create rect 130 30 190 90 -fill blue -tag rect
#' $app cballoon $f.c rect "This is\na blue square"
#' puts "After time [$app timer time] seconds!"
#' ```
#'
#' ## <a name='inheritance'>INHERITANCE</a>
#' 
#' This widget can be used to build up other more specialized applications. Here is an example, 
#' where we create a generic Editor class which adds additional menu points and embeds 
#' a scrolled text widget.
#'
#' The most basic inheritance example would be just copying the functionality without the text widget.
#'
#' ```
#' package require paul
#' namespace eval ::test { }
#' oo::class create ::test::EditorApp {
#'    superclass paul::basegui
#'    variable textw
#'    constructor {args} {
#'         next {*}$args
#'         set frame [my getFrame]
#'         set textw [text $frame.t -wrap none]
#'         [self] autoscroll $textw
#'    }
#'    # added functionality
#'    # access functionality of the text widget
#'    # like: % app text insert end "hello basegui world"
#'    method text {args} {
#'       $textw {*}$args
#'    }
#' }
#' if {[info exists argv0] && $argv0 eq [info script]} {
#'    #start editor
#'    set app [::test::EditorApp new ]
#'    $app text insert end "Hello EditorApp!!"
#'    $app addStatusBar
#'    $app progress 50
#'    $app message "Editor was loaded!"
#' }
#' ``` 
#'
#' This simple example should show how to extend the functionality of the basegui toplevel.
#' Before you start to write specialized applications you should create a simple proxy class which 
#' does nothing more than inheriting from `paul::basegui` first. This is the code above without the text widget parts. 
#' You can then extend this base class and your specialized applications inherit from your baseclass. 
#' This allows you to extend all your specialized classes using your baseclass. So your setup should be:
#'
#' ```
#'
#'                                  -- your::editor
#' paul::basegui -- your::basegui ---+
#'                                  -- your::databasebrowser
#'
#'
#' ```
#' 
#' This is in the long term better than inheriting from `paul::basegui` directly. You don't like to change the code of 
#' this class, but you can change `your::basegui` for instance to give better help facilities in the Help menu, or other features you need in your applications most of the time.
#' If you do this both application `your::editor` and `your::databasebrowser` will have this functionality at the same time 
#' after implementing it in `your::basegui` type. If you follow this approach you can easily update the *paul::basegui* package without loosing your new functionalities.
#' 
#' ## TODO's
#' 
#' * socket check for starting the application twice
#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **paul::basegui** command was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2019-2023  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
#' ## <a name='license'>LICENSE</a>
#' 
#' ```{.tcl eval=true echo=false id="licence"}
#' include LICENSE
#' ```
#' 

if {[info exists argv0] && $argv0 eq [info script] && [regexp basegui $argv0]} {
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
        puts "     The paul::basegui class for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019-2024  Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::basegui class provides a basic application framework for"
        puts "                       building Tk applications."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --license : printing the license to the terminal"
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "\n\n      Hint: You can read the documentation like this:\n"
        puts "         tclsh paul/basegui.tcl  --man | pandoc -f Markdown -t plain | less"
        puts "         tclsh paul/basegui.tcl  --man | pandoc -f Markdown -t html | w3m -T text/html -"
        
        puts ""
    }
}


