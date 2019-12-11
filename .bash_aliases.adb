# vim: set ft=bash noet:
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

export adb=$(which adb)
export dos2unix="$(which tr) -d '\r'"
alias adb_getprop="$adb shell getprop"
alias adbFindPackages="$adb shell pm list packages -f -i"
alias adbGetADBTcpPort="$adb shell getprop service.adb.tcp.port"
alias adbGetAndroidVersion="$adb shell getprop ro.build.version.release | $dos2unix"
alias adbGetArch="$adb shell getprop ro.product.cpu.abi | $dos2unix"
alias adbGetBatteryLevel="$adb shell dumpsys battery | grep level | $dos2unix"
alias adbGetBrand="$adb shell getprop ro.product.brand | $dos2unix"
alias adbGetCodeName="$adb shell getprop ro.product.device | $dos2unix"
alias adbGetExtSDCardMountPoint="$adb shell mount | awk '/emulated|sdcard0/{next}/(Removable|storage)\//{if(\$2==\"on\")print\$3;else print\$2}'"
alias adbGetManufacturer="$adb shell getprop ro.product.manufacturer | $dos2unix"
alias adbGetModel="$adb shell getprop ro.product.model | $dos2unix"

alias adbGetNetworkInterface="$adb shell getprop wifi.interface | $dos2unix"
$adb shell echo >/dev/null 2>&1 && export androidDeviceNetworkInterface=$(adbGetNetworkInterface)
if [ -n "$androidDeviceNetworkInterface" ];then
	alias adbGetNetworkIP="$adb shell ip -o addr show $androidDeviceNetworkInterface | awk -F ' *|/' '/inet /{print\$4}' | $dos2unix"
fi

alias adbGetSDK="$adb shell getprop ro.build.version.sdk | $dos2unix"
alias adbGetSerial="$adb shell getprop ro.serialno | $dos2unix"
function adbSetADBTcpPort {
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

	local androidDeviceNetworkInterface=$($adb shell getprop wifi.interface | $dos2unix)
	local adbGetNetworkIP=$($adb shell ip -o addr show $androidDeviceNetworkInterface | awk -F ' *|/' '/inet /{print$4}' | $dos2unix)

	if $adb shell getprop | \egrep -q "service.adb.tcp.port.*[0-9]+";then
		local currentADBTcpPortNum=$($adb shell getprop service.adb.tcp.port)
		echo "[ $FUNCNAME ] => INFO : The <service.adb.tcp.port> parameter is already set to $currentADBTcpPortNum." >&2
		return 4
	fi

	set +x
	$adb tcpip $port
	sleep 1
	$adb connect $adbGetNetworkIP:$port | grep -w connected && echo "[ $FUNCNAME ] => INFO : You can now unplugg the USB cord and run your <adb shell> commands." >&2
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
