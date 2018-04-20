# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
declare -A | grep -wq color || source $initDir/.colors
test "$debug" = "1" && echo "=> Running $blink$bold${colors[blue]}${BASH_SOURCE[0]}$normal ..."

#test -z "$bashProfileLoaded" && Source .profile
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "/etc/skel/.bashrc" ]; then
		test "$debug" = "1" && time source /etc/skel/.bashrc || source /etc/skel/.bashrc
    fi
fi

test -f $initDir/.bashrc.seb && test "$debug" = "1" && time source $initDir/.bashrc.seb || source $initDir/.bashrc.seb

set +x
test "$debug" = "1" && echo "=> END of $blink$bold${colors[blue]}${BASH_SOURCE[0]}$normal"
