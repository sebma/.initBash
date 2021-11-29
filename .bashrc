# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
test -z "$initDir" && export initDir=$HOME/.initBash
! declare 2>&1 | grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test -z "$debug" && export debug=0
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."
tty -s && test "$debug" -gt 0 && { echo;echo "=> \${BASH_SOURCE[*]} = ${BASH_SOURCE[*]}";echo; }

#test -z "$bashProfileLoaded" && source .profile
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "/etc/skel/.bashrc" ]; then
		if [ "$debug" -gt 0 ];then
			echo "=> Running $bold${colors[blue]}/etc/skel/.bashrc$normal ..."
			time source /etc/skel/.bashrc;true
			echo "=> END of $bold${colors[blue]}/etc/skel/.bashrc$normal"
		else
			source /etc/skel/.bashrc
		fi
	fi
fi

# Le "tty -s" indique si le shell est interactif.Il est donc la pour ne pas sourcer ".bashrc.seb" en mode non-interif afin que "scp/rsync" puissen(nt) fonctionner
if tty -s && [ -f $initDir/.bashrc.seb ];then
	test "$debug" -gt 0 && { time source $initDir/.bashrc.seb;true; } || source $initDir/.bashrc.seb
fi

test "$debug" -lt 3 && set +x
test "$debug" -gt 0 && \echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
