# vim: set ft=bash noet:
! declare 2>&1 | grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

alias findipp="\ippfind _ipp._tcp"
alias findipps="\ippfind _ipps._tcp"
alias findprinter="\ippfind _printer._tcp"

set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
