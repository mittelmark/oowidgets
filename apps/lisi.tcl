#!/usr/bin/env tclsh
##############################################################################
#
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : MicroEmacs User
#  Created       : 2025-02-06 06:12:50
#  Last Modified : <250206.0729>
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


package require paul
package provide lisi
set app [::paul::basegui new -style clam]
set f [$app getFrame]
set ie [paul::imedit $f.ie -commandline "dot -Tpng %i -o %o"  \
        -statuslabel [$app message] -pane horizontal]
$ie labentry configure -labeltext "Command Line: "
set txt [$ie text] 
$txt configure -background skyblue
$txt insert 1.0 "digraph g { A -> B } \n"
oo::objdefine  $txt mixin paul::txindent paul::txfileproc
pack $ie -side top -fill both -expand true -padx 5 -pady 5
$app addStatusBar
