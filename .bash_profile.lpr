#!sh
alias lprColor="\lpr -P $(lpstat -a 2>/dev/null | awk '/[Cc](olor|ouleur)/{print$1;exit}')"
alias a2psColor="\a2ps -P $(lpstat -a 2>/dev/null | awk '/[Cc](olor|ouleur)/{print$1;exit}')"
export colorPrinter="$(lpstat -a | awk '/[Cc](olor|ouleur)/{print$1;exit}')"
export defaultPrinter="$(LANG=C lpstat -d 2>/dev/null | awk '/^system default destination:/{print$NF}')"
which lpstat >/dev/null 2>&1 && export defaultPrinter=$(LANG=C lpstat -a 2>/dev/null | awk '/accepting/{print$1}') || export defaultPrinter=""
#if which lpstat >/dev/null 2>&1 && lpstat -p 2>/dev/null | grep -q printer

if which lpstat >/dev/null 2>&1 && lpstat -p 2>/dev/null | grep -q printer 
then
	lpoptions -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=single -o prettyprint -o StapleLocation=UpperLeft
	export colorPrinter="$(lpstat -a | awk '/[Cc](olor|ouleur)/{print$1;exit}')"
	test $colorPrinter && lpoptions -p $colorPrinter -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=single -o prettyprint -o StapleLocation=UpperLeft
fi

#lpoptions -p $defaultPrinter/Duplex2PagesPerSheet -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=double -o number-up=2 -o number-up-layout=btlr  -o page-border=single -o prettyprint
#lpoptions -p $defaultPrinter/Duplex4PagesPerSheet -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=double -o number-up=4 -o page-border=single -o prettyprint
