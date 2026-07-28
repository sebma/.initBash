# vim: ft=bash noet:
! declare 2>&1 | grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

#alias lpr="\lpr -P ppti-14-503-imp -o PageSize=A4 -o PageRegion=A4 -o Resolution=default -o InputSlot=Tray2 -o Duplex=DuplexNoTumble -o PreFilter=No"
#alias lpr="\lpr -o PageSize=A4 -o PageRegion=A4 -o Resolution=default -o InputSlot=Tray2 -o Duplex=DuplexNoTumble -o PreFilter=No"
alias enscript='\a2ps -P $colorPrinter'
alias setDefaultPrinter='lpoptions -d'
alias defaultPrinter='lpstat -d'
alias findipp="\ippfind _ipp._tcp"
alias findipps="\ippfind _ipps._tcp"
alias findprinter="\ippfind _printer._tcp"
alias lpq="\lpq -a +3"
alias lpr2ppsheet="\lpr -o number-up=2"
alias lprColor='\lpr -P $colorPrinter'
alias printerInfo='lpstat -l -p'
alias printerList='lpstat -e'
alias printerOptions='lpoptions -l -p $(lpstat -e | head -1)'
alias printerStatus='lpstat -s'

set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
