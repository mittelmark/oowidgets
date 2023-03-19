package require Tk
package provide oowidgets 0.1
namespace eval ::oowidgets { }

# this is a tk-like wrapper around the class,
# so that object creation works like other Tk widgets
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
          $wtype $path
          set widget ${path}_
          foreach opts [$path configure] {
              set opt [lindex $opts 0]
              set val [lindex $opts end]
              set parentOptions($opt) $val
          }
          array set nopts $args
          foreach opt [array names nopts] {
              set widgetOptions($opt) $nopts($opt)
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
      
      method configure { args } {
              my variable widget
              my variable widgetOptions
              my variable parentOptions
              
              if {[llength $args] == 0}  {
                      return [lsort [list [array get parentOptions] {*}[array get widgetOptions]]]
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
              
              foreach opt [array names opts] {
                      set val $opts($opt)
                      
                      # overwrite with new value
                      if { [info exists widgetOptions($opt)] } {
                              set widgetOptions($opt) $val
                      } elseif {[info exists parentOptions($opt)]} {
                            set parentOptions($opt) $val
                            $widget configure $opt $val 
                      } else {
                           return -code error "unknown configuration option: \"$opt\" specified"
                          
                      }
              }
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
}
                        
proc oowidgets::widget {name body} {
    oowidgets::new $name
    oo::class create $name $body 
    oo::define $name { superclass oowidgets::BaseWidget }
}
