#!/usr/bin/env tclsh
##############################################################################
#
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : MicroEmacs User
#  Created       : 2025-02-22 13:58:37
#  Last Modified : <250225.1459>
#
#  Description	 :
#
#  Notes         :
#
#  History       :
#	
##############################################################################
#
#  Copyright (c) 2025 MicroEmacs User.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from MicroEmacs User.
#
##############################################################################

package require oowidgets
package require tkoo
package require paul
package require msgcat
namespace eval ::paul { }
oowidgets::widget ::paul::Htext {
    variable history
    variable seen
    variable doc
    variable win
    variable indexLabel
    variable searchLabel
    variable backLabel
    variable historyLabel
    variable search
    variable app
    variable first
    constructor {path args} {
        # Create the text widget; turn off its insert cursor
        set app [paul::basegui new -toplevel false]
        ttk::style layout SearchEntry [ttk::style layout TEntry]
        ttk::style configure SearchEntry [ttk::style configure TEntry]
        ttk::style configure SearchEntry -borderwidth 6
        ttk::style configure SearchEntry -padding {6 6 6 6} 
        ttk::style configure SearchEntry -background salmon
        my install ttk::frame $path
        ttk::frame $path.bb
        ttk::button $path.bb.home -image ::paul::navhome16 -command [mymethod Home] -width 10
        ttk::button $path.bb.indx -image ::paul::textblock16 -command [mymethod Show Index] -width 10
        ttk::button $path.bb.back -image ::paul::nav1leftarrow16 -command [mymethod Back] -width 10
        ttk::button $path.bb.forward -image ::paul::nav1rightarrow16 -command [list puts Hi] -width 10
        ttk::separator  $path.bb.sep
        ttk::entry $path.bb.entry -textvar [myvar search] -style SearchEntry -width 30
        ttk::button $path.bb.button -command [mymethod Dosearch] -text " Search "
        ttk::frame $path.txt
        pack $path.bb -side top -fill x -expand false
        pack $path.bb.home -side left -padx 5 -pady 10
        pack $path.bb.indx -side left -padx 5 -pady 10        
        pack $path.bb.back -side left -padx 5 -pady 10
        pack $path.bb.forward -side left -padx 10 -pady 10
        pack $path.bb.sep -side left -padx 10 -pady 10        
        pack $path.bb.entry -side left -padx 10 -pady 10
        pack $path.bb.button -side left -padx 10 -pady 10
        set win [tk::text $path.txt.ro -border 5 -relief flat -wrap word -spacing1 5]
        $app autoscroll $win
        pack $path.txt -fill both -expand true
        $win configure -background salmon
        # we need the real widget - underline at the end
        #set win [my widget]
        set seen {}
        set history {}
        set historyLabel [msgcat::mc "History"]
        set searchLabel [msgcat::mc "Search"]
        set indexLabel [msgcat::mc "Index"]
        set backLabel [msgcat::mc "Back"]
        set search hello
        array set doc [list]
        $win tag config link -foreground blue -underline 1
        $win tag config seen -foreground purple4 -underline 1
        $win tag bind link <1> [mymethod Click $win %x %y]
        $win tag bind link <Enter> "$win configure -cursor hand2"
        $win tag bind link <Leave> "$win configure -cursor {}"
        $win tag config hdr -font {Tahoma 16 bold}
        $win tag config hdr2 -font {Tahoma 14 bold}        
        $win tag config fix -font {Courier 12}
        $win tag config italic -font {Times 12 italic}
        $win tag config bold   -font {Times 12 bold}
        $win tag config plain  -font {Times 12}
        $win tag config dtx    -lmargin1 20 -lmargin2 20
        $win tag config bullet -font {Courier 8 bold} -offset 3 -lmargin1 10
        my configure {*}$args
    }
    method file_read {filename} {
        if [catch {open $filename r} infh] {
            puts stderr "Cannot open $filename: $infh"
            exit
        } else {
            set title Main
            set first ""
            while {[gets $infh line] >= 0} {
                if {[regexp {^## (.+)} $line -> title]} {
                    if {$first eq ""} {
                        set first $title
                    }
                    set doc($title) "\n"
                } else {
                    append doc($title) "$line\n"
                }
            }
            close $infh
            puts [array names doc]
        }
        if {[info exists doc(Main)]} {
            my Show Main
        } elseif {$first ne ""} {
            my Show $first
        }
    }
    method Click {w x y} {
        set range [$w tag prevrange link [$w index @$x,$y]]
        set link [eval $w get $range]
        my Show $link
    }
    
    method Show {title} {
        set w $win
        $w config -state normal
        $w delete 1.0 end
        $w insert end $title hdr \n
        switch -- $title {
            Back    {my Back; return}
            History {my Listpage $history}
            Index   {my Listpage [lsort -dic [array names doc]]}
            Search  {my Search}
            default {
                if {![info exists doc($title)]} {
                    $w insert end [msgcat::mc "This page was referenced but not written yet."]
                } else {
                    set var 0
                    set dtx {}
                    foreach i [split $doc($title) \n] {
                        if { ![string compare $dtx {}] } {
                            if [regexp {^[ \t]+} $i] {
                                $w insert end $i\n fix
                                set var 0
                                continue
                            }
                        }
                        set i [string trim $i]
                        if {[regexp {^### (.+)} $i -> header]} {
                            $w insert end $header hdr2
                            continue
                        }
                        if { ![string length $i] } {
                            $w insert end "\n" plain
                            if { $var } { $w insert end "\n" plain }
                            set dtx {}
                            continue
                        }
                        
                        if { [regexp {^[*] (.*)} $i -> i] } {
                            if { !$var || [string compare $dtx {}] } { $w insert end \n   plain }
                            $w insert end "o " bullet
                            set dtx dtx
                        }
                        
                        set var 1
                        regsub {]} $i {[} i
                        while {[regexp {([^[~*]*)([*~[])([^~[*]+)(\2)(.*)} $i \
                            -> before type marked junked after]} {
                            $w insert end $before "plain $dtx"
                            switch $type {
                                {~} { $w insert end $marked "italic $dtx" }
                                {*} { $w insert end $marked "bold   $dtx" }
                                {[} { my Showlink $marked "plain  $dtx" }
                                  }
                                  set i $after
                              }
                              $w insert end "$i " "plain $dtx"
                          }
                      }
                      #$w insert end \n------\n {} $indexLabel link " - " {} $searchLabel link
                      #if [llength $history] {
                      #    $w insert end " - " {} $historyLabel link " - " {} $backLabel link
                      #}
                  }
              }
          $w insert end \n
          lappend history $title
          
          $w config -state disabled
    }
    method Back { } {
        set w $win
        set l [llength $history]
        set last [lindex $history [expr $l-2]]
        set history [lrange $history 0 [expr $l-3]]
        puts $history
        my Show $last
    }
    method Listpage {list} {
        set w $win
        foreach i $list {$w insert end \n; my Showlink $i}
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
        $w insert end "\n\n" {} [msgcat::mc "Search results for '%s':" $search] {} \n {}
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
        if {[string equal $link History]} {
            set link $historyLabel
        }  elseif {[string equal $link Search]} {
            set link $searchLabel
        }  elseif {[string equal $link Index]} {
            set link $indexLabel
        }  elseif {[string equal $link Back]} {
            set link $backLabel
        }
        $w insert end $link $tag
    }
    method Home { } {
        if {[info exists doc(Main)]} {
            my Show Main
        } elseif {$first ne ""} {
            my Show $first
        }
    }
}

paul::htext .ht
.ht file_read [file rootname [info script]].txt
pack .ht -side top -fill both -expand true
