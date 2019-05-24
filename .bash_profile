# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
scriptDir=$(cd $(dirname $BASH_SOURCE);pwd);test $HOME = / && export HOME=$scriptDir ; cd #Pour les cas tordus ou HOME pointerai sur "/", par example sur les certains telephones Android

export initDir=$HOME/.initBash
set | grep -q "^colors=" || source $initDir/.colors
test $debug || debug=0
test "$debug" '>' 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."
function Source { test "$debug" '>' 0 && time source "$@" && echo || source "$@" ; }

test -f $initDir/.bash_profile.seb && Source $initDir/.bash_profile.seb

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$initDir/.bashrc" ]; then
		Source "$initDir/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    echo $PATH | grep -wq "$HOME/bin" || PATH="$HOME/bin:$PATH"
fi

set +x
test "$debug" '>' 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
