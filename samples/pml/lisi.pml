@startuml
scale 1.5
package " paul " {
  class basegui {
    // Class attributes and methods
  }
  class imedit { }
  class labentry { }
  class txfileproc <<mixin>>
}

package " tk " {
  class tk::text { }
  class ttk::label
  class ttk::entry 
}

Entity app << (I,#EE9999) Lisi>> {
  gui()
  main()
}

app --> basegui : " instance-of"
app *- imedit : " part-of"
tk::text --|> txfileproc : " mixin"
imedit *-- txfileproc : part-of
imedit *-- labentry : part-of
labentry *-- ttk::label
labentry *-- ttk::entry
@enduml


