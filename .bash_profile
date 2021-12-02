test "$HOME" = / && export HOME=$(cd $(dirname $BASH_SOURCE);pwd) && cd #Pour les cas tordus ou HOME pointerai sur "/", par example sur les certains telephones Android apres un "adb shell"
test -n "$debug" || debug=0
test "$debug" -gt 0 && tty -s && echo "=> Running $(basename ${BASH_SOURCE[0]})$normal ..."

test -f $HOME/.initBash/.bash_profile.seb && source $HOME/.initBash/.bash_profile.seb

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
	PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
	PATH="$HOME/.local/bin:$PATH"
fi

test "$debug" -lt 3 && set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
