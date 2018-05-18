#!sh
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" '>' 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

#Finding the emplacement of the "history.m" file to be used with the GNU Readline wrapper
case $(uname -s) in
	Darwin)
#To use "$MATLAB/history.m" in rlwrap
	test -d "$HOME/Library/Application Support/MathWorks/MATLAB" && export MATLAB=$(\ls -d "$HOME/Library/Application Support/MathWorks/MATLAB/"* | head -1)
	;;
	Linux)
	test -d "$HOME/.matlab" && export MATLAB=$(\ls -d "$HOME/.matlab/"* | head -1)
	;;
esac

set +x
test "$debug" '>' 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
