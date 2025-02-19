TCLSH=tclsh
default:
	#pandoc tutorial.md -o tutorial.html --filter pantcl -s --toc
	pantcl tutorial.md tutorial.html --css mini.css --no-pandoc
	#htmlark tutorial.html -o temp.html
	#mv temp.html tutorial.html
manual:
	pantcl oowidgets/oowidgets.tcl oowidgets/oowidgets.html --css "mini.css" --no-pandoc

paul-manual:
	pandoc paul/header.md -o paul/header.html 	
	pantcl paul/basegui.tcl paul/basegui.html --css mini.css --no-pandoc
	pantcl paul/dlabel.tcl paul/dlabel.html --css mini.css --no-pandoc
	pantcl paul/imedit.tcl paul/imedit.html --css mini.css --no-pandoc	
	pantcl paul/labentry.tcl paul/labentry.html --css mini.css --no-pandoc
	pantcl paul/rotext.tcl paul/rotext.html --css mini.css --no-pandoc
	pantcl paul/notebook.tcl paul/notebook.html --css mini.css --no-pandoc
	pantcl paul/statusbar.tcl paul/statusbar.html --css mini.css --no-pandoc
	pantcl paul/txmixins.tcl paul/txmixins.html --css mini.css --no-pandoc
	pantcl paul/tvmixins.tcl paul/tvmixins.html --css mini.css --no-pandoc	
	rm paul/header.html

paul-demo:
	TCLLIBPATH=. $(TCLSH) paul/basegui.tcl --demo
	TCLLIBPATH=. $(TCLSH) paul/dlabel.tcl --demo
	TCLLIBPATH=. $(TCLSH) paul/imedit.tcl --demo	
	TCLLIBPATH=. $(TCLSH) paul/labentry.tcl --demo
	TCLLIBPATH=. $(TCLSH) paul/notebook.tcl --demo	
	TCLLIBPATH=. $(TCLSH) paul/rotext.tcl --demo
	TCLLIBPATH=. $(TCLSH) paul/statusbar.tcl --demo
	TCLLIBPATH=. $(TCLSH) paul/tvmixins.tcl --demo	
	TCLLIBPATH=. $(TCLSH) paul/txmixins.tcl --demo	
test:
	$(TCLSH) tests/flash.test 	
record:
	byzanz-record --delay 4 --duration=13 --x=860 --y=40 --width=1065 \
		--height=720 out.gif &  pandoc tutorial.md \
		-o tutorial.html --filter pantcl -s

