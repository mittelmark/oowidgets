package require Tk 8.6
package provide oowidgets 0.3.2

#' ---
#' title: package oowidgets - create megawidgets using TclOO
#' author: Detlef Groth, University of Potsdam, Germany
#' date: 2023-08-26
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
#'
#'     body { 
#'       margin: 0 auto;
#'       padding-left: 50px;
#'       padding-right: 50px;
#'       padding-top: 50px;
#'       padding-bottom: 50px;
#'       hyphens: auto;
#'       max-width: 1000px; 
#'     }
#'     pre { background: rgb(250,229,211); padding: 8px; }
#'     pre.sourceCode, pre.tcl { 
#'         background: #eeeeee; 
#'         padding: 8px;
#'         font-size: 95%;
#'     }
#'     #TOC li {
#'         list-style: square;
#'     }
#'     .code-title {
#'       background: #dddddd;
#'       padding: 8px;
#'     } 
#'     </style>
#'     ```
#' ---
#' 
#'
#' ## NAME 
#' 
#' `oowidgets` - package to create megawidgets using TclOO
#' 
#' ## SYNOPSIS
#' 
#' ```
#' package require oowidgets
#' oowidgets::widget CLASSNAME CODE
#' ```
#' 
#' ## METHODS
#' 
#' There is only one method currently:
#' 

# not required for Tcl 8.7 very likely
if {![package vsatisfies [package provide Tcl] 8.7]} {
    proc ::oo::Helpers::callback {method args} {
        list [uplevel 1 {namespace which my}] $method {*}$args
    
    }
    proc ::oo::Helpers::mymethod {method args} {
        list [uplevel 1 {namespace which my}] $method {*}$args
    
    }
    # That is not yet in in Tcl 8.7?
    proc ::oo::Helpers::myvar {varname} {
        return [uplevel 1 {namespace qualifiers [namespace which my]}]::$varname
    }
}


namespace eval ::oowidgets { }

# this is a tk-like wrapper around the class,
# so that object creation works like other Tk widgets
# is considered a private function for now

proc oowidgets::new name { 
    eval "
    proc [string tolower $name] {path args}  { 
      set obj \[$name create tmp \$path {*}\$args\]
        rename \$obj ::\$path
        return \$path
    }
    "
}
# the BaseWidget from which your MegaWidgest should inherit
oo::class create ::oowidgets::BaseWidget {
      variable parentOptions
      variable widgetOptions
      variable widget
      variable widgetpath
      variable widgettype
      constructor {path args} {
              my variable widgetOptions
              my variable parentOptions
              array set widgetOptions [list]
              array set parentOptions [list]
              #my configure {*}$args
      }

      # public methods starts with lower case declaration names,
      # whereas private methods starts with uppercase naming
      
      method install {wtype path args} {
          my variable parentOptions
          my variable widgetOptions
          my variable widget
          my variable widgetpath 
          set widgetpath $path
          $wtype $path
          set widget ${path}_
          foreach opts [$path configure] {
              set opt [lindex $opts 0]
              set val [lindex $opts end]
              set parentOptions($opt) $val
          }
          array set nopts $args
          foreach opt [array names nopts] {
              if {[info exists parentOptions($opt)]} {
                  set parentOptions($opt) $nopts($opt)
                  $path configure $opt $nopts($opt)
              } else {
                  set widgetOptions($opt) $nopts($opt)
              }
          }
          # set widget ${path}_
          rename $path $widget
      }
      method cget { {opt "" }  } {
              my variable widgetOptions
              my variable parentOptions
              if { [string length $opt] == 0 } {
                      return [lsort [list [array get parentOptions] {*}[array get widgetOptions]]]
              }
              if { [info exists widgetOptions($opt) ] } {
                      return $widgetOptions($opt)
              } elseif {[info exists parentOptions($opt)]} {
                      return $parentOptions($opt)
              } 
              return -code error "# unknown option"
      }
      method tkclass {} {
          return [winfo class [string range [self] 2 end]]
      }
      unexport tkclass
      method configure { args } {
          my variable widget
          my variable widgetOptions
          my variable parentOptions
          if {[llength $args] == 0}  {
              return [list {*}[array get parentOptions] {*}[array get widgetOptions]]
          } elseif {[llength $args] == 1}  {
              # return configuration value for this option
              set opt $args
              if { [info exists widgetOptions($opt) ] } {
                  return $widgetOptions($opt)
              } elseif {[info exists parentOptions($opt)]} {
                  return $parentOptions($opt)
              } else {
                  return -code error "# unkown option"
              }
          }
          
          # error checking
          if {[expr {[llength $args]%2}] == 1}  {
              return -code error "value for \"[lindex $args end]\" missing"
          }
          
          # process the new configuration options...
          array set opts $args
          set nargs [list]
          foreach opt [lsort [array names opts]] {
              set val $opts($opt)
              # overwrite with new value
              if { [info exists widgetOptions($opt)] } {
                  set widgetOptions($opt) $val
              } elseif {[info exists parentOptions($opt)]} {
                  lappend nargs $opt
                  lappend nargs $val
                  set parentOptions($opt) $val
              } else {
                  return -code error "unknown configuration option: \"$opt\" specified"
                  
              }
          }
          return [$widget configure {*}$nargs]
      } 
      method widget {} {
          my variable widgetpath
          return $widgetpath
      }
      # delegate all other methods to the widget
      method unknown {method args} {
          my variable widget
          if {[catch {$widget $method {*}$args} result]} {
              return -code error $result
          } else {
              return $result
          }
      }
      unexport unkown install
}

