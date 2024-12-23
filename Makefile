
default:
	pandoc tutorial.md -o tutorial.html --filter pantcl -s --toc
	htmlark tutorial.html -o temp.html
	mv temp.html tutorial.html
manual:
	pantcl oowidgets/oowidgets.tcl oowidgets/oowidgets.html --css "mini.css"

paul-manual:
	pandoc paul/header.md -o paul/header.html 	
	pantcl paul/basegui.tcl paul/basegui.html --css mini.css
	pantcl paul/statusbar.tcl paul/statusbar.html --css mini.css
	pantcl paul/dlabel.tcl paul/dlabel.html --css mini.css
	pantcl paul/rotext.tcl paul/rotext.html --css mini.css
	pantcl paul/notebook.tcl paul/notebook.html --css mini.css
	pantcl paul/txmixins.tcl paul/txmixins.html --css mini.css
	rm paul/header.html

test:
	tclsh tests/flash.test 	
record:
	byzanz-record --delay 4 --duration=13 --x=860 --y=40 --width=1065 \
		--height=720 out.gif &  pandoc tutorial.md \
		-o tutorial.html --filter pantcl -s

