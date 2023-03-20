
default:
	pandoc tutorial.md -o tutorial.html --filter pantcl -s --toc
	htmlark tutorial.html -o temp.html
	mv temp.html tutorial.html

record:
	byzanz-record --delay 4 --duration=13 --x=860 --y=40 --width=1065 \
		--height=720 out.gif &  pandoc tutorial.md \
		-o tutorial.html --filter pantcl -s