#' **oowidgets::widget** _classname_ _code_ 
#' 
#' > Creates a class with the given _classname_ and a widget command
#' using the given _classname_ and _code_ block.
#' The created widget command has the same name as the class 
#' name but consists only of lowercase letters. Therefor in order
#' to avoid name collisions, the given _classname_ must have at least 
#' one uppercase letter. 
#' 
#' > Hint: Since version 0.3 you can use as well only lowercase letters for the _classname_,
#' the given _classname_ will be then automatically capitalized at the first letter.
#' 
#' >  TclOO Commands:
#' 
#' >  The following new commands can be used inside the new class definition:
#' 
#' > - __callback__ METHODNAME ?args..?_ - alias for _mymmethod_, see below
#'   - __myvar__ _VARNAME_ - return the fully qualified variable name, useful
#'         useful for arguments requiring variable names, such as _-textvariable_
#'   - __mymethod__ _METHODNAME ?args..?_ - formatting object methods to use them as callbacks,
#'         for instance as arguments for _-command_
#' 
#' > Please note, that at least _callback/mymethod_ will be available in Tcl 8.7
#' 
#' > Object methods:
#' 
#' > The following public object commands are implemented within the oowidgets base class:
#' 
#' > - __cget__ _-option_ - the usual cget method for every widget, returning the standard widget options or some new options for the widget
#'   - __configure__ _?-option value ...?_ - the usual configure method for every widget working with default widget options and new options
#'   - __widget__ - returns the widget path for the underlying widget
#' 
#' > The following protected object commands are implemented within the oowidgets base class and can be used only inside derived new class:
#' 
#' > - __install__ _basewidget path ?-option value ...?_ - the way to install a default widget with standard and new options
#'   - __tkclass__  - returns the value of _[winfo class widgetPath]_ for the internal default widget, should be used inside mixins which should be working for different widget types
#' 
#' >  Example:
#' 
#' ```{.tcl eval=true echo=false results="hide"}
#' lappend auto_path .
#' ```
#' 
#' ```{.tcl eval=true}
#'    package require oowidgets
#'    namespace eval ::test { }
#'    oowidgets::widget ::test::Button {
#'        constructor {path args} {
#'           my install ttk::button $path -message testmessage
#'           my configure {*}$args
#'        }
#'        method test {} {
#'            puts [my cget -message]
#'        }
#'    }  
#'    puts "available commands: [info commands ::test::*]"
#'    set btn [::test::button .btn -command exit -text Exit]
#'    set btn2 [::test::button .btn2 -command { puts Hello } -text Hello]
#'    pack $btn -side top -padx 10 -pady 10 -ipadx 10 -ipady 10
#'    pack $btn2 -side top -padx 10 -pady 10 -ipadx 10 -ipady 10
#'    $btn test
#'    $btn configure -message newmessage
#'    $btn test
#'    $btn2 invoke
#'    after 3000 [list $btn invoke]
#' ```
#' 

proc oowidgets::widget {name body} {
    if {![regexp {[A-Z]} $name]} {
        # create class name which contains at least one
        # lowercase character
        set idx [string last :: $name]
        if {$idx eq -1} {
            set name [string toupper $name 0]
        } else {
            incr idx 2
            set name [string toupper $name $idx]
        }
    }
    catch { rename $name "" }
    oowidgets::new $name
    oo::class create $name $body
    if {[lindex $body 0] ne "superclass"} {
        oo::define $name { superclass oowidgets::BaseWidget }
    }
}

#' ## SEE ALSO
#' 
#' - [Tutorial](../tutorial.html)
#' - [Readme](../README.html)
#'
#' ## LICENSE
#'
#' Copyright 2023 Detlef Groth
#' 

#' Redistribution and use in source and binary forms, with or without
#'  modification, are permitted provided that the following conditions are met: 
#' 
#' 1. Redistributions of source code must retain the above copyright notice,
#' this list of conditions and the following disclaimer. 
#' 
#' 2. Redistributions in binary form must reproduce the above copyright
#' notice, this list of conditions and the following disclaimer in the
#' documentation and/or other materials provided with the distribution. 
#' 
#' 3. Neither the name of the copyright holder nor the names of its
#' contributors may be used to endorse or promote products derived from this
#' software without specific prior written permission. 
#'
#' THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#' - AS IS - AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#' LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
#' PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
#' OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#' EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#' PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#' OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#' WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#' OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#' ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

