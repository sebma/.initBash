# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
test -z "$initDir" && export initDir=$HOME/.initBash
! declare 2>&1 | grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" || debug=0
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

#test -z "$bashProfileLoaded" && source .profile
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "/etc/skel/.bashrc" ]; then
		test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}/etc/skel/.bashrc$normal ..."
		source /etc/skel/.bashrc
		test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}/etc/skel/.bashrc$normal"
	fi
fi

tty -s && test -f $initDir/.bashrc.seb && source $initDir/.bashrc.seb #Pour que "scp/rsync" fonctionnent meme si il y a des commandes "echo"

test "$debug" -lt 3 && set +x
test "$debug" -gt 0 && \echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
