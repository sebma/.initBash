#!sh

#Finding the emplacement of the "history.m" file to be used with the GNU Readline wrapper
case $(uname -s) in
	Darwin)
	test -d "$HOME/Library/Application Support/MathWorks/MATLAB" && export MATLAB=$(\ls -d "$HOME/Library/Application Support/MathWorks/MATLAB/"* | head -1)
	;;
	Linux)
	test -d "$HOME/.matlab" && export MATLAB=$(\ls -d "$HOME/.matlab/"* | head -1)
	;;
esac
