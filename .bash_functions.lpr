# vim: set ft=sh noet:
! declare 2>&1 | grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

function lprColorPageRange {
	test -n "$colorPrinter" && test $colorPrinter && lprPageRange $@ -P $colorPrinter
}
function lprPageRange {
	test $# -lt 2 && {
		echo "=> Usage: $FUNCNAME pageRange pdf/psFile" >&2
		return 1
	}

	pageRange=$1
	shift
	test $pageRange && echo $pageRange | grep -ivq "[A-Z]" && command lpr -o page-ranges=$pageRange $@ && lpq
}

set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
