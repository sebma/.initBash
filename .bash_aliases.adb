# vim: set ft=sh noet:
! declare 2>&1 | grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

adb=$(type -P adb)
dos2unix="$(type -P tr) -d '\r'"
getprop="$adb shell getprop"
alias adb_getprop="$getprop"
alias adb_getprop_grep="$getprop | $dos2unix | grep -P"
alias adbCpuInfo="$adb shell cat /proc/cpuinfo | $dos2unix"
alias adbMemInfo="$adb shell cat /proc/meminfo | $dos2unix"
alias adbBuildInfo="$adb shell cat /system/build.pro | $dos2unix"
alias adbEnablePackage="$adb shell pm enable"
alias adbFindPackages="$adb shell pm list packages"

alias adbGetADBTcpPort="$getprop service.adb.tcp.por | $dos2unix"
alias adbGetAndroidSDK="$getprop ro.build.version.sdk | $dos2unix"
alias adbGetAndroidVersion="$getprop ro.build.version.release | $dos2unix"
alias adbGetArch="$getprop ro.product.cpu.abi | $dos2unix"

alias adbGetBatteryLevel="$adb shell dumpsys battery | grep level | $dos2unix"
alias adbGetBrand="$getprop ro.product.brand | $dos2unix"
alias adbGetDeviceCodeName="$getprop ro.product.device | $dos2unix"

alias adbGetExtSDCardMountPoint="$adb shell mount | awk '/emulated|sdcard0/{next}/(Removable|storage)\//{if(\$2==\"on\")print\$3;else print\$2} | $dos2unix"
alias adbGetManufacturer="$getprop ro.product.manufacturer | $dos2unix"
alias adbGetModel="$getprop ro.product.model | $dos2unix"
alias adbGetWlanInterface="$getprop wifi.interface 2>/dev/null | $dos2unix"

if [ -n "$androidWlanInterface" ];then
	alias adbGetWlanIP="{ $getprop dhcp.${androidWlanInterface/:*/}.ipaddress | \grep [0-9] || $adb shell ip -o addr show $androidWlanInterface | awk -F ' *|/' '/inet /{print\$4}'; } | $dos2unix"
	alias adbGetWlanMAC="$adb shell cat /sys/class/net/${androidWlanInterface/:*/}/addres | $dos2unix"
fi

alias adbGetProp="$getprop"
alias adbGetPropGrep="$getprop | $dos2unix | grep -P"
alias adbGetSerial="$getprop ro.serialno | $dos2unix"

set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
