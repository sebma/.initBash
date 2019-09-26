# vim: set syn=sh noet:
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

Source $initDir/.bash_functions.build
Source $initDir/.bash_functions.AV
Source $initDir/.bash_functions.ytdl

function Echo {
	local rc=$?
	set +o histexpand # Turn off history expansion to be able easily use the exclamation mark in strings i.e https://stackoverflow.com/a/22130745/5649639
	command echo "$@"
	set -o histexpand
	return $rc
}
function Less {
	for file
	do
		\highlight -O ansi --force "$file" | \less -ir
	done
}
function More {
	for file
	do
		\highlight -O ansi --force "$file" | more
	done
}
function Most {
	for file
	do
		\highlight -O ansi --force "$file" | most
	done
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
	local sudo="command sudo"
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
	local top=$(which -a top | \grep ^/usr) #Au cas ou il y a un script top ailleurs dans le PATH
	local processPattern=$1
	test -n "$processPattern" && shift && local processPIDs=$(\pgrep -f $processPattern)
	if [ -z "$processPIDs" ]
	then
		$top
	else
		if [ $os = Linux ]
		then
			$top -d 1 $(printf -- "-p %d " $processPIDs) $@
		elif [ $os = Darwin ]
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
function apkInfo {
	for package
	do
		echo "=> package = $package"
		[ -f "$package" ] || {
			echo "==> ERROR : The file $package does not exist." >&2; continue
		}

		aapt dump badging "$package" | awk -F"'" '/^package:/{print$(NF-1)}/application:|^package:/{print$2}/[Ss]dkVersion:/'
	done
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
function awkCalc {
	\awk "BEGIN{ print $* }"
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
function castnowPlaylist {
	test $# = 0 && {
		echo "=> Usage: $FUNCNAME [index] playlistFile ..." >&2
		return 1
	}

	local index=${1:-1}
	test $# = 2 && shift
	local playlist=$1
	printf "=> Start playing playlist at: "
	\sed -n "${index}p" $playlist
	castnowURLs $(awk '{print$1}' $playlist | \grep -v ^# | tail -n +$index)
}
function castnowURLs {
	test $# = 0 && {
		echo "=> Usage: $FUNCNAME [ytdl-format] url1 url2 ..." >&2
		return 1
	}

	local format="mp4[height<=480]/mp4/best"
	echo $1 | \egrep -q "^(https?|s?ftps?)://" || { format="$1"; shift; }

#	set -x
	for url
	do
		youtube-dl --no-continue --ignore-config -f "$format" -o- -- "$url" | castnow --quiet -
	done
	set +x
	echo
}
function cer2pem {
	for cerCertificate
	do
		openssl x509 -inform DER -in "$cerCertificate" -outform PEM -out "${cerCertificate/.pem/.cer}"
		ls -l "${cerCertificate/.pem/.cer}"
	done
}
function cleanFirefoxLock {
	case $(lsb_release -si) in
		Debian) firefoxProgramName=iceweasel;;
		Ubuntu) firefoxProgramName=firefox;;
	esac

	pgrep -lf $firefoxProgramName || \rm -vf ~/.mozilla/firefox/*.default/lock ~/.mozilla/firefox/*.default/.parentlock
}
function numberSmallerEqual {
	number1=$1
	number2=$2
	return perl -e "exit(! ( $number1 <= $number2 ) )"
}
function versionSmallerEqual {
	number1=$1
	number2=$2
	return perl -Mversion -e "exit(! ( version->parse( $number1 ) <= version->parse( $number2 ) ) )"
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
		args=$@
		command dfc -TW $args
	else
		shift
		args=$@
		test "$args" && argsRE="|"$(echo $@ | tr -s / | tr " " "|" | sed "s,/$,,")
		firstArg="$(echo "$firstArg" | tr -s /)"
		test "$firstArg" != / && firstArg="$(echo "$firstArg" | sed "s,/$,,")"
		command dfc -TWfc always | \egrep "FILESYSTEM|$firstArg$argsRE"
	fi
}
function dirName {
	#NE MARCHE PAS LORSQUE LE CHEMIN NE CONTIENT PAS DE "/"
	for arg
	do
		echo ${arg%/*}
	done
}
function distribPackageMgmt {
	case $(distribType) in
		debian|Debian) packageType="deb";;
		redhat|Redhat|sailfishos) packageType="rpm";;
		*) packageType=unknown;;
	esac
	echo $packageType
}
function distribType {
	distribType=unknown
	if which lsb_release >/dev/null 2>&1
	then
		distrib=$(\lsb_release -si)
		case $distrib in
			Ubuntu|Debian) distribType="debian";;
			Mer |Redhat|Fedora) distribType="redhat";;
			*) distribType=unknown;;
		esac
	else
		if   [ $os = Linux ]
		then
			distrib=$(awk -F"=" '/^ID=/{print$2}' /etc/os-release)
			distribType=$(grep ID_LIKE /etc/os-release | cut -d= -f2 | cut -d'"' -f2 | cut -d" " -f1) #Pour les cas ou ID_LIKE est de la forme ID_LIKE="rhel fedora"
		elif [ $os = Darwin ]
		then
			distrib="$(sw_vers -productName)"
			distribType=$os
		else
			distrib=unknown
			distribType=$os
		fi
	fi
	echo $distribType
}
function env {
	command env $@ | sort
}
function extractURLs {
	for file
	do
		\sed -E 's/^.*http/http/;s/[<"].*$//;/^\s*$/d;/http/!d' "$file"
	done | sort -u
}
function extractURLs_Simplified  {
	for file
	do
		\grep -oP '(www|http:|https:)+[^\s"]+[\w]' "$file" | uniq
	done | sort -u
}
function fileTypes {
	local find="command find"
	time for dir
	do
		$find $dir -xdev -ls | awk '{print substr($3,1,1)}' | sort -u
	done
}
function find {
	local find="command find"
	[ $os = Darwin ] && find=gfind
	dir=$1
	if echo $dir | \grep -q "^-"
	then
		dir=.
	else
		shift
	fi
#	firstPredicate=$1
#	shift
	args="$@"
	if echo $@ | \grep -q "\-ls"
	then
		args=${args/-ls/}
		$find $dir $firstPredicate $args -printf "%10i %10k %M %n %-10u %-10g %10s %AY-%Am-%Ad %.12AX %p\n"
	else
#		$find $dir $firstPredicate "$arg"
		$find $dir $firstPredicate "$@"
	fi
}
function findHumanReadable {
	local find="command find"
	[ $os = Darwin ] && find=gfind
	dir=$1
	echo $dir | \grep -q "\-" && dir=. || shift
	args="$@"
	if echo $args | \grep -q "\-ls"
	then
		$find $dir $firstPredicate $args | numfmt --field 7 --from=iec --to=iec-i --suffix=B | \column -t
	else
		$find $dir $firstPredicate $args
	fi
}
function findLoops {
	[ $os = Darwin ] && find=gfind || find="command find"
	time $find $@ -xdev -follow 2>&1 >/dev/null | egrep -w "loop|denied"
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
	local wget="$(which wget2 2>/dev/null || which wget)"
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
		printf "=> $url : " >&2
		\curl -Ls $url | pup --charset utf8 'title text{}'| \recode html..latin9
	done
}
function getVideosFromRSSPodCastPlayList {
	test $# = 1 && {
		local rssURL="$1"
		local wget="$(which wget2 2>/dev/null || which wget)"
#		$wget $(youtube-dl -g "$rssURL")
		$wget $(curl -s "$rssURL" | egrep -o "https?:[^ <>]*(mp4|webm)" | grep -v .google.com/ | uniq)
	}
}
function gitCloneHome {
	test $# -ge 1 && gitCloneNonEmptyDir $@ $HOME
}
function gitCloneNonEmptyDir {
	local url="$1"
	local dir="$2"
	test $dir || dir=.
	test $url && {
		git init "$dir"
		git remote | grep -q origin || git remote add origin "$url"
		git fetch
		git pull origin master
		git branch --set-upstream-to=origin/master master
	}
}
function gitUpdateAllLocalRepos {
	local dir=""
	command gfind ~ -type d -name .git | while read dir
	do
		cd $dir/..
		echo "=> Updating <$dir> local repo. ..." >&2
		\grep -w "^[[:blank:]]url" ./.git/config
		\git pull
		cd - >/dev/null
	done
	unset dir
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
function grepFunction {
	let $# -lt 2 && {
		echo "=> Usage : $FUNCNAME startRegExpPattern fileList" >&2
		return 1
	}
	shift
	grepParagraph "function $1|${1}.*[(]" "^}" "$@"
}
function grepParagraph {
	let $# -lt 3 && {
		echo "=> Usage : $FUNCNAME startRegExpPattern endRegExpPattern fileList" >&2
		return 1
	}
	local startRegExpPattern
	local endRegExpPattern
	local fileListPattern="${@:3}"

#	startRegExp=$1 endRegExp=$2 \sed -E -n "/$startRegExpPattern/,/$endRegExpPattern/p" $fileListPattern
#	startRegExp=$1 endRegExp=$2 awk "/$startRegExpPattern/{p=1}p;/$endRegExpPattern/{p=0}" $fileListPattern
	startRegExp=$1 endRegExp=$2 perl -ne 'print "$ARGV:$_" if /$ENV{startRegExp}/ ... (/$ENV{endRegExp}/ || eof)' $fileListPattern
}
function greplast {
	grep "$@" | awk 'END{print}'
}
function h5ll {
	local switch="$1"
	echo $switch | \grep -q "^-" && shift 1 || switch=""
	for file
	do
		\h5ls -r $switch $file
	done | \egrep "Group|Attribute:|Dataset|Data:"
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

	local pdfFiles=""
	for url_or_file
	do
		pdfFileName=$(basename $url_or_file | \sed -E "s/#.*//;s/$|\.[^.]+$/.pdf/")
		pdfFiles+="$pdfFileName "
		wkhtmltopdf --no-background --outline --header-line --footer-line --header-left [webpage] --footer-left "[isodate] [time]" --footer-right [page]/[toPage] "$url_or_file" "$pdfFileName"
	done
	open $pdfFiles
}
function htmlReIndent {
	for file
	do
		xmllint --html --format "$file" 2>/dev/null > "${file/.*/.indented.html}"
		[ $? != 0 ] && echo "=> WARNING: xmllint could not re-indent $file." >&2 && continue
		\mv "${file/.*/.indented.html}".indented "$file"
	done | sort -u
}
function httpLocalServer {
#	local fqdn=$(host $(hostname) | awk '/address/{print$1}')
	local fqdn=localhost
	test $1 && port=$1 || port=1234
	test $port -lt 1024 && {
		echo "=> ERROR: Only root can bind to a tcp port lower than 1024." >&2
		return 1
	}

	local oldPort=$(\ps -fu $USER | \grep -v awk | awk '/SimpleHTTPServer/{print$NF}')
	command ps -fu $USER | \grep -v grep | \grep -q SimpleHTTPServer && echo "=> SimpleHTTPServer is already running on http://$fqdn:$oldPort/" || {
		logfilePrefix=SimpleHTTPServer_$(date +%Y%m%d)
		mkdir -p ~/log
		nohup python -m SimpleHTTPServer $port >~/log/${logfilePrefix}.log 2>&1 &
		test $? = 0 && {
			echo "=> SimpleHTTPServer started on http://$fqdn:$port/" >&2
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
	local system=$(systemType)
	case $system in
		Debian|Ubuntu) \ls -lact --full-time /etc | awk 'END {print $6,substr($7,1,8)}' ;;
		Mer|Redhat) \rpm -q basesystem --qf '%{installtime:date}\n' ;;
		darwin15*) \ls -lactL -T /etc | awk 'END {print $6,$7,$8}' ;;
		*)	;;
	esac
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
	if which ldapsearch >/dev/null 2>&1
	then
		ldapsearch -x -LLL uid=$1
	fi
}
function listVideosFromRSSPodCastPlayList {
	test $# = 1 && {
		local rssURL="$1"
		local wget="$(which wget2 2>/dev/null || which wget)"
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
	locate "$PWD/.*$regExp" "$@"
}
function locateFromHome {
	local regExp="$1"
	shift
	locate "$HOME/.*$regExp" "$@"
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
function lsbin {
	for package
	do
		package=${package/:/}
		case "$(distribPackageMgmt)" in
			rpm) packageContents="rpm -ql";;
			deb) packageContents="dpkg -L";;
		esac
		$packageContents $package
	done | grep bin/ | sort -u
}
function lseth {
	\lspci | awk '/Ethernet controller/{print$1}' | while read device
	do
		\lspci -nns $device "$@"
	done
}
function lsgroup {
	for group
	do
		printf "%s:" $group;awk -F: "/$group:/"'{gsub(","," ");print$NF}' /etc/group
	done
}
function lsgroup {
	for group
	do
		printf "%s:" $group;awk -F: "/$group:/"'{gsub(","," ");print$NF}' /etc/group
	done
}
function lswifi {
	\lspci | awk '/Network controller/{print$1}' | while read device
	do
		\lspci -nns $device "$@"
	done
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
function memUsage {
	local processName=$1
	local columns="pid,comm,pmem,rssize"
	if test $processName
	then
		\pgrep -f $processName >/dev/null && \ps -o $columns -p $(\pgrep -f $processName) | awk '/PID/;/[0-9]/{sub($4,$4/1024);print$0" MiB";total+=$4}END{if(total>1024)printf "=> Total= %.3lf GiB\n\n",total/1024>"/dev/stderr"; else printf "=> Total= %.3f MiB\n\n",total>"/dev/stderr"}' | \column -t
	else
#		\ps -eo rss= | awk '/[0-9]/{total+=$1/1024}END{print "\tTotal= "total" MiB"}'
		\free -m | awk '/Mem:/{total=$2}/buffers.cache:/{used=$3}END{printf "%5.2lf%%\n", 100*used/total}'
	fi
}
function mkdircd {
	\mkdir -pv $1
	cd $1 && pwd -P
}
function mountISO {
	loopBackDevice=$(udisksctl loop-setup -r -f "$1" | awk -F "[ .]" '{print$(NF-1)}')
	udisksctl mount -b $loopBackDevice
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
	case $os in
		Darwin) sw_vers >/dev/null 2>&1 && echo $(sw_vers -productName) $(sw_vers -productVersion) || system_profiler SPSoftwareDataType || defaults read /System/Library/CoreServices/SystemVersion ProductVersion ;;
		Linux) \lsb_release -scd | tr "\n" " ";echo 2>/dev/null || awk -F'[="]' '/PRETTY_NAME/{printf$(NF-1)" "}/VERSION_CODENAME/{codeName=$2}END{if(codeName)print codeName;else print""}' /etc/os-release || sed -n 's/\\[nl]//g;1p' /etc/issue ;;
		*) ;;
	esac
}
function pdfAutoRotate {
	for file
	do
		output="${file/.pdf/-ROTATED.pdf}"
		time \gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/All -sOutputFile="$output" "$file"
		echo
		echo "=> $output"
	done
}
function pdfCompress {
	for pdf
	do
		echo "=> Compressing $pdf ..."
		time \pdftk $pdf output ${pdf/.pdf/__SMALLER.pdf} compress
		echo
		du -h ${pdf/.pdf/*.pdf}
	done
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
function pdfSelect {
	input=$1
	pages=$2
	output=$3
	test $# != 3 && {
		echo "=> Usage : $FUNCNAME <inputFile> <pageRanges> <outputFile>" >&2
		return 1
	}
	time \pdfjam $input $pages -o $output
	open $output
}
function pem2cer {
	for pemCertificate
	do
		openssl x509 -inform PEM -in "$pemCertificate" -outform DER -out "${pemCertificate/.pem/.cer}"
		ls -l "${pemCertificate/.pem/.cer}"
	done
}
function perlCalc {
	\perl -le "print ${*/^/**}"
}
function picMpixels {
	for fileName
	do
		LC_NUMERIC=C \perl -le "printf \"=> fileName = %s size = %.2f Mpix\n\", \"$fileName\", $(identify -format '%w*%h/10**6' $fileName)"
	done | \column -t
}
function pingMyLAN {
	local myLAN=$(\ip addr show | awk '/inet /{print$2}' | egrep -v '127.0.0.[0-9]|192.168.122.[0-9]')
	if which fping >/dev/null 2>&1
	then
		time fping -r 0 -aAg $myLAN 2>/dev/null | sort -u
	else
		time \nmap -T5 -sP $myLAN | sed -n '/Nmap scan report for /s/Nmap scan report for //p'
	fi
}
function pip {
	local caller=${FUNCNAME[1]}
	test $caller || caller="pip"
	which $caller >/dev/null || { echo "$0: ERROR $caller is not installed">&2;return 1; }
	firstArg=$1
	if   [ "$firstArg" = install ]
	then
		if groups | egrep -wq "sudo|admin"
		then
			\sudo -H $(which $caller) $@
		else
			command $caller $@ --user
		fi
	elif [ "$firstArg" = uninstall ]
	then
		if groups | egrep -wq "sudo|admin"
		then
			\sudo -H $(which $caller) $@
		else
			command $caller $@
		fi
	elif [ "$firstArg" = search ]
	then
		command $caller $@ | sort
	else
		command $caller $@
	fi
}
function pip2 {
	which pip2 >/dev/null || { echo "-$0: pip2: command not found">&2;return 1; }
	pip $@
}
function pip3 {
	which pip3 >/dev/null || { echo "-$0: pip3: command not found">&2;return 1; }
	pip $@
}
function piphelp {
	pip help $1 | less
}
function piphelp {
	pip help $1 | less
}
function printrv {
	lp -o page-set=odd -o outputorder=reverse $1
	echo "=> Press enter once you have flipped the pages in the printer ..."
	read
	lp -o page-set=even $1
}
function processSPY {
	watchProcess $@
}
function processUsage {
	local columns="rssize,pmem,pcpu,pid,args"
#	headers=$(\ps -e -o $columns | grep -v grep.*COMMAND | \grep COMMAND)
	headers=" RSS\t       %MEM %CPU  PID   COMMAND"
	echo -e "$headers" >&2
	# "tail -n +1" ignores the SIGPIPE
	\ps -e -o $columns | sort -nr | cut -c-156 | head -500 | awk '!/COMMAND/{printf "%9.3lf MiB %4.1f%% %4.1f%% %5d %s\n", $1/1024,$2,$3,$4,$5}' | tail -n +1 | head -45
}
function pythonCalc {
	\python -c "print(${*/^/**})"
}
function reload_SHELL_Functions_And_Aliases {
#	for script in ~/.${0}rc $initDir/.*functions $initDir/.*aliases $initDir/.*aliases.$os
	for script in $initDir/.bashrc.$os $initDir/.*functions $initDir/.*functions.$os $initDir/.*aliases $initDir/.*aliases.$os
	do
		source $script
	done
}
function renameExtension { test $# = 2 && shopt -s globstar && for f in **/*.$1; do /bin/mv -vi "$f" "${f/.$1/.$2}"; done; }
function downgradeTo {
	distribCodename=$1
	case $distribCodename in
		"-h"|"")
			echo "=> ERROR: Usage: $FUNCNAME [ <distribCodename> ] | downgrade current" >&2
			return -1
		;;
		"current")
			distribCodename=$(lsb_release -sc)
		;;
		*) #Ajouter une commande pour tester si le nom donne existe
		;;
	esac
	echo "=> distribCodename = $distribCodename"
	sudo sed -i".$(date +%Y%m%d)" "s/$(lsb_release -sc)/$distribCodename/" /etc/apt/sources.list
	if test -s /etc/apt/preferences.d/99-downgrade
	then
		time sudo command apt update
		sudo command apt dist-upgrade -V
	else
		echo "=> ERROR: The file </etc/apt/preferences.d/99-downgrade> does not exist, generating it ..." >&2 && {
			cat <<-EOF
			Package: *
			Pin: release a=$distribCodename
			Pin-Priority: 1001

			Package: *
			Pin: release a=$distribCodename-updates
			Pin-Priority: 1001

			Package: *
			Pin: release a=$distribCodename-security
			Pin-Priority: 1001

			Package: *
			Pin: release a=$distribCodename-backports
			Pin-Priority: 1001

			Package: *
			Pin: release a=$distribCodename-proposed
			Pin-Priority: -1
EOF
		} | sudo tee /etc/apt/preferences.d/99-downgrade
		echo "=> Please re-run the <downgrade> function." >&2
		return 1
	fi
}
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
function rename_APK {
	type aapt || return
	for package
	do
		echo "=> package = $package"
		[ -f "$package" ] || {
			echo "==> ERROR : The package $package does not exist." >&2; continue
		}

		packagePath=$(dirname "$package")
		set -o pipefail
		packageID=$(aapt dump badging "$package" | awk -F"'" '/^package:/{print$2}') || continue
		set +o pipefail
		packageVersion=$(aapt dump badging "$package" | awk -F"'" '/^package:/{print$6}' | cut -d' ' -f1)
		packageNewFileName="$packagePath/$packageID-$packageVersion.apk"
		[ "$package" = $packageNewFileName ] || mv -v "$package" $packageNewFileName
	done
}
function rename_All_APKs {
	type aapt || return
	for package in $(\ls *.apk)
	do
		echo "=> package = $package"
		[ -f "$package" ] || {
			echo "==> ERROR : The package $package does not exist." >&2; continue
		}

		if echo $package | egrep -q "^[^\.]+\.apk"
		then
			packagePath=$(dirname $package)
			set -o pipefail
			packageID=$(aapt dump badging "$package" | awk -F"'" '/^package:/{print$2}') || continue
			set +o pipefail
			packageVersion=$(aapt dump badging "$package" | awk -F"'" '/^package:/{print$6}' | cut -d' ' -f1)
			packageNewFileName="$packagePath/$packageID-$packageVersion.apk"
			[ "$package" = $packageNewFileName ] || mv -v "$package" $packageNewFileName
		fi
	done
}
function resetRESOLUTION {
	\xrandr | awk '{if(/\<connected/)output=$1;if(/\*/){print"xrandr --output "output" --mode "$1;exit}}' | sh -x
}
function resizePics {
	for src
	do
		ext=$(echo "$src" | awk -F. '{print$NF}')
		dst="${src/.$ext/-SMALLER}.$ext"
		convert -verbose -resize '1024x768>' "$src" "$dst"
		touch -r "$src" "$dst"
	done
}
function resizePics_1536 {
	for src
	do
		ext=$(echo "$src" | awk -F. '{print$NF}')
		dst="${src/.$ext/-SMALLER_1536}.$ext"
		convert -verbose -resize '1536x1152>' "$src" "$dst"
		touch -r "$src" "$dst"
	done
}
function resizePics_2048 {
	for src
	do
		ext=$(echo "$src" | awk -F. '{print$NF}')
		dst="${src/.$ext/-SMALLER_2048}.$ext"
		convert -verbose -resize "$((2*1024))x$((2*768))>" "$src" "$dst"
		touch -r "$src" "$dst"
	done
}
function resizePics_3072 {
	for src
	do
		ext=$(echo "$src" | awk -F. '{print$NF}')
		dst="${src/.$ext/-SMALLER_3072}.$ext"
		convert -verbose -resize "$((3*1024))x$((3*768))>" "$src" "$dst"
		touch -r "$src" "$dst"
	done
}
function resizePics_4096 {
	for src
	do
		ext=$(echo "$src" | awk -F. '{print$NF}')
		dst="${src/.$ext/-SMALLER_4096}.$ext"
		convert -verbose -resize "$((4*1024))x$((4*768))>" "$src" "$dst"
		touch -r "$src" "$dst"
	done
}
function restart_conky {
	for server
	do
		ssh $server "pgrep conky && killall -SIGUSR1 conky || conky -d"
	done
	\pgrep conky && \killall -SIGUSR1 conky || conky -d
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
	[ $os = Darwin ] && deadline="-t 5"
	[ $os = Linux ]  && deadline="-w 5"
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
function sizeOfRemoteFile {
    trap 'rc=$?;set +x;echo "=> $FUNCNAME: CTRL+C Interruption trapped.">&2;return $rc' INT
    local size
    local total="0"
    local format=18
    echo $1 | \egrep -q "^https?://" || {
        format=$1
        shift
    }
    for url
    do
        size=$(\curl -sI "$url" | \sed "s/\r//g" | awk 'BEGIN{IGNORECASE=1}/Content-?Length:/{print$2/2^20}')
        total="$total+$size"
        printf "%s %s Mo\n" $url $size
    done
    test $# -gt 1 && {
        total=$(echo $total | \bc -l)
        echo "=> total = $total Mo"
    }
    trap - INT
}
function sortInPlace {
	local sort="command sort"
	for file
	do
		$sort -uo "$file" "$file"
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
	local timeout=5
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
function sshStartLocalForward {
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
function sum {
	awk "{print \$1}" | LC_ALL=C numfmt --from=iec | paste -sd+ | bc | numfmt --to=iec-i --suffix=B
}
function systemType {
	local system
	if which lsb_release >/dev/null
	then
		system=$(lsb_release -si)
	else
		system=$OSTYPE
	fi
	echo $system
}
function tcpConnetTest {
	test $# -lt 2 && {
		echo "=> Usage : $FUNCNAME server/ip portNumber" >&2
		return 1
	}
	if which netcat > /dev/null 2>&1
	then
		if test $http_proxy
		then
			if which nc.openbsd > /dev/null 2>&1
			then
				time \nc.openbsd -x $proxyName:$proxyPort -v -z -w 5 $(echo $@ | tr ":" " ")
			else
				echo "=> $FUNCNAME: Cannot connect through $proxyName:$proxyPort because <nc.openbsd> is not installed." >&2		
				return 1
			fi
		else
			time \netcat -v -z -w 5 $(echo $@ | tr ":" " ")
		fi
	else
#		local remoteSSHServer=$(echo $@ | awk '{sub("^(-[[:alnum:]_]+ ?)+","");sub("[[:alnum:]_]+@","");print$1}')
		local remoteSSHServer=$1
		local remotePort=$2
		time command bash -c ": < /dev/tcp/$remoteSSHServer/$remotePort"
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
	local process=$1
	local pid=$(\pgrep -f "$1" | head -1)
	test -n "$pid" && \ps -o etime -fp $pid
}
function totalSize {
	local column=$1
	awk "{print \$$column}" | LC_ALL=C numfmt --from=iec | paste -sd+ | bc | numfmt --to=iec-i --suffix=B
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
function typeFunction {
	for function
	do
		type $function
	done | \sed 's/;$//' | \sed -zE 's/$\n\{/{/'
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
		test $os = Linux &&  \sudo \wget --content-disposition -NP /usr/lib/vlc/lua/playlist/ $youtubeLuaURL
		test $os = Darwin && \sudo \wget --content-disposition -NP /Applications/VLC.app/Contents/MacOS/share/lua/playlist/ $youtubeLuaURL
	else
		\wget --content-disposition -NP ~/.local/share/vlc/lua/playlist/ $youtubeLuaURL
	fi
}
function updateYoutubePlaylistLUAForVLC {
	local playlist_youtubeLuaURL=https://dl.opendesktop.org/api/files/download/id/1473753829/149909-playlist_youtube.lua
	if groups 2>/dev/null | egrep -wq "sudo|admin"
	then
		test $os = Linux &&  \sudo \wget --content-disposition -NP /usr/lib/vlc/lua/playlist/ $playlist_youtubeLuaURL
		test $os = Darwin && \sudo \wget --content-disposition -NP /Applications/VLC.app/Contents/MacOS/share/lua/playlist/ $playlist_youtubeLuaURL
	else
		\wget --content-disposition -NP ~/.local/share/vlc/lua/playlist/ $playlist_youtubeLuaURL
	fi
}
function webgrep {
	url=$1
	shift
	test $# -ge 1 && curl -s $url | egrep $@
}
function wgetParallel {
	for url
	do
		\wget -Nb "$url"
	done
}
function whatPackageContainsExecutable {
	if [ "$(distribPackageMgmt)" = deb ]
	then
		findPackage="command dpkg -S"; searchPackage="command apt-file search";
		$findPackage $(printf "bin/%s " "$@")
	else
		for executable
		do
			case "$(distribPackageMgmt)" in
				rpm) findPackage="command rpm -qf"; searchPackage="command yum whatprovides";;
				*) findPackage="command $(which whohas) 2>/dev/null";; # Search package across most common distributions
			esac
			if $findPackage $executable | sed "s|/||";then
				:
			else
				if which $executable >/dev/null 2>&1
				then
					echo "=> Using : $searchPackage $executable ..." >&2
					$searchPackage $executable
				else
					echo "=> Using : $searchPackage bin/$executable ..." >&2
					$searchPackage bin/$executable
				fi
			fi
		done
	fi
}
function whereisIP {
	which curl >/dev/null && \curl -A "" ipinfo.io/$1 || \wget -qO- -U "" ipinfo.io/$1
}
function wlanmac {
	wlanIF=$(iwconfig 2>&1 | awk '/ESSID:/{print$1}')
	test "$wlanIF" && ip link show $wlanIF | awk '/link\/ether /{print$2}'
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
			unzip -q -p "$xpiFile" manifest.json | jq '{name:.name , id:.applications.gecko.id , description:.description , version:.version , url:.homepage_url}'
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
