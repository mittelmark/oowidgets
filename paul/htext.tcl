#!/usr/bin/env tclsh
#' ---
#' title: paul::htext documentation
#' author: Detlef Groth, University of Potsdam, Germany
#' Date : <250306.1126>
#' tcl:
#'   eval: 1
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
#' lappend auto_path .
#' include paul/header.html
#' ```
#' 
#' ## NAME
#'
#' **paul::htext** - hypertext widget for browsing Markdown like documentation.
#' This is adaption of the [htext](https://wiki.tcl-lang.org/page/htext) widget 
#' programmed initially by [Richard Suchenwirth](https://wiki.tcl-lang.org/page/suchenwi).
#'
#' ## <a name='toc'></a>Table of Contents
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'  - [FILE FORMAT](#format)
#'  - [EXAMPLE](#example)
#'  - [SEE ALSO](#see)
#'  - [AUTHOR](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'></a>SYNOPSIS
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path [file join [file dirname [info script]] ..]
#' ```
#' 
#' ```
#' package require paul
#' paul::htext pathName -option value ?-option value?
#' pathName file_read FILENAME
#' ```
#'
#' ## <a name='description'></a>DESCRIPTION
#' 
#' **paul::htext** - is a composite widget consisting of a toolbar with button for
#' naviagation and a text widget with hypertext facilities.
#' The widget can be used to add help facilitites to your application. It supports the following
#' features:
#' 
#' __Formatting:__
#'
#' You can use an essential subset of Markdown syntax:
#'
#' - hyperlinks within the same document supporting link to header sections
#' - headers formatting
#' - item lists
#' - sub item lists
#' - verbatim text with 4 space indentation
#' - formatting bold, italics and textwriter within the text
#' - image embedding
#'
#' __Interface:__
#'
#' - full text searching
#' - history navigation
#' - document reloading
#' - browser like button bar
#'
#' ## <a name='command'></a>COMMAND
#'
#' **paul::htext** *pathName ?options?*
#' 
#' > Creates and configures a new paul::htextwidget  using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'></a>WIDGET OPTIONS
#' 
#' The **paul::htext** widget is a composite widget useful for embedding navigating help documents
#' of Tk applications.
#' It supports the followingt options the following options:
#'
#' - __-filename__ _STRING_ - the filename from which the documentation should be loaded.
#' - __-toolbar__ _BOOL_ - should a browser like toolbar been show on top of the widget
#'
package require oowidgets
package require tkoo
package require paul
package require msgcat
namespace eval ::paul { }
oowidgets::widget ::paul::Htext {
    variable seen
    variable doc
    variable win
    variable search
    variable app
    variable phi
    variable first
    variable filename
    variable btnforward
    variable btnback
    variable sections
    variable sectionheader
    variable 
    constructor {path args} {
        # Create the text widget; turn off its insert cursor
        set app [paul::basegui new -toplevel false]
        set phi [paul::history new]
        ttk::style layout SearchEntry [ttk::style layout TEntry]
        ttk::style configure SearchEntry [ttk::style configure TEntry]
        ttk::style configure SearchEntry -borderwidth 6
        ttk::style configure SearchEntry -padding {6 6 6 6} 
        #ttk::style configure SearchEntry -background salmon
        my option -filename ""
        my option -toolbar true
        my install ttk::frame $path
        ttk::frame $path.bb
        ttk::button $path.bb.home -image ::paul::navhome16 -command [mymethod Home] -width 10
        ttk::button $path.bb.reload -image ::paul::actreload16 -command [mymethod Reload] -width 10        
        ttk::button $path.bb.indx -image ::paul::textblock16 -command [mymethod show Index] -width 10
        ttk::button $path.bb.back -image ::paul::nav1leftarrow16 -command [mymethod Back] -width 10
        ttk::button $path.bb.forward -image ::paul::nav1rightarrow16 -command [mymethod Forward] -width 10
        set btnback $path.bb.back
        set btnforward $path.bb.forward
        ttk::separator  $path.bb.sep
        ttk::entry $path.bb.entry -textvar [myvar search] -style SearchEntry -width 30
        ttk::button $path.bb.button -command [mymethod Dosearch] -text " Search "
        ttk::frame $path.txt
        #pack $path.bb -side top -fill x -expand false
        pack $path.bb.home -side left -padx 5 -pady 10
        pack $path.bb.reload -side left -padx 5 -pady 10        
        pack $path.bb.indx -side left -padx 5 -pady 10        
        pack $path.bb.back -side left -padx 5 -pady 10
        pack $path.bb.forward -side left -padx 10 -pady 10
        pack $path.bb.sep -side left -padx 10 -pady 10        
        pack $path.bb.entry -side left -padx 10 -pady 10
        pack $path.bb.button -side left -padx 10 -pady 10
        set win [tk::text $path.txt.ro -border 5 -relief flat -wrap word -spacing1 5]
        $app autoscroll $win
        pack $path.txt -fill both -expand true -side top
        #$win configure -background salmon
        # we need the real widget - underline at the end
        #set win [my widget]
        set seen {}
        set search hello
        array set doc [list]
        array set sectionheader [list]
        $win tag config link -foreground blue -underline 0
        $win tag config seen -foreground purple4 -underline 0
        $win tag config error -foreground red
        $win tag bind link <1> [mymethod Click $win %x %y]
        $win tag bind link <Enter> "$win configure -cursor hand2"
        $win tag bind link <Leave> "$win configure -cursor {}"
        $win tag config hdr -font {"DejaVu Sans" 18 bold} -underline 1
        $win tag config hdr2 -font {"DejaVu Sans" 16 bold} -underline 1       
        $win tag config fix -font {"DejaVu Sans Mono" 12}
        $win tag config italic -font {"DejaVu Sans" 14 italic}
        $win tag config bold   -font {"DejaVu Sans" 14 bold}
        $win tag config plain  -font {"DejaVu Sans" 14}
        #$win tag config dtx    -lmargin1 0 -lmargin2 0
        ##$win tag config dtx2    -lmargin1 0 -lmargin2 0        
        $win tag config bullet -font {"DejaVu Sans Mono" 10 bold} -offset 3 -lmargin1 10
        $win tag config bullet2 -font {"DejaVu Sans Mono" 10 bold} -offset 6 -lmargin1 20
        my configure {*}$args
        if {[my cget -toolbar]} {
            pack $path.bb -side top -fill x -expand false -before $path.txt
        }
        set sections [list]
        if {[my cget -filename] ne ""} {
            my file_read [my cget -filename]
        }
        bind $win <Key-space> [list tk::TextScrollPages $win +1 ]
        bind $win <Key-BackSpace> [list tk::TextScrollPages $win -1 ]
        bind $win <Key-Next> [list tk::TextScrollPages $win +1 ]
        bind $win <Key-Prior> [list tk::TextScrollPages $win -1 ]
        bind $win <Control-h> [mymethod Back]
        bind $win <Control-l> [mymethod Forward]
    }
    #' 
    #' ## <a name='commands'></a>WIDGET COMMANDS
    #' 
    #' Each **paul::htext** widget supports the following methods.
    #' 
    #' *pathName* **file_read** *filename*
    #' 
    #' > Open the given filename and display the first section into the text widget.
    #'
    method file_read {filename} {
        if [catch {open $filename r} infh] {
            error "Cannot open $filename: $infh"
        } else {
            set title Main
            set first ""
            set sections [list]
            while {[gets $infh line] >= 0} {
                if {[regexp {^\s*<a name} $line]} {
                    continue
                }
                if {[regexp {^##? (.+)} $line -> title]} {
                    set title [string trim $title]
                    set otitle $title
                    set title [regsub { -.+} $title ""]
                    set sectionheader($title) $otitle
                    if {$first eq ""} {
                        set first $title
                    }
                    set doc($title) "\n"
                    lappend sections $title
                } else {
                    append doc($title) "$line\n"
                }
            }
            close $infh
        }
        if {[info exists doc(Main)]} {
            my show Main
        } elseif {$first ne ""} {
            my show $first
        }
        my configure -filename $filename
    }
    method Click {w x y} {
        set range [$w tag prevrange link [$w index @$x,$y]]
        if {$range ne ""} {
            set link [eval $w get $range]
            if {$link ne ""} {
                my show $link
            }
        }
    }
    #' *pathName* **sections** 
    #' 
    #' > Returns all sections in the order they appear in the file.
    #'   This list can be used to create a browse table of contents for 
    #'   instance in a tk::listbox widget.
    #'
    method sections { } {
        return $sections
    }
    
    #' *pathName* **show** *section*
    #' 
    #' > Display the given section in the help widget.
    #'
    method show {title} {
        set w $win
        $w config -state normal
        $w delete 1.0 end
        if {[info exists sectionheader($title)]} {
            $w insert end $sectionheader($title) hdr \n
        } else {
            $w insert end $title hdr \n
        }
        switch -- $title {
            Back    {my Back; return}
            History {my Listpage $phi getHistory}
            Index   {my Listpage [lsort -dic [array names doc]]}
            Search  {my Search}
            default {
                if {![info exists doc($title)]} {
                    $w insert end [msgcat::mc "This page was referenced but not written yet."]
                } else {
                    my Md2Text $title
                }
            }
        }
        $w insert end \n
        $phi insert $title
        $w config -state disabled
        if {[$phi canBackward]} {
            $btnback configure -state active
        } else {
            $btnback configure -state disabled
        }
        if {[$phi canForward]} {
            $btnforward configure -state active
        } else {
            $btnforward configure -state disabled
        }
            
    }
    method Md2Text {title} {
        set w $win
        set list false
        set listlist false
        set pre false
        set plain true
        set dtx ""
        foreach i [split $doc($title) \n] {
            if {$pre && [regexp "^\\s*$" $i]} {
                set pre false
                $w insert end "\n"
                set plain true
            } elseif {$pre} {
                $w insert end $i\n fix
            } elseif {$plain} {
                if {[regexp {^[ \t]{4,}[^-*]} $i] || [regexp {^[ \t]*[+|]} $i]}  {
                    $w insert end \n$i\n fix
                    set pre true
                    set plain false
                    continue
                }
                if {[regexp {<a name.+>} $i]} {
                    continue
                }
                if {[regexp {^### (.+)} $i -> header]} {
                    $w insert end "\n$header\n" hdr2
                    continue
                }
                if {[regexp "^\\s*$" $i]} {
                    if {$list} {
                        $w insert end "\n" plain
                    }
                    set list false
                    set listlist false
                    set dtx ""
                    $w insert end "\n" plain
                }
                # remove Md links
                set i [regsub -all {\(#[A-Za-z0-9]+\)} $i ""]
                # image(s) - best leave them alone on a line
                while {[regexp {^(.*?)!\[\]\((.+?)\)(.*)$} $i -> before imgfile after]} {
                    set imgpath [file join [file dirname [my cget -filename]] $imgfile]
                    $w insert end "$before" plain
                    if {[file exists $imgpath]} {
                        set imgname [image create photo -file $imgpath]
                        set end0 [$w index end]
                        $w image create end -image $imgname
                        $w tag add centered $end0 end-1c
                    } else {
                        $w insert end "Error: File '$imgpath' does not exists!" "plain error"
                    }
                    set i $after 
                }
                ## formatting
                ## [links]
                regsub -all {]} $i {[} i
                ## __bold __ or *bold*
                regsub -all {__([^_]+?)__} $i {*\1*} i
                ## italic _italic_ or ~italic~
                regsub -all {_([^_]+?)_} $i {~\1~} i
                
                if {[regexp {^[-*] (.+)} $i -> i]} {
                    $w insert end "\no " bullet
                    set dtx dtx
                    set list true
                    
                } elseif {[regexp {^    [-*] (.*)} $i -> i]} {
                    set dtx dtx2
                    $w insert end "\n- " "bullet2 $dtx"
                    set listlist true
                }
                while {[regexp {([^[`~*]*)([`*~[])([^~[`*]+)(\2)(.*)} $i \
                   -> before type marked junked after]} {
                   $w insert end $before "plain $dtx"
                   switch $type {
                      {~} { $w insert end $marked "italic $dtx" }
                      {*} { $w insert end $marked "bold   $dtx" }
                      {`} { $w insert end $marked "fix   $dtx" }                                
                      {[} { my Showlink $marked "plain  $dtx" }
                   }
                   set i $after
                }
            $w insert end "$i " "plain $dtx"
            
        }
            
        }
    }
    method Back { } {
        set w $win
        set prev [$phi back]
        my show $prev
    }
    method Forward { } {
        set w $win
        set nxt [$phi forward]
        my show $nxt
    }
    method Listpage {list} {
        set w $win
        foreach i $list {$w insert end \n; my Showlink $i}
    }
    method Reload { } {
        set current [$phi current]
        array unset doc 
        my file_read [my cget -filename]
        if {[info exists doc($current)]} {
            my show $current
        }
        
    }
    method Search {} {
        set w $win
        $w insert end "\n" {} [msgcat::mc "Search phrase:"] {} "  " {}
        ttk::entry $w.e -textvar [myvar search]
        $w window create end -window $w.e
        focus $w.e
        $w.e select range 0 end
        bind $w.e <Return> [mymethod Dosearch]
        ttk::button $w.b -text [msgcat::mc " Search! "] -command [mymethod Dosearch]
        $w window create end -window $w.b
    }
    method Dosearch {} {
        set w $win
        $w config -state normal
        $w delete 1.0 end
        $w insert end "\n" {} [msgcat::mc "Search results for '%s':" $search] {} \n {}
        foreach i [lsort [array names doc]] {
            if [regexp -nocase $search $i] {
                $w insert end \n; my Showlink $i ;# found in title
            } elseif [regexp -nocase -indices -- $search $doc($i) pos] {
                regsub -all \n [string range $doc($i) \
                    [expr [lindex $pos 0]-20] [expr [lindex $pos 1]+20]] \
                        " " context
                $w insert end \n
                my Showlink $i
                $w insert end " - ...$context..."
            }
        }
        $w config -state disabled
    }
    method Showlink {link {tags {} }} {
        set w $win
        if {[regexp "^image\\://(.*)\$" $link "" imgname]} {
            set end0 [$w index end]
            $w insert end "\n"
            $w image create end -image $imgname
            $w insert end "\n"
            $w tag add centered $end0 end-1c
            return
        }
        set tag "link $tags"
        if {[lsearch -exact $seen $link]>-1} {
            lappend tag seen
        } else {lappend seen $link}
        $w insert end $link $tag
    }
    method Home { } {
        if {[info exists doc(Main)]} {
            my show Main
        } elseif {$first ne ""} {
            my show $first
        }
    }
}

#' 
#' ## <a name='format'></a>FILE FORMAT
#' 
#' The widget supports the following format options:
#'
#' - sections which are displayed on separate pages are starting with two hash marks `## TITLE`
#' - subsection within the same page are starting with three hash marks `### SUBSECTION`
#' - hyperlinks to other pages are embedded within brackets like this `[SECTIONNAME]`
#' - you can make your document as well Markdown compatible by using [SECTIONAME](#anchorname) syntax
#'   and placing HTML anchor tags within your document
#' - bold text is emphasized using stars or two underlines `*bold*`, `__bold__`
#' - italic text is emphasized usng the tilde `~italic~` or using a single underline `_italic_`
#' - typewriter text is emphasized using the backtick character ``typewriter``
#' - lists are started with stars or minus symbols at the first line
#' - sub lists are started with 4 spaces at the beginning of a line and thereafter
#'   as well a minus or star symbol followed by a space and the item text.
#' - paragraph breaks created by empty lines
#' - two empty lines place a empty line between two paragraphs
#' - images are declared like Markdown images, but without text within the bracket part
#' 
#' Here an example for a help file:
#'
#' ```
#' <a name="secone"> </a>
#' ## Section One
#' 
#' ### Subsection formatted text
#'
#' Some text written on *bold* and ~italics~. 
#'
#' ### Subsection list items
#'
#' Let's follow this by a list:
#'
#' * item 1
#'     - subitem 1.1
#'     - subitem 1.2
#' * item 2
#' * item 3
#' 
#' ### Paragraphs
#' 
#' Paragraphs are created by adding empty lines between your text.
#' 
#' This starts a new paragraph.
#'
#' ### Hyperlinks
#'
#' Hyperlinks are create by placing a section name into brackets like this
#' [Section Two]. To make this syntax compatible with standard Markdown links
#' you have to add an anchor section after the link name like this:
#'
#' [Section Two](#sectwo)
#' 
#' some text in between ...

#' <a name="sectwo"> </a>
#' ## Section Two
#' 
#' These Markdown syntax is only required if you would like to make your documentation
#' fully Markdown compatible. For instance using it as a README within your project.
#' 
#' Text which is indented with 4 whitespaces will be shown like it is except for sub item lists:
#'
#'     This text will be not formatted in any way
#'     and this line as well.
#' 
#'
#' ## Final Section 
#' 
#' This is the final section where we can link to [Section One].
#'
#' Let's add an image example:
#'
#' ![](path/to/image.png)
#'
#' Currently only PNG and GIF images are supported. The path must be relative to
#' the documentation file.
#' ```
#' 
#' ## <a name='example'></a>EXAMPLE
#' 
#' ```{.tcl eval=true}
#' lappend auto_path .
#' package require paul
#' paul::htext .ht
#' .ht file_read paul/htext.txt
#' pack .ht -side top -fill both -expand true
#' foreach section [.ht sections] {
#'    puts $section
#' }
#' update idletasks
#' ```
#' 
#' ## <a name='see'></a>SEE ALSO
#'
#' - [oowidgets](../oowidgets/oowidgets.html)
#'
#' ## <a name='authors'></a>AUTHOR
#'
#' The **paul::htext** widget was written by Detlef Groth, University of Potsdam, Germany. 
#' The initial code was based on code from the Tclers Wiki mainly started by [Richard Suchenwirth](https://wiki.tcl-lang.org/page/suchenwi).
#'
#' ## <a name='copyright'></a>COPYRIGHT
#'
#' Copyright (c) 2025  Detlef Groth, E-mail: dgroth(at)uni(minus)potsdam(dot)de
#' 
#' ## <a name='license'></a>LICENSE
#'
#' ```{.tcl eval=true id="license" echo=false}
#' include LICENSE
#' ```

if {[info exists argv0] && $argv0 eq [info script] && [regexp htext $argv0]} {
    lappend auto_path [file join [file dirname [info script]] ..]
    package require paul
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [package version paul]
        destroy .
    } elseif {[llength $argv] == 1 && [file exists [lindex $argv 0]]} {
        pack [paul::htext .phtext -filename [lindex $argv 0]] -side top -fill both -expand true
        pack [ttk::button .btn -text "Close" -command exit] -side bottom -fill x -padx 20 -pady 20
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
        puts "     The paul::htext widget for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2025  Detlef Groth, E-mail: dgroth(at)uni(minus)potsdam(dot)de\n"
        puts "License: BSD - License see manual page"
        puts "\nThe paul::htext widget provides a hypertext widget"
        puts "with an optional browser like toolbar."
        puts ""
        puts "Usage: [info nameofexe] [info script] [FILENAME] options\n"
        puts "    Arguments:"
        puts "        FILENAME  : documentation file with basic markdown\n"
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
