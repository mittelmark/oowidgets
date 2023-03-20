package require oowidgets
package provide tkoo 0.2
namespace eval ::tkoo { }
oowidgets::widget ::tkoo::Button {
    constructor {path args} {
        my install ttk::button $path
        my configure {*}$args
    }
}
oowidgets::widget ::tkoo::Canvas {
    constructor {path args} {
        my install tk::canvas $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::CheckButton {
    constructor {path args} {
        my install ttk::checkbutton $path
        my configure {*}$args
    }
}
oowidgets::widget ::tkoo::ComboBox {
    constructor {path args} {
        my install ttk::combobox $path
        my configure {*}$args
    }
}
oowidgets::widget ::tkoo::Entry {
    constructor {path args} {
        my install ttk::entry $path
        my configure {*}$args
    }
}
oowidgets::widget ::tkoo::Frame {
    constructor {path args} {
        my install ttk::frame $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::Label {
    constructor {path args} {
        my install ttk::label $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::LabelFrame {
    constructor {path args} {
        my install ttk::labelframe $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::ListBox {
    constructor {path args} {
        my install tk::listbox $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::Menu {
    constructor {path args} {
        my install tk::menu $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::MenuButton {
    constructor {path args} {
        my install ttk::menubutton $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::NoteBook {
    constructor {path args} {
        my install ttk::notebook $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::PanedWindow {
    constructor {path args} {
        my install ttk::panedwindow $path
        my configure {*}$args
    }
}
oowidgets::widget ::tkoo::ProgessBar {
    constructor {path args} {
        my install ttk::progressbar $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::RadioButton {
    constructor {path args} {
        my install ttk::radiobutton $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::Scale {
    constructor {path args} {
        my install ttk::scale $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::ScrollBar {
    constructor {path args} {
        my install ttk::scrollbar $path
        my configure {*}$args
    }
}


oowidgets::widget ::tkoo::Separator {
    constructor {path args} {
        my install ttk::separator $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::SizeGrip {
    constructor {path args} {
        my install ttk::sizegrip $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::SpinBox {
    constructor {path args} {
        my install ttk::spinbox $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::Text {
    constructor {path args} {
        my install tk::text $path
        my configure {*}$args
    }
}

oowidgets::widget ::tkoo::TreeView {
    constructor {path args} {
        my install ttk::treeview $path
        my configure {*}$args
    }
}


