# vim: set ft=sh noet:
# ~/.bash_logout: executed by bash(1) when login shell exits.
! declare 2>&1 | \grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

# when leaving the console clear the screen to increase privacy

if [ "$SHLVL" = 1 ]; then
	[ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

test -f $initDir/.bash_logout.seb && source $initDir/.bash_logout.seb

set -x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal" || Echo "=> Closing connection to $(echo $SSH_CONNECTION | awk '$0=$3') ..."
