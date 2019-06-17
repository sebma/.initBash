# vim: set syn=sh noet:
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" '>' 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

[ "$debug" '>' 1 ] && time="eval time" || time=eval
$time defaultPrinter="$(LANG=C lpstat -p -d 2>/dev/null | awk '/^system default destination:/{print$NF;exit}')" #i.e. https://www.cups.org/doc/options.html#PRINTER
if test $defaultPrinter
then
	lpoptions -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=single-thick -o prettyprint -o StapleLocation=UpperLeft

	$time colorPrinter="$(LANG=C lpstat -a | awk 'BEGIN{IGNORECASE=1}/(color|couleur)/{print$1;exit}')"
	if test $colorPrinter 
	then
		lpoptions -p $colorPrinter -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=single-thick -o prettyprint -o StapleLocation=UpperLeft
		alias lprColor='\lpr -P $colorPrinter'
		alias a2psColor='\a2ps -P $colorPrinter'
	fi
else
	$time defaultPrinter=$(LANG=C lpstat -a 2>/dev/null | grep -vi pdf | awk '/accepting/{print$1;exit}') || defaultPrinter=""
	test $defaultPrinter && lpadmin -d $defaultPrinter
fi

if test $defaultPrinter && lpstat -d | grep -q 'no system default destination'
then
	lpoptions -d $defaultPrinter
fi

export defaultPrinter colorPrinter

#lpoptions -p $defaultPrinter/Duplex2PagesPerSheet -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=double -o number-up=2 -o number-up-layout=btlr  -o page-border=single-thick -o prettyprint
#lpoptions -p $defaultPrinter/Duplex4PagesPerSheet -o media=A4 -o fit-to-page -o Duplex=DuplexNoTumble -o sides=two-sided-long-edge -o page-border=double -o number-up=4 -o page-border=single-thick -o prettyprint

set +x
test "$debug" '>' 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
