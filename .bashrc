# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
test -z "$initDir" && export initDir=$HOME/.initBash
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" '>' 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."
function Source { test "$debug" '>' 0 && time source "$@" && echo || source "$@" ; }

#test -z "$bashProfileLoaded" && Source .profile
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "/etc/skel/.bashrc" ]; then
		test "$debug" '>' 0 && echo "=> Running $bold${colors[blue]}/etc/skel/.bashrc$normal ..."
		Source /etc/skel/.bashrc
		test "$debug" '>' 0 && echo "=> END of $bold${colors[blue]}/etc/skel/.bashrc$normal"
    fi
fi

test -f $initDir/.bashrc.seb && Source $initDir/.bashrc.seb #Pour que "scp/rsync" fonctionnent meme si il y a des commandes "echo"

set +x
test "$debug" '>' 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
