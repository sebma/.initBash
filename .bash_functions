# vim: ft=bash noet:
! declare 2>&1 | \grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

Source $initDir/.bash_functions.build
Source $initDir/.bash_functions.AV

test "$debug" -gt 0 && Echo "\n=> \${BASH_SOURCE[*]} = ${BASH_SOURCE[*]}\n"
find="$(type -P find)"

function EchoSpecialCharacters {
	local rc=$?
	set +o histexpand # Turn off history expansion to be able easily use the exclamation mark in strings i.e https://stackoverflow.com/a/22130745/5649639
	command echo "$@"
	set -o histexpand
	return $rc
}
function Cat {
	local highlightCMD="command highlight -O ansi --force"
	if [ $# = 0 ] || [ "$1" = - ];then
		$highlightCMD
	else
		for file
		do
			echo "::::::::::::::" 1>&2
			echo $file 1>&2
			echo "::::::::::::::" 1>&2
			$highlightCMD "$file"
		done
	fi
}
function Less {
	local highlightCMD="command highlight -O ansi --force"
	local extension=not_yet_defined
	local lessColors="command less -R"
	local less="command less -r"
	if [ $# = 0 ] || [ "$1" = - ];then
		$highlightCMD | $lessColors
	else
		for file
		do
			extension=$(basename "$file" | awk -F"." '{print tolower($NF)}')
			[ $extension != pdf ] && $highlightCMD "$file" | $lessColors || $less "$file"
		done
	fi
}
function More {
	local highlightCMD="command highlight -O ansi --force"
	if [ $# = 0 ] || [ "$1" = - ];then
		$highlightCMD
	else
		for file
		do
			echo "::::::::::::::" 1>&2
			echo $file 1>&2
			echo "::::::::::::::" 1>&2
			$highlightCMD "$file"
		done
	fi | more
}
function Most {
	local highlightCMD="command highlight -O ansi --force"
	if [ $# = 0 ] || [ "$1" = - ];then
		$highlightCMD | most
	else
		for file
		do
			echo "::::::::::::::" 1>&2
			echo $file 1>&2
			echo "::::::::::::::" 1>&2
			$highlightCMD "$file" | most
		done
	fi
}
function Nohup {
	local firstArg=$1
	local nohup="command nohup"
	if [ $(type -t $firstArg) = function ]
	then
		shift && $nohup bash -c "$(declare -f $firstArg);$firstArg $*"
	elif [ $(type -t $firstArg) = alias ]
	then
		alias nohup='\nohup '
		eval "nohup $@"
	else
		$nohup "$@"
	fi
}
function Sudo {
	local firstArg=$1
	if [ $(type -t $firstArg) = function ]
	then
		shift && $sudo bash -c "$(declare -f $firstArg);$firstArg $*"
	elif [ $(type -t $firstArg) = alias ]
	then
		alias sudo='\sudo '
		eval "sudo $@"
	else
		$sudo "$@"
	fi
}
function Top {
	local top=$(type -aP top | \grep ^/usr) #Au cas ou il y a un script top ailleurs dans le PATH
	local processPattern=$1
	test -n "$processPattern" && shift && local processPIDs=$(\pgrep -f $processPattern)
	if [ -z "$processPIDs" ]
	then
		$top
	else
		if   [ $osFamily = Linux ]
		then
			$top -d 1 $(printf -- "-p %d " $processPIDs) $@
		elif [ $osFamily = Darwin ]
		then
			$top -i 1 $(printf -- "-pid %d " $processPIDs) $@
		fi
	fi
}
function addUsersInGroup {
#	local lastArg="$(eval echo \${$#})"
#	local lastArg="${@:$#}"
	local lastArg="${@: -1}"
	local allArgsButLast="${@:1:$#-1}"
	for user in $allArgsButLast
	do
		sudo adduser $user $lastArg
	done
}
function anyTimeWithTZ2LocalTimeZone {
	local remoteTime=to_be_defined
	local remoteTZ
	local date=date
	test $osFamily = Darwin && date=gdate
	if [ $# = 0 ];then
		echo "=> Usage : $FUNCNAME remoteTime [remoteTZ]" >&2
		return 1
	elif [ $# = 1 ];then
		case $1 in
			-h|--h|-help|--help) echo "=> Usage : $FUNCNAME remoteTime [remoteTZ]" >&2;return 1;;
			*) remoteTime=$1;;
		esac
	else
		remoteTime=$1
		remoteTZ=$2
	fi

	remoteTime=${remoteTime/./:}
	$date -d "$remoteTime $remoteTZ"
}
function any2ascii {
	local encoding=unknown
	for file
	do
		encoding=$(file -b -i "$file" | cut -d= -f2 | $sed "s/([0-9]+)[lb]e/\1/")
		if type -P iconv >/dev/null 2>&1;then
			iconv -f $encoding "$file"
		elif type -P recode >/dev/null 2>&1;then
			cat "$file" | recode $encoding.. 2>/dev/null
		fi
	done
}
function apkInfo {
	type aapt >/dev/null || return
	local apkFullInfo="$(type -P aapt) dump badging"
	for package
	do
		echo "=> package = $package"
		[ -f "$package" ] || {
			echo "==> ERROR : The file $package does not exist." >&2; continue
		}

		$apkFullInfo "$package"
		echo
	done | egrep "^$|\b([s]dkVersion|application-label|native-code|versionName|package: +name)[:=][^ ]+"
}
function apkRename {
	type aapt >/dev/null || return
	local apkFullInfo="$(type -P aapt) dump badging"
	for package
	do
		echo "=> package = $package"
		[ -f "$package" ] || {
			echo "==> ERROR : The package $package does not exist." >&2; continue
		}

		packagePath=$(dirname "$package")
		set -o pipefail
		packageID=$($apkFullInfo "$package" | awk -F"'" '/^package:/{print$2}') || continue
		set +o pipefail
		packageVersion=$($apkFullInfo "$package" | awk -F"'" '/^package:/{print$6}' | cut -d' ' -f1)
		packageNewFileName="$packagePath/$packageID-$packageVersion.apk"
		[ "$package" = $packageNewFileName ] || \mv -vi "$package" $packageNewFileName
	done
}
function apkRename_All_APKs {
	type aapt || return
	ls *.apk >/dev/null && apkRename *.apk
}
function aria2c {
#	local options="$(echo "$@" | \sed -E "s/(^| )[^ -]+\b//g")" # Suppressing non options
#	local urls="$(echo "$@" | \sed -E "s/(^| )-[^ ]+\b//g")" # Suppressing options
#	for url in $urls
	for url
	do
		command aria2c $options "$url"
	done
}
function asc2gpg {
	for ascFile
	do
		\gpg -v -o "${ascFile/.asc/.gpg}" --dearmor "$ascFile"
	done
}
function aslookup {
	echo "AS      | IP               | BGP Prefix          | CC | Registry | Allocated  | AS Name"
	for ip
	do
		whois -h whois.cymru.com " -v $ip" | \grep ^[0-9]
	done
}
function aslookupSeb {
	local options=""
	if echo $1 | grep "^-" -q;then
		options="$1 $2"
		shift 2
	fi

	echo "AS      | IP               | BGP Prefix          | CC | Registry | Allocated  | AS Name"
	for ip
	do
		whois $ip | awk -v ip=$ip -F':| +' 'BEGIN{IGNORECASE=1}/Origin(AS)?:/{as=$3}/CIDR:|route:/{cidr=$3}/country:/{country=$3}/RegDate:/{regdate=$3}/netname:/{asname=$3}END{printf "%-7s | %-16s | %-19s | %-2s | %-8s | %-10s | %s\n", as,ip,cidr,country,registry,regdate,asname}'
	done
}
function awkCalc {
	set -- ${@/[/(}
	set -- ${@/]/)}
	\awk -v CONVFMT=%.15g 'BEGIN{ print '"$*"' "" }'
}
function backupFile {
	for file
	do
		date=$(stat -c %y "$file" | cut -d" " -f1 | tr -d -)
		ext="${file/*./}"
		basename="${file/.$ext/}"
		\cp -piv "$file" "$basename-$date.$ext"
	done
}
function baseName {
	for arg
	do
		echo ${arg/*\//}
	done
}
function bible {
	local bible="command bible"
	for verses
	do
		$bible $verses | sed -n "2,3p"
		$bible -f $verses | cut -d: -f2
	done
}
function brewInstall {
	if ! type -P brew >/dev/null 2>&1; then
		if [ $osFamily = Linux ]; then
			if groups | \egrep -wq "adm|admin|sudo|wheel";then
				brewPrefix=/home/linuxbrew/.linuxbrew
			else
				brewPrefix=$HOME/.linuxbrew
			fi
		elif [ $osFamily = Darwin ]; then
			brewPrefix=/usr/local
		fi

		$SHELL -c "$(\curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" || return

		echo $PATH | grep -q $brewPrefix || export PATH=$brewPrefix/bin:$PATH
		brew=$brewPrefix/bin/brew
		$brew -v
	fi

	if test -x $brew;then
		source $initDir/.bash_functions.brew
		brewPostInstall
	fi
}
function brewPortableInstall {
	brew=undefined
	brewPrefix=undefined
	if ! type -P brew > /dev/null 2>&1; then
		git --help >/dev/null || return
		brewPrefix=$HOME/.linuxbrew
		git clone https://github.com/homebrew/brew $brewPrefix

		echo $PATH | grep -q $brewPrefix || export PATH=$brewPrefix/bin:$PATH
		brew=$brewPrefix/bin/brew
		$brew -v
	fi

	if test -x $brew;then
		source $initDir/.bash_functions.brew
		brewPostInstall
	fi
}
function castnowPlaylist {
	test $# = 0 && {
		echo "=> Usage: $FUNCNAME [index] [format] playlistFile ..." >&2
		return 1
	}

	local index=1
	local format="mp4[height<=480]/mp4/best"
	local playlist
	test $# = 1 && playlist=$1
	test $# = 2 && format=$1 && playlist=$2
	test $# = 3 && index=$1 && format=$2 && playlist=$3
	printf "=> Start playing playlist at: "
	\sed -n "${index}p" $playlist
	castnowURLs $format $(awk '{print$1}' $playlist | \grep -v "^#" | tail -n +$index)
}
function castnowURLs {
	test $# = 0 && {
		echo "=> Usage: $FUNCNAME [ytdl-format] url1 url2 ..." >&2
		return 1
	}

	local format="mp4[height<=480]/mp4/best"
	echo $1 | \egrep -q "^(https?|s?ftps?)://" || { format="$1"; shift; }

	for url
	do
		echo "youtube-dl --no-continue --ignore-config -f $format -o- -- $url | castnow --quiet -"
		youtube-dl --no-continue --ignore-config -f "$format" -o- -- "$url" | castnow --quiet -
	done
	set +x
	echo
}
function cgrep {
	local allArgsButLast="${@:1:$#-1}"
	local lastArg="${@: -1}"
	local url="$lastArg"
	if [ $# == 0 ]
	then
		echo "=> Usage: $FUNCNAME [grepOptions] regexp url"
		return 1
	fi
	\curl -Ls "$url" | grep $allArgsButLast
}
function chromium_snap_start {
	local SNAP=$(snap run --shell chromium -c 'echo $SNAP')
	local SNAP_USER_COMMON=$(snap run --shell chromium -c 'echo $SNAP_USER_COMMON')
	SNAP=$SNAP SNAP_USER_COMMON=$SNAP_USER_COMMON $SNAP/bin/chromium.launcher "$@" &
}
function cleanFirefoxLock {
	case $osID in
		debian) firefoxProgramName=iceweasel;;
		ubuntu) firefoxProgramName=firefox;;
	esac

	pgrep -lf $firefoxProgramName || \rm -vf ~/.mozilla/firefox/*.default/lock ~/.mozilla/firefox/*.default/.parentlock
}
function compareRemoteFile {
	local sdiffOptions=""
	if [ $# != 3 ] && [ $# != 4 ];then
		echo "=> Usage: $FUNCNAME filePath server1|localhost|. server2|localhost|." >&2
		return 1
	elif [ $# == 4 ] && [ ${1:0:1} == "-" ];then
		sdiffOptions=$1
		shift
		[ ${sdiffOptions:0:2} == "-h" ] && sdiff --help && return
	fi

	local filePath="$1"
	shift
	local server1=$1
	local server2=$2

	#Le dernier cat est la au cas ou le mdp est demande de maniere interactive
	if [ $server1 = localhost ] || [ $server1 == . ];then
		sdiff $sdiffOptions "$filePath" <(ssh $server2 cat "$filePath") | cat
	elif [ $server2 = localhost ] || [ $server2 == . ];then
		sdiff $sdiffOptions <(ssh $server1 cat "$filePath") "$filePath" | cat
	else
		sdiff $sdiffOptions <(ssh $server1 cat "$filePath") <(ssh $server2 cat "$filePath") | cat
	fi
}
function compareRemoteDir {
	local sdiffOptions=""
	if [ $# != 3 ] && [ $# != 4 ];then
		echo "=> Usage: $FUNCNAME dirPath server1|localhost|. server2|localhost|." >&2
		return 1
	elif [ $# == 4 ] && [ ${1:0:1} == "-" ];then
		sdiffOptions=$1
		shift
		[ ${sdiffOptions:0:2} == "-h" ] && sdiff --help && return
	fi

	local dirPath="$1"
	shift
	local server1=$1
	local server2=$2

	#Le dernier cat est la au cas ou le mdp est demande de maniere interactive
	if [ $server1 = localhost ] || [ $server1 == . ];then
		sdiff $sdiffOptions <(find "$dirPath" -printf '%p\t%s\n' | sort) <(ssh $server2 find "$dirPath" -printf '"%p\t%s\n"' | sort) | cat
	elif [ $server2 = localhost ] || [ $server2 == . ];then
		sdiff $sdiffOptions <(ssh $server1 find "$dirPath" -printf '"%p\t%s\n"' | sort) <(find "$dirPath" -printf '%p\t%s\n' | sort) | cat
	else
		sdiff $sdiffOptions <(ssh $server1 find "$dirPath" -printf '"%p\t%s\n"' | sort) <(ssh $server2 find "$dirPath" -printf '"%p\t%s\n"' | sort) | cat
	fi
}
function conda2Rename {
	oldName=$1
	newName=$2
	test $# = 2 && {
		conda2 create --name $newName --offline --clone $oldName
		conda2 remove --name $oldName --offline --all
	}
}
function conda3Rename {
	oldName=$1
	newName=$2
	test $# = 2 && {
		conda3 create --name $newName --offline --clone $oldName
		conda3 remove --name $oldName --offline --all
	}
}
function condaSearchThroughChannels {
	pythonChannelsList="conda-forge intel anaconda aaronzs"
	for pkg
	do
		for ch in $pythonChannelsList
		do
			echo "=> Searching through conda channel <$ch> ..."
			conda search -c $ch $pkg 2>/dev/null
		done
	done
}
function convertion {
	local lastArg="${@: -1}"
	local retCode=unset

	set -o pipefail
	units -t "$@" | tr -d "\n"
	retCode=$?
	set +o pipefail
	echo " $lastArg"

	return $retCode
}
function countWorkDays {
	local monthNumber=-1
	local year=-1

	case $# in
		0) monthNumber=$(date +%m);year=$(date +%Y);;
		1) test $1 -le 12 && { monthNumber=$1;year=$(date +%Y);} || year=$1;;
		2) monthNumber=$1;year=$2;;
		*) echo "=> Usage: $FUNCNAME [monthNumber=current] [year=current]" >&2;return 1;;
	esac

#	export LC_MESSAGES=en_US.UTF-8
	if [ $# == 1 ] && [ $monthNumber == -1 ];then
		gcal -Hno -b1 $year | \egrep -v "^Sa|^Su|$year|^$|^ +[[:alpha:]]+" | sed "s/^[[:alpha:]]*\s*//g" | fmt -w 1 | wc -l
	else
		gcal -Hno $monthNumber $year | \egrep -v "Saturday|Sunday|$year|^$" | sed "s/^[[:alpha:]]*\s*//g" | fmt -w 1 | wc -l
	fi
}
function createSshTunnel {
	test $# -lt 3 && {
		echo "=> Usage : $FUNCNAME <localPort> <remotePort> <remoteServer> <sshServer>"
		echo "OR"
		echo "=> Usage : $FUNCNAME <localPort> <remotePort> <sshServer>"
		return 1
	} >&2

	declare -i localPort=$1
	declare -i remotePort=$2

	if [ $# = 3 ]
	then
		declare sshServer=$3
		remoteServer=localhost
	elif [ $# -gt 3 ]
	then
		declare remoteServer=$3
		declare sshServer=$4
		test $sshServer = $remoteServer && remoteServer=localhost
	fi

	if autossh -V >/dev/null 2>&1
	then
#		command autossh -M 0 -f -T -N cli-myJupyter-Tunnel
		command autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -f -N -L $localPort:$remoteServer:$remotePort $sshServer
	else
		command ssh -f -N -L $localPort:$remoteServer:$remotePort $sshServer
	fi

	pgrep ssh.*-L
}
function ddPV {
	test $# -lt 2 && {
		echo "=> Usage: $FUNCNAME if=FILE of=FILE OPTIONS ..." >&2
		return -1
	}
	input=$1
	inputFile=$(echo $input | awk -F= '{print$2}')
	shift
	#echo "=> sudo pv --wait $inputFile | sudo dd $@ ..."
	#time sudo pv --wait $inputFile | sudo dd $@
	echo "=> sudo bash -c \"pv $inputFile | dd $@\" ..."
	time sudo bash -c "pv $inputFile | dd $@"
}
function dfc {
	firstArg=$1
	if echo "$firstArg" | \egrep -q "^\-|^$"
	then
		command dfc -TWw "$@"
	else
		shift
		test $# != 0 && argsRE="|$(echo "$@" | tr -s / | sed 's/ /$|/g' | sed "s,/$,," | sed 's/$/$/')"
		firstArg=$(echo "$firstArg" | tr -s /)
		test "$firstArg" != / && firstArg="$(echo "$firstArg" | sed "s,/$,,")"
		command dfc -TWfwc always | sed "s/ *$//" | \egrep "FILESYSTEM|${firstArg}\>${argsRE}"
	fi
}
function dirName {
	#NE MARCHE PAS LORSQUE LE CHEMIN NE CONTIENT PAS DE "/"
	for arg
	do
		echo ${arg%/*}
	done
}
function distribName {
	local osName=unknown
	echo $OSTYPE | grep -q android && local osFamily=Android || local osFamily=$(uname -s)

	if [ $osFamily = Linux ]; then
		if type -P lsb_release > /dev/null; then
			osName=$(lsb_release -si)
			osName=${osName,} # Converts 1st letter to lower case cf. man bash | grep -m1 -B4 -A10 ,,
			[ $osName = "n/a" ] && osName=$(source /etc/os-release && echo $ID)
		elif [ -s /etc/os-release ]; then
			osName=$(source /etc/os-release && echo $ID)
		fi
	elif [ $osFamily = Darwin ]; then
		osName="$(sw_vers -productName)"
	elif [ $osFamily = Android ]; then
		osName=Android
	else
		osName=$OSTYPE
	fi

	echo $osName | awk '{print tolower($0)}'
}
function distribType {
	local distribName=unknown
	local distribType=unknown
	echo $OSTYPE | grep -q android && local osFamily=Android || local osFamily=$(uname -s)

	distribName=$(distribName)

	if [ $osFamily = Linux ]; then
		case $distribName in
			sailfishos|rhel|fedora|centos) distribType=redhat ;;
			ubuntu) distribType=debian;;
			*) distribType=$distribName ;;
		esac
	elif [ $osFamily = Darwin ]; then
			distribType=Darwin
	elif [ $osFamily = Android ]; then
			distribType=Android
	else
		type -P bash >/dev/null 2>&1 && distribType=$(bash -c 'echo $OSTYPE') || distribType=$osFamily
	fi

	echo $distribType
}
function envSorted {
	command env "$@" | sort
}
function expandURL {
	for url
	do
		time \curl -sIL "${url}" | sed -n 's/[Ll]ocation: *//p'
	done
}
function extractURLsFromFiles {
	for file
	do
		\sed -E 's/^.*http/http/;s/[<"].*$//;/^\s*$/d;/http/!d' "$file"
	done | sort -u
}
function extractURLsFromFiles_Simplified  {
	for file
	do
		\grep -oP '(www|http:|https:)+[^\s"]+[\w]' "$file" | uniq
	done | sort -u
}
function extractURLsFromURLs {
	for url
	do
		\curl -Ls "$url" | \sed -E 's/^.*http/http/;s/[<"].*$//;/^\s*$/d;/http/!d'
	done | sort -u
}
function extractURLsFromURLs_Simplified  {
	for url
	do
		\curl -Ls "$url" | \grep -oP '(www|http:|https:)+[^\s"]+[\w]' | uniq
	done | sort -u
}
function fileTypes {
	[ $osFamily = Darwin ] && local find=gfind
	time for dir
	do
		$find $dir -xdev -ls | awk '{print substr($3,1,1)}' | sort -u
	done
}
function findSeb {
	[ $osFamily = Darwin ] && local find=gfind
	local dir=$1
	if echo $dir | \grep -q "^-"
	then
		dir=.
	else
		shift
	fi
#	firstPredicate=$1
#	shift
	local args=("$@")
	if echo "${args[@]}" | \grep -q "\-ls"
	then
		args=( "${args[@]/-ls/}" )
		$find $dir $firstPredicate ${args[@]} -printf "%10i %10k %M %n %-10u %-10g %10s %AY-%Am-%Ad %.12AX %p\n"
	else
		$find $dir $firstPredicate ${args[@]}
	fi
}
function findCorruptedFilesIn {
	local grep=$(type -P ggrep 2>/dev/null || type -P grep)
	time $grep -a -r . "$@" >/dev/null
}
function findWithHumanReadableSizes {
	[ $osFamily = Darwin ] && local find=gfind
	local dir=$1
	echo $dir | \grep -q "\-" && dir=. || shift
	local args=("$@")
	if echo "${args[@]}" | \grep -q "\-ls"
	then
		$find $dir $firstPredicate "${args[@]}" | numfmt --field 7 --from=iec --to=iec-i --suffix=B | \column -t
	else
		$find $dir $firstPredicate "${args[@]}"
	fi
}
function findLoops {
	echo $OSTYPE | \grep android -q && local osFamily=Android || local osFamily=$(uname -s)
	[ $osFamily = Darwin ] && local find=gfind
	time $find "$@" -xdev -follow -printf ""
}
function fsUsage {
	local df="command df"
    local filesytem=/
    if [ $# = 0 ];then
        filesytem=/
    elif [ $# = 1 ];then
        filesytem=$1
    fi

    $df -m $filesytem | awk '/dev/{printf "  Usage of %s: %.1f%% of %.2fGB\n", $NF, 100*$3/$2, $2/1024}'
}
function functionDefinition {
	[ $osFamily = Darwin ] && local sed="command sed -E"
	[ $osFamily = Linux ]  && local sed="command sed -r"
	type "$@" | \grep -v 'is a function$' | $sed 's/(;| )$//;s/    /\t/g'
}
function gdebiALL {
	for package
	do
		sudo gdebi -n $package
	done
}
function getBJC {
	#bjcUrl=http://www.bibledejesuschrist.org/downloads/bjc_internet.pdf
	bjcUrl=http://www.bibledejesuschrist.org/downloads/bjc.pdf
	extension=${bjcUrl/*./}
	bjcBaseName=$(basename $bjcUrl .$extension)
	echo "=> Downloading last BJC version ..."
	wget $bjcUrl
	\mv -v $bjcBaseName.$extension "${bjcBaseName}_$(date -d "$(stat -c %y $bjcBaseName.$extension)" +%Y%m%d_%HH%MM%S).$extension"
}
function getCodeName {
	if [ $# != 2 ];then
		echo "=> Usage: $FUNCNAME brand model" >&2
		return 1
	fi

	local brand=$1
	local model=$2
	local curl="command curl -sL"
	local codeNameJSONDataBaseURL=https://github.com/jaredrummler/AndroidDeviceNames/raw/master/json/manufacturers

	if $curl -I $codeNameJSONDataBaseURL/$brand.json | \grep "Not Found";then
		echo "[$FUNCNAME] => ERROR : The page $codeNameJSONDataBaseURL/$brand.json was not found." >&2
		return 2
	fi

	$curl $codeNameJSONDataBaseURL/$brand.json | jq -r --arg model $model '.devices[] | select( .model | match($model;"i") ).codename'
}
function getField {
	test $# -ne 3 && {
		echo "=> ERROR on Usage: $FUNCNAME separator1 separator2 fieldNumber" >&2
		return 1
	}
	local sep1="$1"
	local sep2="$2"
	declare -i fieldNumber=$3
	awk -F "${sep1}|$sep2" "{print\$$fieldNumber}"
}
function getFiles {
	test $# -lt 2 && {
		echo "=> Usage: $FUNCNAME <wget args> URL" >&2
		return 1
	}

	local lastArg="$(eval echo \${$#})"
	local baseUrl=$(echo $url | awk -F/ '{print$3}')
	local wget="command wget"
	local url=$lastArg

	echo $url | egrep "^(https?|ftp)://" || {
		echo "=> ERROR: This protocol is not supported by GNU Wget." >&2
		return 2
	}

#	time $wget --no-parent --continue --timestamping --random-wait --user-agent=Mozilla --content-disposition --convert-links --page-requisites --recursive --reject index.html --accept "$@"
	set -x
	time $wget --no-parent --continue --timestamping --random-wait --user-agent=Mozilla --content-disposition --convert-links --page-requisites --recursive --accept "$@"
	set +x
}
function getPythonFunctionName {
	local funcName=$1
	shift
	test $# != 0 && grepParagraph "def $funcName " '^$' $@
}
function getPythonFunctions {
	test $# != 0 && grepParagraph "def " '^$' $@
}
function getShellFunctionName {
	local funcName=$1
	shift
	test $# != 0 && grepParagraph "(^|\s)$funcName\s*\(\)|\bfunction\s$funcName" '^}' $@
}
function getShellFunctions {
	test $# != 0 && grepParagraph '(^|\s)\w+\(\)|\bfunction\b' '^}' $@
}
function getURLTitle {
	for url
	do
		printf "$url # " >&2
		if type -P xidel >/dev/null;then
			xidel -s --css 'head title' "$url"
		elif type -P pup >/dev/null;then
			\curl -Ls "$url" | pup --charset utf8 'head title text{}'
		fi
	done
}
function getVideosFromRSSPodCastPlayList {
	test $# = 1 && {
		local rssURL="$1"
		local wget="$(type -P wget2 2>/dev/null || type -P wget)"
#		$wget $(youtube-dl -g "$rssURL")
		$wget $(curl -s "$rssURL" | egrep -o "https?:[^ <>]*(mp4|webm)" | grep -v .google.com/ | uniq)
	}
}
function gpg2asc {
	for gpgFile
	do
		\gpg -o - --enarmor "$gpgFile" | sed "s/ARMORED FILE/PUBLIC KEY BLOCK/" | tee "${gpgFile/.gpg/.asc}"
	done
}
function gpgPrint {
	for pubKey
	do
		echo $pubKey
		printf -- "-%.s" $(seq ${#pubKey})
		echo
		\gpg $pubKey | awk '{printf$1"   "$2" "$3"\n""uid\t\t  ";$1=$2=$3="";print}'
		echo
	done
}
function grepdoc {
	local pattern="$1"
	shift
	for doc
	do
		catdoc "$doc" | egrep -H --label="$doc" -i "${pattern}"
	done
}
function grepFunction {
	test $# -lt 2 && {
		echo "=> Usage : $FUNCNAME startRegExpPattern fileList" >&2
		return 1
	}
	echo $1 | grep -q -- "^-[a-z]" && local option=$1 && shift
	local startRegExpPattern=$1
	shift
	grepParagraph $option "function $startRegExpPattern|${startRegExpPattern}.*[(]" "^}" "$@"
}
function grepParagraph {
set +x
	local fileListPattern="-"
	test $# -lt 2 && {
		echo "=> Usage : $FUNCNAME [-h|-l] startRegExpPattern endRegExpPattern [fileList]" >&2
		return 1
	}
	test $# = 2 && {
		echo "=> Calling $FUNCNAME through pipe is not yes implemented. " >&2
		return 2
	}

	echo $1 | grep -q -- "^-[a-z]" && local option=$1 && shift

	fileListPattern="${@:3}"
	local startRegExpPattern
	local endRegExpPattern

#	startRegExp=$1 endRegExp=$2 \sed -E -n "/$startRegExpPattern/,/$endRegExpPattern/p" $fileListPattern
#	startRegExp=$1 endRegExp=$2 awk "/$startRegExpPattern/{p=1}p;/$endRegExpPattern/{p=0}" $fileListPattern

	case $option in
		-h) startRegExp=$1 endRegExp=$2 perl -ne 'print "$_" if /$ENV{startRegExp}/ ... (/$ENV{endRegExp}/ || eof)' $fileListPattern
		;;
		-l) startRegExp=$1 endRegExp=$2 perl -ne 'print "$ARGV\n" if /$ENV{startRegExp}/ ... (/$ENV{endRegExp}/ || eof)' $fileListPattern | uniq
		;;
		*) startRegExp=$1 endRegExp=$2 perl -ne 'print "$ARGV:$_" if /$ENV{startRegExp}/ ... (/$ENV{endRegExp}/ || eof)' $fileListPattern
		;;
	esac
}
function grepSection {
	test $# -lt 2 && {
		echo "=> Usage : $FUNCNAME startRegExpPattern fileList" >&2
		return 1
	}
	echo $1 | grep -q -- "^-[a-z]" && local option=$1 && shift
	local startRegExpPattern=$1
	shift
	grepParagraph $option "$startRegExpPattern" "^$" "$@"
}
function greplast {
	grep "$@" | awk 'END{print}'
}
function h5L {
	local switch="$1"
	echo $switch | \grep -q "^-" && shift 1 || switch=""
	for file
	do
		\h5ls -r $switch $file
	done | \egrep "Group|Attribute:|Dataset|Data:"
}
function help {
	local help="builtin help"
	local lines=$($help "$@" | wc -l)
	local termLines=$(tput lines)
	[ $lines -gt $termLines ] && $help "$@" | less || $help "$@"
}
function hide {
	for file
	do
		mv $file .$file
	done
}
function html2pdf {
	test $# = 0 && {
		echo "=> Usage: $FUNCNAME url_or_file1 url_or_file1 ..." >&2
		return 1
	}

	if ! type -P wkhtmltopdf >/dev/null 2>&1;then
		echo "=> ERROR[$FUNCNAME]: You need to install the <wkhtmltopdf> tool." >&2
		return 2
	fi

	local pdfFiles=""
	local pageSize=$(paperconf)
	for url_or_file
	do
		pdfFileName=$(basename $url_or_file | \sed -E "s/#.*|[)]//;s/%20|[(]/_/g;s/$|\.[^.]+$/.pdf/")
		pdfFiles+="$pdfFileName "
		wkhtmltopdf --page-size $pageSize --minimum-font-size 12 --no-background --outline --header-line --footer-line --header-left [webpage] --footer-left "[isodate] [time]" --footer-right [page]/[toPage] "$url_or_file" "$pdfFileName"
	done

	echo
	echo "=> OutputFile = $pdfFileName"
	echo
	open $pdfFiles
}
function htmlReIndent {
	test $# = 1 && [ $1 = - ] && xmllint --html --format - && return
	for file
	do
		xmllint --html --format "$file" 2>/dev/null > "${file/.*/.indented.html}"
		[ $? != 0 ] && echo "=> WARNING: xmllint could not re-indent $file." >&2 && continue
		\mv -v "${file/.*/.indented.html}".indented "$file"
	done | sort -u
}
function httpLocalServer {
#	local fqdn=$(host $(hostname) | awk '/address/{print$1}')
#	local fqdn=$(\dig +short -x $(\dig +search +short $(hostname)))
	local fqdn=localhost
	local ip=$(\dig -x +search +short $(hostname))
	local -i port=1234
	local python="command python"

	case $1 in
		-h|-help|--h|--help) echo "=> Usage: $FUNCNAME [portNumber|$port]" >&2; return 1 ;;
	esac

	test $1 && port=$1
	if [ $port -lt 1024 ] && [ $UID != 0 ]; then
		echo "=> ERROR: Only root can bind to a tcp port lower than 1024." >&2
		return 2
	fi

	local pythonVersion="$($python -V 2>&1 | sed 's/[A-Za-z]* //' | cut -d. -f1)"
	case $pythonVersion in
		2) SimpleHTTPServerModuleName=SimpleHTTPServer;;
		3) SimpleHTTPServerModuleName=http.server;;
	esac

	local oldPort=$(\ps -fu $USER | \grep -v awk | awk "/$SimpleHTTPServerModuleName/"'{print$NF}')
	\ps -fu $USER | \grep -v grep | \grep -q $SimpleHTTPServerModuleName && echo "=> $SimpleHTTPServerModuleName is already running on http://$fqdn:$oldPort/" || {
		logfilePrefix=$SimpleHTTPServerModuleName_$(date +%Y%m%d)
		mkdir -p ~/log
		nohup $python -m $SimpleHTTPServerModuleName $port >~/log/${logfilePrefix}.log 2>&1 &
		test $? = 0 && {
			echo "=> $SimpleHTTPServerModuleName started on http://$ip:$port/" >&2
			echo "=> logFile = ~/log/${logfilePrefix}.log" >&2
		}
	}
}
function img2pdfA4 {
	local lastArg="${@: -1}"
	local allArgsButLast="${@:1:$#-1}"
	img2pdf --pagesize A4 $allArgsButLast -o $lastArg
}
function img2pdfA4R {
	local lastArg="${@: -1}"
	local allArgsButLast="${@:1:$#-1}"
	img2pdf --pagesize A4^T $allArgsButLast -o $lastArg
}
function installDate {
	local distribType=$(distribType)
	case $distribType in
		debian|ubuntu) \ls -lact --full-time /etc | awk 'END {print $6,substr($7,1,8)}' ;;
		mer|redhat) \rpm -q basesystem --qf '%{installtime:date}\n' ;;
		darwin15*) \ls -lactL -T /etc | awk 'END {print $6,$7,$8}' ;;
		*)	;;
	esac
}
function isbn2Barcode_with_barcode {
	local string="" stringLength=0
	if [ $# = 1 ]; then
		string="$1"
		stringLength="${#string}"
		if [ $stringLength = 10 ];then
			barcode -e isbn -S -b "$string" | mogrify -format png -resize 200% - | feh -
		elif [ $stringLength = 13 ];then
			barcode -e ean-13 -S -b "$string" | mogrify -format png -resize 200% - | feh -
		fi
	fi
}
function isbn2Barcode_with_zint {
	local string=""
	if [ $# = 1 ]; then
		string="$1"
		zint -b ISBNX --scale 2 --direct -d "$string" | feh -
	fi
}
function isPrivateIP {
	for IP
	do
		python3 -c "import ipaddress;print('$IP is private') if ipaddress.ip_address('$IP').is_private else print('$IP is public')"
	done
}
function isPublicIP {
	for IP
	do
		python3 -c "import ipaddress;print('$IP is public') if not ipaddress.ip_address('$IP').is_private else print('$IP is private')"
	done
}
function jpgRotate {
	test $# = 0 && {
		echo "=> Usage: $FUNCNAME angle file1 file2 file3 ..." >&2
		return 1
	}

	local angle=$1
	shift
	for pic
	do
		extension="${pic/*./}"
		newFile="${pic/.$extension/_ROTATED.$extension}"
		echo "=> Losslessly rotating $pic by $angle degrees into $newFile ..." >&2
		jpegtran -perfect -rotate $angle "$pic" > "$newFile"
		touch -r "$pic" "$newFile"
	done
}
function jupyterToken {
	jupyter notebook list
	local token
	if jupyter notebook list | \grep -wq token
	then
		token=$(jupyter notebook list | awk -F '[= ]' '/token=/{token=$2}END{print token}')
	else
		\pgrep -f jupyter-notebook >/dev/null && token=$(awk -F '[=&]' '/token=/{token=$2}END{print token}' nohup.out)
	fi
	test -n "$token" && echo "=> token = $token"
}
function latexBuild {
	local outPutDIR=tmp
	mkdir -pv $outPutDIR
	for file
	do
		\texfot pdflatex --shell-escape --output-directory $outPutDIR "$file" && open $outPutDIR/${file/tex/pdf}
	done
}
function ldapUserFind {
	if type -P ldapsearch >/dev/null 2>&1
	then
		ldapsearch -x -LLL uid=$1
	fi
}
function listVideosFromRSSPodCastPlayList {
	test $# = 1 && {
		local rssURL="$1"
		local wget="$(type -P wget2 2>/dev/null || type -P wget)"
#		echo $(youtube-dl -g "$rssURL")
		echo $(curl -s "$rssURL" | egrep -o "https?:[^ <>]*(mp4|webm)" | grep -v .google.com/ | uniq)
	}
}
function locateBin {
	local regExp="$1"
	shift
	locate "bin/.*$regExp" "$@"
}
function locateFromHere {
	local regExp="$1"
	shift
	locate "^$PWD/.*$regExp" "$@" | sed "s|$PWD.||"
}
function locateFromHome {
	local regExp="$1"
	shift
	locate "^$HOME/.*$regExp" "$@" | sed "s|$HOME.||"
}
function lprColorPageRange {
	test -n "$colorPrinter" && test $colorPrinter && lprPageRange $@ -P $colorPrinter
}
function lprPageRange {
	test $# -lt 2 && {
		echo "=> Usage: $FUNCNAME pageRange pdf/psFile" >&2
		return 1
	}

	pageRange=$1
	shift
	test $pageRange && echo $pageRange | grep -ivq "[A-Z]" && command lpr -o page-ranges=$pageRange $@ && lpq
}
function listPackageContents {
	package=${1/:/}
	case "$(packageManager)" in
		rpm) packageContents="rpm -ql";;
		deb) packageContents="dpkg -L";;
	esac
	$packageContents $package
}
function lsbin {
	for package
	do
		listPackageContents $package
	done | sort -u | grep bin/
}
function lsconf {
	for package
	do
		listPackageContents $package
	done | sort -u | grep etc/
}
function lsdesktopfiles {
	for package
	do
		listPackageContents $package
	done | sort -u | grep "\.desktop$"
}
function lsdoc {
	for package
	do
		listPackageContents $package
	done | sort -u | egrep "(doc|man[0-9]?)/"
}
function lsicons {
	for package
	do
		listPackageContents $package
	done | sort -u | egrep "(jpg|svg|png)$"
}
function lslib {
	for package
	do
		listPackageContents $package
	done | sort -u | egrep "(\.so)"
}
function lv_Dev_Creation_Date {
	sudo -v
	for lv
	do
		sudo lvdisplay
	done | egrep "LV Path|Creation"
}
function lv_FS_Creation_Date {
	sudo -v
	for fs
	do
		sudo lvdisplay $(lvm_Mount_Point_2_LVM_Paths $fs)
	done | egrep "LV Path|Creation"
}
function lvm_DM_Paths_2_LVM_Paths {
	for dmPath
	do
		\lsblk -nf $dmPath | awk '{print"/dev/mapper/"$1}'
	done
}
function lvm_Mount_Point_2_LVM_Paths {
	local dmPath
	for fs
	do
		dmPath=$(\df $fs | awk "$fs/"'{print$1}')
		\lsblk -nf $dmPath | awk '{print"/dev/mapper/"$1}'
	done
}
function memUsageOfProcessName {
	local ps="command ps"
	for processName
	do
		if \pgrep $processName >/dev/null;then
			printf "=> $processName: "
			type -P smem >/dev/null && echo && smem -P $processName -t -c "swap rss uss pss" -k | \sed -n '1p;$p' || $ps -o rss= -C $processName | LC_ALL=C numfmt --from-unit=1K --from=iec | paste -sd+ | bc | numfmt --to=iec-i
		fi
	done
}
function memUsageOfProcessRegExp {
	local ps="command ps"
	for processRegExp
	do
		if \pgrep $processRegExp >/dev/null;then
			printf "=> $processRegExp: "
			type -P smem >/dev/null && echo && smem -P $processRegExp -t -c "swap rss uss pss" -k | \sed -n '1p;$p' || $ps -o rss= -p $(\pgrep $processRegExp) | LC_ALL=C numfmt --from-unit=1K --from=iec | paste -sd+ | bc | numfmt --to=iec-i
		fi
	done
}
function mkdircd {
	\mkdir -pv $1
	cd $1 && pwd -P
}
function mkdirSeb {
	local dir
	for dir
	do
		dir="${dir// /_}"
		mkdir "$dir"
	done
}
function monitorInfo {
	if [ -z "$SSH_CONNECTION" ];then
		\xrandr --props | edid-decode | egrep 'Manufacturer:|Product|Alphanumeric'
	else
		echo "=> You cannot use <$FUNCNAME> through SSH." >&2
		return 1
	fi
}
function mountISO {
	loopBackDevice=$(udisksctl loop-setup -r -f "$1" | awk -F "[ .]" '{print$(NF-1)}')
	udisksctl mount -b $loopBackDevice
}
function mountLVM {
	local LV="$1"
	local mountPount=$(basename $(echo $LV  | cut -d- -f2-))
	shift
	sudo mkdir /mnt/$mountPount
	sudo findmnt /mnt/$mountPount && echo "=> There is already a mounted filesystem here !" >&2 && return 1
	sudo mount -v $LV /mnt/$mountPount
}
function myUnlink {
	for file
	do
		unlink $file
	done
}
function mysqlplus {
	if test $TNS_ADMIN
	then
		echo "=> Connecting to database <$ORACLE_SID> as <$USER> ..."
		sqlplus $USER $@
	else
		echo "=> ERROR: Variable TNS_ADMIN is not defined." >&2
	fi
}
function nbPages {
	for file
	do
		printf "$file:Pages: "
		pdfinfo $file | awk '/Pages:/{print$NF}'
	done | awk '/Pages:/{nbPages+=$NF;print}END{print "=> Total: " nbPages}'
}
function numberSmallerEqual {
	number1=$1
	number2=$2
#	return $( awk "BEGIN{ exit(! ( $number1 <= $number2 ) ) }" )
	return $( perl -e "exit(! ( $number1 <= $number2 ) )" )
}
function odf2 {
	formats="pdf|doc|docx|odt|odp|ods|ppt|pptx|xls|xlsx"
	test $# -lt 2 && {
		echo "=> Usage: $FUNCNAME $formats file1 [file2] [file3] ..." >&2
		return 1
	}

	format=$1; shift
	case $format in
