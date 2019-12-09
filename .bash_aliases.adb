# vim: set ft=bash noet:
declare -A | grep -wq colors || source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

which adb >/dev/null 2>&1 && {
export adb=$(which adb)
export dos2unix="$(which tr) -d '\r'"
alias adbFindPackage="$adb shell pm list packages -f -i"
alias adbGetAndroidVersion="$adb shell getprop ro.build.version.release | $dos2unix"
alias adbGetArch="$adb shell getprop ro.product.cpu.abi | $dos2unix"
alias adbGetBatteryLevel="$adb shell dumpsys battery | grep level | $dos2unix"
alias adbGetBrand="$adb shell getprop ro.product.brand | $dos2unix"
alias adbGetCodeName="$adb shell getprop ro.product.device | $dos2unix"
alias adbGetManufacturer="$adb shell getprop ro.product.manufacturer | $dos2unix"
alias adbGetModel="$adb shell getprop ro.product.model | $dos2unix"
alias adbGetNetworkIP="$adb shell ip -o addr | egrep -v '(127.0.0.|169.254.0|inet6|loopback)' | awk -F ' *|/' '/inet /{print\$4}' | $dos2unix"
alias adbGetNetworkInterface="$adb shell ip -o addr | egrep -v '(127.0.0.|169.254.0|inet6|loopback)' | awk '/inet /{print\$2}' | $dos2unix"
alias adbGetSDK="$adb shell getprop ro.build.version.sdk | $dos2unix"
alias adbGetSerial="$adb shell getprop ro.serialno | $dos2unix"
}
set +x
test "$debug" -gt 0 && echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
