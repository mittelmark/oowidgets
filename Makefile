
default:
	pandoc tutorial.md -o tutorial.html --filter pantcl -s --toc
	htmlark tutorial.html -o temp.html
	mv temp.html tutorial.html
manual:
	pantcl oowidgets/oowidgets.tcl oowidgets/oowidgets.html -s 

paul-manual:
	pandoc paul/header.md -o paul/header.html 	
	pantcl paul/basegui.tcl paul/basegui.html -s
	pantcl paul/statusbar.tcl paul/statusbar.html -s
	pantcl paul/dlabel.tcl paul/dlabel.html -s	
	pantcl paul/rotext.tcl paul/rotext.html -s		
	pantcl paul/notebook.tcl paul/notebook.html -s
	rm paul/header.html
 	
record:
	byzanz-record --delay 4 --duration=13 --x=860 --y=40 --width=1065 \
		--height=720 out.gif &  pandoc tutorial.md \
		-o tutorial.html --filter pantcl -s