#		"$formats") ;;
		pdf|doc|docx|odt|odp|ods|ppt|pptx|xls|xlsx) ;;
		*) echo "=> Cannot convert to the <$format> format." >&2; return 2 ;;
	esac

	for file
	do
		extension=${file/*./}
		ls $file >/dev/null && {
			echo "loffice --headless --convert-to $format $file ..."
			command loffice --headless --convert-to $format $file
			\ls -l ${file/$extension/$format}
		}
	done
}
function odfInfo {
	for document
	do
		\unzip -c $document meta.xml | tr -s " " "\n" | fmt
	done
}
function os {
	local os=not_yet_defined
	case $osFamily in
		Darwin)
			sw_vers >/dev/null 2>&1 && os="$($(sw_vers -productName) $(sw_vers -productVersion))" || os=$(system_profiler SPSoftwareDataType) || os=$(defaults read /System/Library/CoreServices/SystemVersion ProductVersion) ;;
		Linux)
			if [ -s /etc/os-release ]; then
				source /etc/os-release && os=$PRETTY_NAME
			elif type -P lsb_release >/dev/null 2>&1; then
				os=$(\lsb_release -scd | paste -sd" ")
			else
				os=$(\sed -n 's/\\[nl]//g;1p' /etc/issue)
			fi
			;;
		Android) type -P getprop >/dev/null && os="Android $(getprop ro.build.version.release)" || os=unknown ;;
		*) os=unknown ;;
	esac
	echo $os
}
function osSize {
	#La partition swap n'est pas prise en compte pour le moment
	LC_NUMERIC=C
	local df="command df"
	echo $OSTYPE | grep -q android && export osFamily=Android || export osFamily=$(uname -s)
	if [ $osFamily = Linux ];then
		time $df -T | awk 'BEGIN{printf "df -T "} !/tmpfs/ && /\/$|boot$|opt|tmp$|usr|var/{printf $NF" "}' | sh -x | awk '{total+=$4}END{print total/1024^2" GiB"}'
		echo
		time $df -T | awk 'BEGIN{printf "sudo du -cxsk "} !/tmpfs/ && /\/$|boot$|opt|tmp$|usr|var/{printf $NF" "}' | sh -x | awk '/[\t ]+total$/{print$1/1024^2" GiB"}'
	else
		echo "=> [${0/*\//}] ERROR : $osFamily is not supported yet." >&2
	fi
}
function packageManager {
	local pkgManager
	case $(distribType) in
		debian) pkgManager="deb";;
		redhat) pkgManager="rpm";;
		Darwin) type -P brew >/dev/null 2>&1 && pkgManager="brew";;
		*)
			local pkgTools=$(type -P dpkg rpm 2>/dev/null | awk -F/ '{print$NF}')
			for pkgTool in $pkgTools
			do
				case $pkgTool in
					dpkg) pkgManager="deb";;
					rpm) pkgManager="rpm";;
					*) pkgManager=unknown;;
				esac
			done
			;;
	esac
	echo $pkgManager
}
function pdf2jpg {
	local pageRage=all
	local pdfFileName=unset
	local imageFileNamePrefix=unset

	if [ $# = 0 ] || [ "$1" = -h ];then
		echo "=> INFO: Usage : $FUNCNAME [pageRage] pdfFileName [imageFileNamePrefix]"
		return 1
	fi

	if [ $# = 1 ];then
		pdfFileName="$1"
		imageFileNamePrefix="${pdfFileName%.*}-%02d"
	elif [ $# = 2 ];then
		pageRage="$1"
		pdfFileName="$2"
		imageFileNamePrefix="${pdfFileName%.*}-%02d"
	elif [ $# = 2 ];then
		pageRage="$1"
		pdfFileName="$2"
		imageFileNamePrefix="$3"
	fi

	if [ $pageRage = all ];then
		convert "$pdfFileName" "${imageFileNamePrefix}.jpg"
	else
		convert "${pdfFileName}[$pageRage]" "${imageFileNamePrefix}.jpg"
	fi

	return
}
function pdfAutoRotate {
	for file
	do
		output="${file/.pdf/-ROTATED.pdf}"
		time \gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/All -sOutputFile="$output" "$file"
		echo
		echo "=> $output"
		echo
	done
}
function pdfCompress_pdftk {
	for pdf
	do
		if \ls "$pdf" >/dev/null;then
			echo "=> Compressing $pdf ..."
			outputFile="${pdf/.pdf/-SMALLER_pdftk.pdf}"
			time \pdftk "$pdf" output "$outputFile" compress
			echo
			du -h "$pdf" "$outputFile"
			fi
		echo
	done
}
function pdfCompress_ps2pdf {
	trap 'echo "=> $FUNCNAME: CTRL+C Interruption trapped.">&2;' INT
	for pdf
	do
		if \ls "$pdf" >/dev/null;then
			echo "=> Compressing $pdf ..."
			outputFile="${pdf/.pdf/-SMALLER_ps2pdf.pdf}"
			time \ps2pdf -dPDFSETTINGS=/ebook "$pdf" "$outputFile" 2>&1 | uniq
			echo
			du -h "$pdf" "$outputFile"
		fi
		echo
	done
	trap - INT
}
function pdfConcat {
	test $# -lt 2 && {
		echo "=> Usage : $FUNCNAME <file1.pdf> <file2.pdf> ... <outputFile.pdf>" >&2
		return 1
	}
	test "$1" && {
		local lastArg="$(eval echo \${$#})"
		local allArgsButLast="${@:1:$#-1}"
		time gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile="$lastArg" $allArgsButLast && open "$lastArg" || time pdfjoin --rotateoversize false $allArgsButLast -o $lastArg || time pdftk $allArgsButLast cat output $lastArg verbose
	}
}
function pdfDPI {
	for pdfFile
	do
		if \ls "$pdfFile" >/dev/null;then
			echo "=> pdfFile = $pdfFile" >&2
			time identify -format "%x x %y\n" "$pdfFile" 2>&1 | uniq
		fi
		echo
	done
}
function pdfInfo {
	for pdfFile
	do
		if \ls "$pdfFile" >/dev/null;then
			echo "=> pdfFile = $pdfFile" >&2
			pdfinfo "$pdfFile"
		fi
		echo
	done
}
function pdfSelect {
	input="$1"
	pages=$2
	output="$3"
	test $# != 3 && {
		echo "=> Usage : $FUNCNAME <inputFile> <pageRanges> <outputFile>" >&2
		return 1
	}
	time \pdfjam --fitpaper true --keepinfo "$input" $pages -o "$output"
	open "$output"
}
function perlCalc {
	set -- ${@/^/**}
	set -- ${@/[/(}
	set -- ${@/]/)}
	\perl -le "print $*"
}
function perlgrep {
	local pattern="$1"
	\perl -ne "print grep /$pattern/ip,\$_"
}
function perlGrep {
	local regExp
	local perlOpts="-lne"
	local perlOutputVar='"$_"'
	local perlSetColorCode=""
	local perlUses="use Term::ANSIColor;"

	if [ $# != 1 ]
	then
		regExp="$2"
		if echo $1 | grep -q -- "^-";then
			firstOption=$1
			case $firstOption in
				-w) regExp="\b${regExp}\b";;
				-o) perlOutputVar='"$&"';;
				--color*) perlSetColorCode='print color("blue");';perlResetColor='print color("reset");';;
			esac
		fi
		regExp="/${regExp}/p"
		if echo $1 | grep -q -- "^-";then
			firstOption=$1
			case $firstOption in
				-i) regExp+="i";;
			esac
		fi
	else
		regExp="/$1/"
	fi

	[ "$firstOption" != -o ] && [ "$firstOption" = --color ] && set -x && perlOutputVar='"$PREMATCH$perlSetColorCode$&$perlResetColor$POSTMATCH"' && set +x

	\perl "$perlOpts" "$perlUses"'print '"$perlOutputVar"' if '"$regExp;$perlResetColor"
set +x
}
function picMpixels {
	for fileName
	do
		LC_NUMERIC=C \perl -le "printf \"=> fileName = %s size = %.2f Mpix\n\", \"$fileName\", $(identify -format '%w*%h/10**6' $fileName)"
	done | \column -t
}
function pingMyLAN {
	local myOutgoingInterFace=$(ip route | awk '/default/{print$5}')
	local myLAN=$(\ip -4 addr show dev $myOutgoingInterFace scope global up | awk '/inet/{print$2}')
	local fping=$(type -P fping)
	if [ $# = 0 ];then
		if [ -n "$fping" ];then
			getcap $fping | \grep -q cap_net_raw+ep || sudo setcap cap_net_raw+ep $fping
			time $fping -r 0 -aAg $myLAN 2>/dev/null | sort -uV
		else
			time \nmap -T5 -sP $myLAN | sed -n '/Nmap scan report for /s/Nmap scan report for //p'
		fi
	elif [ $# = 1 ];then
		port=$1
		if type -P fping >/dev/null 2>&1;then
			time \nmap -T5 -sP $myLAN | sed -n '/Nmap scan report for /s/Nmap scan report for //p' | while read ip
			do
				tcpConnetTest $ip $port
			done
		fi
	fi
}
function pingSeb {
	time ping "$@" | \egrep -m1 "ttl=[0-9]+\stime=[0-9.]+\sms|errors"
}
function pip {
	local caller=${FUNCNAME[1]}
	test $caller || caller="pip"
	if type -P $caller >/dev/null;then
		local callerCmd="command $caller"
		local callerPath="$(type -P $caller)"
	else
		echo "=> $0: ERROR $caller is not installed" >&2
		return 1
	fi

	firstArg=$1
	if [ "$firstArg" = install ];then
		if $isSudoer;then
			$sudo -H $callerPath $@
		else
			$callerCmd $@ --user
		fi
	elif [ "$firstArg" = uninstall ];then
		if $isSudoer;then
			$sudo -H $callerPath $@
		else
			$callerCmd $@
		fi
	elif [ "$firstArg" = search ];then
		$callerCmd $@ | sort
	else
		$callerCmd $@
	fi
}
function pip2 {
	type -P pip2 >/dev/null || { echo "-$0: pip2: command not found">&2;return 1; }
	pip $@
}
function pip3 {
	type -P pip3 >/dev/null || { echo "-$0: pip3: command not found">&2;return 1; }
	pip $@
}
function piphelp {
	local pip="command pip"
	test -n "$pip" && $pip help $1 | \less
}
function pkill {
	local firstArg=$1
	local pkill="command pkill"
	local echoOption

	case $osFamily in
		Linux) echoOption="-e";;
		Darwin) echoOption="-l";;
		*) echoOption="";;
	esac

	if [ $# != 0 ]; then
		firstArg="$1"
		if echo $firstArg | \grep -q -- "-[0-9]"
		then
			shift
			processName="$1"
			test -n "$processName" && $pkill $firstArg $echoOption -fu $USER "$@"
		else
			processName="$1"
			test -n "$processName" && $pkill $echoOption -fu $USER "$@"
		fi
	else
		$pkill
	fi
}
function printLastLines {
	local pattern=to_be_defined
	local remoteTZ
	if [ $# = 0 ];then
		echo "=> Usage : $FUNCNAME pattern file" >&2
		return 1
	elif [ $# = 1 ];then
		case $1 in
			-h|--h|-help|--help) echo "=> Usage : $FUNCNAME pattern file" >&2;return 1;;
		esac
	else
		pattern="$1"
		file="$2"
	fi

	tac "$file" | sed "/$pattern/q" | tac
}
function printrv {
	[ $# = 0 ] && {
		echo "=> Print odd pages in reverse order : $FUNCNAME document"
		return 1
	}

	lp -o page-set=odd -o outputorder=reverse $1
	echo "=> Press enter once you have flipped the pages in the printer ..."
	read
	lp -o page-set=even $1
}
function processSPY {
	watchProcess $@
}
function processUsage {
	local columns="rssize,user:12,pmem,pcpu,pid,args"
	local ps="command ps"
#	local headers=$($ps -e -o $columns | grep -v grep.*COMMAND | \grep COMMAND)
	local headers=" RSS\t       USER %MEM %CPU  PID   COMMAND"
	echo -e "$headers" >&2
	# "tail -n +1" ignores the SIGPIPE
	$ps -e -o $columns | sort -nr | cut -c-156 | head -500 | awk '!/COMMAND/{printf "%9.3lf MiB %12s %4.1f%% %4.1f%% %5d %s\n", $1/1024,$2,$3,$4,$5,$6}' | tail -n +1 | head -45
}
function psSeb { # Les fontions qui avaient le meme nom que les commands sont exportes et visibles dans les bash, c_est dangereux
	local ps="command ps"
	local firstArg=$1
#	local args=("$@")
	if [ $# = 0 ];then
		$ps | head -1 >&2 # Redirect headers to stderr
		$ps h 
	elif echo $firstArg | \grep -q -- "^-";then
		if echo "$@" | \grep -q -- "-o";then
			$ps "${@//=/}" | \egrep -w 'PID|TTY|TIME|CMD' >&2 # Get headers and redirects them to stderr
			$ps h "$@"
		else
			$ps -f "${@//=/}" | \egrep -w 'PID|TTY|TIME|CMD' >&2 # Get headers and redirects them to stderr
			$ps h -f "$@"
		fi
	else 
		$ps "${@//=/}" | \egrep -w 'PID|TTY|TIME|CMD' >&2 # Get headers and redirects them to stderr
		$ps h "$@"
	fi   
}
function pythonCalc {
	\python -c "print(${*/^/**})"
}
function randomN {
	test $# -gt 1 || test "$1" = "-h" && {
		echo "=> Usage: $FUNCNAME [N=100]" >&2
		return 1
	}
	[ $# = 1 ] && local N=$1 || local N=100
	local b=$((2**15-1))
	test "$N" -gt $b && {
		echo "=> [$FUNCNAME] ERROR: N must be lower than 2^15" >&2
		echo 0 # Workaround for the "sleepRandomMinutes" function when not trapping $?
		return 2
	}
	local n=$RANDOM
	echo $((N*n/b))
}
function realpathSeb {
	for path
	do
		while [ -L "${path}" ]
		do
			path="$(\ls -l "${path}" | awk '{print $NF}')"
		done
		type -P "${path}"
	done
}
function reload_SHELL_Functions_And_Aliases {
#	for script in ~/.${0}rc $initDir/.*functions $initDir/.*aliases $initDir/.*aliases.$osFamily
	for script in $initDir/.bashrc.$osFamily $initDir/.*functions $initDir/.*functions.$osFamily $initDir/.*aliases $initDir/.*aliases.$osFamily
	do
		source $script
	done
}
function renameExtension { test $# = 2 && shopt -s globstar && for f in **/*.$1; do /bin/mv -vi "$f" "${f/.$1/.$2}"; done; }
function renameFileInsideZIP {
	test $# -lt 3 && {
		echo "=> Usage: $FUNCNAME oldName newName zipFile" >&2
		return 1
	}
	local lastArg="$(eval echo \${$#})"
	local zipFile=$lastArg
	local oldName=$1
	local newName=$2
