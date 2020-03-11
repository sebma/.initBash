# vim: set ft=bash noet:
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

export adb=$(which adb)
export dos2unix="$(which tr) -d '\r'"
export getprop="$adb shell getprop"

function adbDisablePackages {
	for package
	do
		echo "=> Disabling <$package> #$remainingPackages/$machingPackagesNumber remaining packages to process ..."
		set -x
		$adb shell pm disable $package || $adb shell pm disable-until-used $package || $adb shell pm disable-user $package
		set +x
		let remainingPackages--
	done | $dos2unix
}
function adbGetAndroidCodeName {
	local getprop="$adb shell getprop"
	( [ $# -ge 2 ] || echo $1 | egrep -q -- "^--?(h|u)" ) && echo "=> Usage : $FUNCNAME [androidRelease]" 1>&2 && return 1
	
	local androidRelease=unknown
	local androidCodeName=unknown
	if echo $1 | egrep -q "[0-9.]+"; then
		androidRelease=$1 
		androidCodeName="REL" # Do not use "androidCodeName" when it equals to "REL" but infer it from "androidRelease"
	elif [ -n "$($getprop ro.build.version.release 2>/dev/null)" ]; then
		androidRelease=$($getprop ro.build.version.release)
		androidCodeName=$($getprop ro.build.version.codename)
	else
		echo "=> [$FUNCNAME] ERROR: Could not detect android release on this device" >&2
		return 2
	fi

	# Time "androidRelease" x10 to test it as an integer
	case $androidRelease in
		[0-9].[0-9]|[0-9].[0-9].|[0-9].[0-9].[0-9])  androidRelease=$(echo $androidRelease | cut -d. -f1-2 | tr -d .);;
		[0-9].) androidRelease=$(echo $androidRelease | sed 's/\./0/');;
		[0-9]) androidRelease+="0";;
	esac

	[ -n "$androidRelease" ] && [ $androidCodeName = REL ] && {
	# Do not use "androidCodeName" when it equals to "REL" but infer it from "androidRelease"
		androidCodeName="${colors[blue]}"
		case $androidRelease in
		10) androidCodeName+=NoCodename;;
		11) androidCodeName+="Petit Four";;
		15) androidCodeName+=Cupcake;;
		20|21) androidCodeName+=Eclair;;
		22) androidCodeName+=FroYo;;
		23) androidCodeName+=Gingerbread;;
		30|31|32) androidCodeName+=Honeycomb;;
		40) androidCodeName+="Ice Cream Sandwich";;
		41|42|43) androidCodeName+="Jelly Bean";;
		44) androidCodeName+=KitKat;;
		50|51) androidCodeName+=Lollipop;;
		60) androidCodeName+=Marshmallow;;
		70|71) androidCodeName+=Nougat;;
		80|81) androidCodeName+=Oreo;;
		90) androidCodeName+=Pie;;
		100) androidCodeName+=ToBeReleased;;
		*) androidCodeName=${colors[red]}unknown;;
		esac
	}
	echo $androidCodeName$normal
}
function adbGetIMEI {
	local getprop="$adb shell getprop"
	local imeiLength=15
	local IMEI1=$(printf "%0${imeiLength}d" 0)
	local IMEI2=$IMEI1

	if IMEI1=$($getprop persist.sys.fota_deviceid1); echo $IMEI1 | \egrep -q "^[0-9]{$imeiLength}"; then
		IMEI2=$($getprop persist.sys.fota_deviceid2 | sed 's/^,//')
	elif IMEI1=$($adb shell service call iphonesubinfo 1 | awk -F"'" 'NR>1{gsub(/\./,"",$2);imei=imei$2}END{print imei}'); echo $IMEI1 | \egrep -q "^[0-9]{$imeiLength}"; then
		IMEI2=$($adb shell service call iphonesubinfo 3 | awk -F"'" 'NR>1{gsub(/\./,"",$2);imei=imei$2}END{print imei}')
	elif IMEI1=$($adb shell dumpsys iphonesubinfo | awk '/Device/{print$NF}'); echo $IMEI1 | \egrep -q "^[0-9]{$imeiLength}"; then
		IMEI2=$($adb shell dumpsys iphonesubinfo2 2>/dev/null | awk '/Device/{print$NF}' )
	elif IMEI1=$($getprop persist.radio.device.imei); echo $IMEI1 | \egrep -q "^[0-9]{$imeiLength}"; then
		:
	fi

	IMEI1=$(echo $IMEI1 | $dos2unix)
	echo $IMEI1
	IMEI2=$(echo $IMEI2 | $dos2unix)
	echo $IMEI2
}
function adbHidePackages {
	for package
	do
		echo "=> Hiding <$package> #$remainingPackages/$machingPackagesNumber remaining packages to process ..."
		$adb shell pm hide $package || $adb shell pm disable-until-used $package || $adb shell pm disable-user $package
		let remainingPackages--
	done | $dos2unix
}
function adbPackageStatus {
	for package
	do
		echo "=> Checking <$package> #$remainingPackages/$machingPackagesNumber remaining packages to process ..."
		if $adb shell pm list packages -e | \egrep -q "$package"; then
			echo "==> $package is ENABLED"
		else
			echo "==> $package is NOT ENABLED"
		fi
		let remainingPackages--
	done | $dos2unix
}
function adbSetADBTcpPort {
	local getprop="$adb shell getprop"
	local defaultADBTcpPort=5555
	local port=0
	local adb=$(which adb)
	local dos2unix="$(which tr) -d '\r'"
	case $1 in
		-h|-help|--h|--help) echo "=> Usage: $FUNCNAME [portNumber|$defaultADBTcpPort]" >&2; return 1 ;;
		[0-9]) port=$1;;
		"") port=$defaultADBTcpPort;;
		*) echo "[ $FUNCNAME ] => ERROR Usage: $FUNCNAME [portNumber|$defaultADBTcpPort]" >&2; return 2 ;;
	esac

	$adb devices | grep -w offline && echo "[ $FUNCNAME ] => INFO : You need to unplug your USB cord." >&2 && return 3
	$adb shell echo >/dev/null || return

	local androidWlanInterface=$($getprop wifi.interface | $dos2unix)
	local adbGetWlanIP=$($adb shell ip -o addr show $androidWlanInterface | awk -F ' *|/' '/inet /{print$4}' | $dos2unix)

	local currentADBTcpPortNum=$($getprop service.adb.tcp.port)
	if echo $currentADBTcpPortNum | \egrep -q "[0-9]+";then
		echo "[ $FUNCNAME ] => INFO : The <service.adb.tcp.port> parameter is already set to $currentADBTcpPortNum." >&2
		set -x;$adb tcpip $currentADBTcpPortNum;set +x
		return 4
	fi

	set +x
	$adb tcpip $port
	sleep 1
	$adb connect $adbGetWlanIP:$port | grep -w connected && echo "[ $FUNCNAME ] => INFO : You can now unplugg the USB cord and run your <adb shell> commands." >&2
	sleep 2
	if $adb devices | grep -w offline || $adb shell echo 2>&1 | grep 'more than one';then
		echo "[ $FUNCNAME ] => INFO : You need to unplug your USB cord." >&2
		return 5
	fi
	$adb shell echo >/dev/null || echo "[ $FUNCNAME ] => INFO : If the <adbd> service could not restart automatically, you need to re-enable <USB Debugging> on the android device manually." >&2
	set +x
}

set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
