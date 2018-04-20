# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" = "1" && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."
function Source { test "$debug" = "1" && time source "$@" && echo || source "$@" ; }

#test -z "$bashProfileLoaded" && Source .profile
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "/etc/skel/.bashrc" ]; then
		Source /etc/skel/.bashrc
    fi
fi

test -f $initDir/.bashrc.seb && Source $initDir/.bashrc.seb

set +x
test "$debug" = "1" && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
