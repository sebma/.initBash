# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

#test -z "$bashProfileLoaded" && source .profile
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "/etc/skel/.bashrc" ]; then
    . "/etc/skel/.bashrc"
    fi
fi

test -f $initDir/.bashrc.seb && source $initDir/.bashrc.seb