#	command printf "@ $oldName\n@=$newName\n" | command zipnote -w $zipFile #necessite zip > v3.1beta
	command 7za $zipFile $oldName $newName
}
function resetRESOLUTION {
	\xrandr | awk '{if(/\<connected/)output=$1;if(/\*/){print"xrandr --output "output" --mode "$1;exit}}' | sh -x
}
function resizePics {
	local defaultWidth=1024
	local defaultHeight=768
	local width=-1 height=-1

	if echo $1 | \egrep -q "^[0-9]+$";then
		width=$1
		shift
		height=$(awk "BEGIN{print $width*768/1024}")
	else
		width=$defaultWidth
		height=$defaultHeight
	fi

	local format="${width}x${height}"
	for src
	do
		ext=$(echo "$src" | awk -F. '{print$NF}')
		dst="${src/.$ext/-SMALLER}.$ext"
		convert -verbose -resize "${format}>" "$src" "$dst"
		touch -r "$src" "$dst"
		exiftran -gpi "$dst"
	done
}
function resizePics_1536 {
	resizePics 1536 "$@"
}
function resizePics_2048 {
	resizePics 2048 "$@"
}
function resizePics_3072 {
	resizePics 3072 "$@"
}
function resizePics_4096 {
	resizePics 4096 "$@"
}
function restart_conky {
	for server
	do
		ssh $server "pgrep conky && killall -SIGUSR1 conky || conky -d"
	done
	\pgrep conky && \killall -SIGUSR1 conky || conky -d
}
function rmEmptyFile {
	for file
	do
		test -f "$file" && ! test -s "$file" && \rm -v "$file"
	done
}
function rsyncIncludeOnly {
	local destination="$(eval echo \$$#)"
	local rsyncCommandSuffix="--include='*/' --exclude='*'"
	local rsyncCommand="command rsync -r -uth -P -z"

	for arg
	do
		[ "$arg" = $destination ] && break
		if echo "$arg" | grep -q '*'
		then
			rsyncCommand="$rsyncCommand --include=\"$arg\""
		else
			rsyncCommand="$rsyncCommand $arg"
		fi
	done
set +x
	echo "=> INFO: Running: $rsyncCommand $rsyncCommandSuffix $destination" >&2
	time $rsyncCommand $rsyncCommandSuffix $destination;
	echo "=> Syncing disks ..."
	time sync
}
function rtt {
	local remote=$1
	test -z $remote && {
		echo "=> Usage: roundTripTime remote" >&2
		return 1
	}
	local NBPackets=10
	local interval=0.2
	local deadline
	local ping="command ping"
	local awk="command awk"
	[ $osFamily = Darwin ] && deadline="-t 5"
	[ $osFamily = Linux ]  && deadline="-w 5"
	$ping -c $NBPackets $deadline -i $interval $remote | $awk -F/ '//{print}/min\/avg\/max\/\w+dev/{avg=$5}END{print "=> avg = "avg" ms"}'
}
function setTimestamps {
	for file
	do
		timestamp=$(echo "$file" | sed -r 's/[a-zA-Z._-]*//g;s/([0-9]{12})([0-9]{2})/\1.\2/')
		nbChars=${#timestamp}
		[ $nbChars = 12 ] && timestamp=${timestamp}.00
		touch -t $timestamp "$file"
	done
}
function sizeOfLocalFiles {
	local size
	local totalExpr="0"
	for file
	do
		size=$(\stat -c %s "$file" | awk '{print$2/2^20}')
		totalExpr="$totalExpr+$size"
		echo "$url $size Mo"
	done
	total=$(perl -e "printf $totalExpr")
	echo "=> total = $total Mo"
}
function sizeOfRemoteFile {
	trap 'rc=$?;set +x;echo "=> $FUNCNAME: CTRL+C Interruption trapped.">&2;return $rc' INT

	local size
	local totalExpr="0"
	local format=18
	echo $1 | \grep -q ^http || {
		format=$1
		shift
	}
	for url
	do
		size=$(\curl -sI "$url" | \sed "s/\r//g" | awk 'BEGIN{IGNORECASE=1}/Content-?Length:/{print$2/2^20}')
		totalExpr="$totalExpr+$size"
		echo "$url $size Mo"
	done
	total=$(perl -e "printf $totalExpr")
	echo "=> total = $total Mo"
 
	trap - INT
}
function sleepRandomMinutes {
	test $# -gt 1 || test "$1" = "-h" && {
		echo "=> Usage: $FUNCNAME [N=10]" >&2
		return 1
	}
	[ $# = 1 ] && local N=$1 || local N=10
	local random=$(randomN $N)
	[ $? = 0 ] && sleep ${random}m || return $?
}
function sortInPlace {
	local sort="command sort"
	for file
	do
		$sort -uo "${file}" "${file}"
	done
}
function sortM3U {
	local sort="command sort"
	for file
	do
		( echo "#EXTM3U";grep -v "#EXTM3U" "$file" | paste - - | $sort -V | \sed "s/\t/\n/" )
	done
}
function speedTest {
	type iperf3 >/dev/null || return
	for iperf3PublicServer in bouygues.testdebit.info ping.online.net ikoula.testdebit.info debit.k-net.fr speedtest.serverius.net iperf.eenet.ee iperf.volia.net
	do
		echo "=> Connecting to IPerf server $iperf3PublicServer ..." >&2
		time iperf3 -c $iperf3PublicServer -t 5 && break
	done
}
function split4GiB {
	test $# = 1 && time split -d -b 4095m $1 $1.
}
function ssh {
	local reachable=""
	local timeout=15s
	local ssh="command ssh"
	type ssh >/dev/null || return
	local remoteSSHServer=$(echo $@ | awk '{sub("^(-[[:alnum:]_]+ ?)+","");sub("[[:alnum:]_]+@","");print$1}')
	if test -n "$remoteSSHServer"
	then
		time $ssh $myDefault_sshOptions -o ConnectTimeout=$timeout $@
	else
		time $ssh -o ConnectTimeout=$timeout $@
	fi
}
function sshStartLocalForwarding {
	local tunnelDef=$1
	if test $tunnelDef
	then
		if ! \pgrep -lf $tunnelDef | \grep -q "/ssh "
		then
			if ! ssh-add -l | \grep agent
			then
				if ! command autossh -M 0 -Nf $tunnelDef 2>/dev/null
				then
					command ssh -Nf $tunnelDef
				fi
			else
				rc=$?
				echo "=> ERROR: Check the ssh-agent and load your ssh key before running: $FUNCNAME $@" >&2
				return $rc
			fi
		else
			echo "=> INFO: The tunnel $tunnelDef is already runnung :" >&2
		fi
		\pgrep -lf $tunnelDef
	fi
}
function string2qrcode_with_qrencode {
	local dotSize=8 string=""
	if [ $# = 1 ];then
		string="$1"
		qrencode -l H -s $dotSize -m 0 -o- "$string" | feh -
	fi
}
string2qrcode_with_zint () {
	# https://www.zint.org.uk/manual
    local dotSize=8 string=""
    if [ $# = 1 ]; then
        string="$1"
        zint -b QRCODE --scale 4 --secure 4 --direct -d "$string" | feh -
    fi
}
function sumFirstColumn {
	awk "{print \$1}" | LC_ALL=C numfmt --from=iec | paste -sd+ | bc | numfmt --to=iec-i --suffix=B
}
function tar2dir {
	local dir=.
	[ $# = 2 ] && local dir="$1" && shift
	mkdir -pv "$dir"
	tar -C "$dir" "$@"
}
function untar2dir {
	local dir=.
	[ $# = $2 ] && local dir="$1" && shift
	mkdir -pv "$dir"
	tar -C "$dir" -xvf "$@"
}
function sshdVersion {
	test $# -lt 2 && {
		echo "=> Usage : $FUNCNAME server/ip portNumber" >&2
		return 1
	}
	local timeout=30
	local remoteSSHServer=$1
	local remotePort=$2
	time {
		local IFS=$'\r' 
		read -t $timeout version < /dev/tcp/$remoteSSHServer/$remotePort
		echo "$version"
	}
}
function tcpConnetTest {
	test $# -lt 2 && {
		echo "=> Usage : $FUNCNAME server/ip portNumber" >&2
		return 1
	}
	local timeout=30
	if type -P netcat > /dev/null 2>&1
	then
		if test $http_proxy
		then
			if type -P nc.openbsd > /dev/null 2>&1
			then
				time \nc.openbsd -x $proxyName:$proxyPort -v -z -w $timeout $(echo $@ | tr ":" " ")
			else
				echo "=> $FUNCNAME: Cannot connect through $proxyName:$proxyPort because <nc.openbsd> is not installed." >&2		
				return 1
			fi
		else
			time \netcat -v -z -w $timeout $(echo $@ | tr ":" " ")
		fi
	else
#		local remoteSSHServer=$(echo $@ | awk '{sub("^(-[[:alnum:]_]+ ?)+","");sub("[[:alnum:]_]+@","");print$1}')
		local remoteSSHServer=$1
		local remotePort=$2
		time timeout $timeout bash -c ": < /dev/tcp/$remoteSSHServer/$remotePort" && echo "$0: connect: connection succeeded" && echo "$0: /dev/tcp/$remoteSSHServer/$remotePort: Connection accepted"
	fi
}
function termtitle {
	printf "\e]0;$*\a"
}
function testURLs {
	for url
	do
		\curl -o /dev/null -Lsw "%{http_code}\n" $url | \egrep -q "^(200|301)$" && echo OK || echo DOWN >&2
	done
}
function testURLsFromFILE {
	for file
	do
		while read line
		do
			url=$line
			printf "=> [$file] : The url = <$url> is : "
#			\curl -sLI -m 5 $url | \egrep -wq "HTTP[^ ]* 200" && echo ALIVE || echo DEAD
			\curl -ksf -o /dev/null -m 5 $url && echo ALIVE || echo DEAD
		done < $file
	done
}
function timeprocess {
	local process="$1"
	local ps="command ps"
	local pid=$(\pgrep -f "$process" | head -1)
	test -n "$pid" && $ps -o pid,lstart,etime,etimes,cmd -fp $pid && time while \pgrep -f "$process" >/dev/null; do sleep 1s;done
}
function totalSize {
	local column=1
	awk -v column=$column '{print $column}' | LC_ALL=C numfmt --from=iec | paste -sd+ | bc | numfmt --to=iec-i --suffix=B
}
function tuneGuitar {
	for note in E2 A2 D3 G3 B3 E4;do
		play -n synth 4 pluck $note repeat 2
	done
}
function txt2pdf {
	for file
	do
		txt2ps "$file"
		\ps2pdf "${file/.*/.ps}"
		\rm -f "${file/.*/.ps}"
		echo "=> ${file/.*/.pdf}"
	done
}
function txt2ps {
	for file
	do
		\enscript -B "$file" -o "${file/.*/.ps}"
	done
}
function umountISO {
	loopBackDevice=$(sudo losetup -a | grep $1 | cut -d: -f1)
	test -z $loopBackDevice && loopBackDevice=$1
	udisksctl unmount -b $loopBackDevice
	udisksctl loop-delete -b $loopBackDevice
}
function updateDistrib {
	local distrib=$(distribType)
	case $distrib in
		debian|ubuntu) sudo apt -V upgrade --download-only "$@" && sync && echo && sudo apt -V upgrade --yes "$@" && echo && sudo apt-get -V autoremove "$@" && sudo \updatedb; sync;;
		*)	;;
	esac
}
function updateYoutubeLUAForVLC {
	local youtubeLuaURL=https://raw.githubusercontent.com/videolan/vlc/master/share/lua/playlist/youtube.lua
	if groups 2>/dev/null | egrep -wq "sudo|admin"
	then
		test $osFamily = Linux &&  \sudo wget --content-disposition -NP /usr/lib/vlc/lua/playlist/ $youtubeLuaURL
		test $osFamily = Darwin && \sudo wget --content-disposition -NP /Applications/VLC.app/Contents/MacOS/share/lua/playlist/ $youtubeLuaURL
	else
		wget --content-disposition -NP ~/.local/share/vlc/lua/playlist/ $youtubeLuaURL
	fi
}
function updateYoutubePlaylistLUAForVLC {
	local playlist_youtubeLuaURL=https://gist.github.com/seraku24/db42e0e418b2252f2136d2d7f1656be5/raw/3b403b281a37565d5ff2b21ef3645e971fac7c77/149909-playlist_youtube-vlc3patch.lua
	if groups 2>/dev/null | egrep -wq "sudo|admin"
	then
		test $osFamily = Linux &&  \sudo wget --content-disposition -NP /usr/lib/vlc/lua/playlist/ $playlist_youtubeLuaURL
		test $osFamily = Darwin && \sudo wget --content-disposition -NP /Applications/VLC.app/Contents/MacOS/share/lua/playlist/ $playlist_youtubeLuaURL
	else
		wget --content-disposition -NP ~/.local/share/vlc/lua/playlist/ $playlist_youtubeLuaURL
	fi
}
function usbFlashDriveInfo {
	test $# != 1 && echo "=> Usage: $FUNCNAME usbFlashDriveDevice" >&2 && return 1
	usbFlashDriveDevice=$1
	sudo smartctl -i -d scsi -T permissive $usbFlashDriveDevice
	sudo parted $usbFlashDriveDevice print
	sudo gdisk -l $usbFlashDriveDevice
}
function usletter2A4 {
	input="$1"
	output="${input/.pdf/--A4.pdf}"
	test $# != 1 && {
		echo "=> Usage : $FUNCNAME <inputFile>" >&2
		return 1
	}
	time \pdfjam --keepinfo -o "$output" --paper a4paper "$input"
	open "$output"
}
function versionSmallerEqual {
	version1=$1
	version2=$2
	return $( perl -Mversion -e "exit ! ( version->parse( $version1 ) <= version->parse( $version2 ) )" )
}
function webgrep {
	url=$1
	shift
	test $# -le 1 && {
		echo "=> Usage: $FUNCNAME url [grepOptions] regexp"
		return 1
	}
	test $# -ge 1 && curl -s $url | egrep $@
}
function webp2jpg {
	local image
	for image
	do
		if identify "$image" | \grep -q "no decode delegate for this image format";then
			dwebp "$image" -o - 2>/dev/null | convert - "${image/.webp/.jpg}"
		else
			convert "$image" "${image/.webp/.jpg}"
		fi
	done
}
function wgrep {
	local allArgsButLast="${@:1:$#-1}"
	local lastArg="${@: -1}"
	local url="$lastArg"
	if [ $# == 0 ]
	then
		echo "=> Usage: $FUNCNAME [grepOptions] regexp url"
		return 1
	fi
	\wget -qO- "$url" | grep $allArgsButLast
}
function wgetParallel {
	for url
	do
		\wget -Nb "$url"
	done
}
function whatPackageContainsExecutable {
	set -- "${@/:/}" # suppress trailing ":" in all arguments
	if [ "$(packageManager)" = deb ]; then
		findPackage="command dpkg -S"; searchPackage="command apt-file search";
		if echo "$@" | \grep -q ^/;then
			$findPackage $(printf "%s " "$@")
		else
			$findPackage $(printf "bin/%s " "$@")
		fi
	elif [ "$(packageManager)" = rpm ]; then
		findPackage="command rpm -qf"; searchPackage="command yum whatprovides";
		if echo "$@" | \grep -q ^/;then
			$findPackage $(printf "%s " "$@")
		else
			$findPackage $( printf "%s " $(type -P "$@") )
		fi
	else
		for executable
		do
			case "$(packageManager)" in
				*) findPackage="command whohas 2>/dev/null";; # Search package across most common distributions
			esac
			if $findPackage $executable | sed "s|/||";then
				:
			else
				if type -P $executable >/dev/null 2>&1
				then
					echo "=> Using : $searchPackage "'$'"(type -P $executable) ..." >&2
					$searchPackage $(type -P $executable)
				else
					echo "=> Using : $searchPackage bin/$executable ..." >&2
					$searchPackage bin/$executable
				fi
			fi
		done
	fi | \egrep "(libexec|bin)/"
}
function whereisIP {
	local output="$(type -P curl >/dev/null && \curl -sA "" ipinfo.io/$1 || \wget -qO- -U "" ipinfo.io/$1)"
	local outputDataType=$(echo "$output" | file -bi -)
	case $outputDataType in
		text/html*) echo "$output" | html2text;;
		application/json*) echo "$output" | jq .;;
		text/plain*) echo "$output";;
		*) echo "Unknown data type." >&2; return 1 ;;
	esac
}
function wlanmac {
	wlanIF=$(iwconfig 2>&1 | awk '/ESSID:/{print$1}')
	test "$wlanIF" && ip link show $wlanIF | awk '/link\/ether /{print$2}'
}
function xmlReIndent {
	for file
	do
		xmllint --format "$file" 2>/dev/null > "${file/.*/.indented.html}"
		[ $? != 0 ] && echo "=> WARNING: xmllint could not re-indent $file." >&2 && continue
		\mv "${file/.*/.indented.html}".indented "$file"
	done | sort -u
}
function xpiInfo {
	type jq >/dev/null || return
	local xpiFile
	local xpiID
	for xpiFile
	do
		echo "=> xpiFile = $xpiFile"
		if unzip -t "$xpiFile" | \grep -wq install.rdf
		then
			for field in em:name em:id em:description em:version em:homepageURL
			do
				unzip -q -p "$xpiFile" install.rdf | awk -F "<|>" /$field/'{if(!f)print$2"="$3;f=1}'
			done | column -ts '='
			xpiID=$(unzip -q -p "$xpiFile" install.rdf | awk -F "<|>" /em:id/'{if(!f)print$3;f=1}')
			test "$xpiID" || for field in name id description version homepageURL
			do
				unzip -q -p "$xpiFile" install.rdf | grep -v "xml.version" | awk -F "<|>" /$field/'{if(!f)print$2"="$3;f=1}'
			done | column -ts '='
		elif unzip -t "$xpiFile" | \grep -wq manifest.json
		then
			unzip -q -p "$xpiFile" manifest.json | jq '{name, id:.applications.gecko.id , description , version , url:.homepage_url}'
			xpiID=$(unzip -q -p "$xpiFile" manifest.json | jq -r '.applications.gecko.id')
		fi
		echo
	done
}
function xpiRename {
	type jq >/dev/null || return
	local xpiFile
	local xpiID
	for xpiFile
	do
		echo "=> xpiFile = $xpiFile"
		if unzip -t "$xpiFile" | \grep -wq install.rdf
		then
			for field in em:id id
			do
				xpiID=$(unzip -q -p "$xpiFile" install.rdf | awk -F "<|>" /$field/'{if(!f)print$3;f=1}')
				test "$xpiID" && break
			done
		elif unzip -t "$xpiFile" | \grep -wq manifest.json
		then
			xpiID=$(unzip -q -p "$xpiFile" manifest.json | jq -r '.applications.gecko.id')
		fi
		{ [ "$xpiID" = null ] || [ "$xpiID" = "" ]; } && echo "==> xpiID = $xpiID" && echo && continue
		test "$xpiID.xpi" = "$(basename $xpiFile)" && echo "==> xpiID = $xpiID"
		\mv -vi $xpiFile "$(dirname $xpiFile)/$xpiID.xpi"
		echo
	done
}
function xsetResolution {
	local output=$(\xrandr | \awk  '/^.+ connected/{print$1}')
	local oldResolution=$(\xrandr | \awk '/[0-9].*\*/{print$1}')

	echo "=> Reset current resolution command :"
	echo "xrandr --output $output --mode $oldResolution"
	if [ $# = 0 ]
	then
		echo "=> Usage: $FUNCNAME XResxYRes"
		echo
		echo "=> Here are the possible resolutions :"
		\xrandr | awk '/^ +[0-9]+x[0-9]+/{printf$1" "}'
		echo
		return 1
	else
		local newResolution=$1
		if ! \xrandr | grep -wq $newResolution
		then
			echo "=> $FUNCNAME ERROR : The resolution <$newResolution> is not supported." >&2
			return 2
		fi

		echo "=> Setting new resolution command :"
		echo "xrandr --output $output --mode $newResolution"
		\xrandr --output $output --mode $newResolution
	fi
}

set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
