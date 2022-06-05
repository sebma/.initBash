# vim: set ft=sh noet:

! declare 2>&1 | grep -wq ^colors= && [ $BASH_VERSINFO -ge 4 ] && source $initDir/.colors
test "$debug" -gt 0 && echo "=> Running $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal ..."

#alias processUsage="printf ' RSS\t       %%MEM %%CPU  COMMAND\n';\ps -e -o rssize,pmem,pcpu,args | sort -nr | cut -c-156 | head -500 | awk '{printf \"%9.3lf MiB %4.1f%% %4.1f%% %s\n\", \$1/1024, \$2,\$3,\$4}' | head"
#alias ssh="\ssh -A -Y -C"
#sdiff -v 2>/dev/null | grep -qw GNU && alias sdiff='\sdiff -Ww $(tput cols 2>/dev/null)' || alias sdiff='\sdiff -w $(tput cols 2>/dev/null)'

#alias reset="\reset;\printf '\33c\e[3J'"
#type -P vim >/dev/null && alias vim="LANG=$(locale -a 2>/dev/null | egrep -i '(fr_fr|en_us|en_uk).*utf' | sort -r | head -1) \vim" && alias vi=vim
#alias wget='wget2 || wget1'

alias .....="cd ../../../.."
alias ....="cd ../../.."
alias ...="cd ../.."
alias ..="cd .."
alias 2iec='\numfmt --to=iec-i --suffix=B --format=%.1f'
alias 2lower=tolower
alias 2si='\numfmt  --to=si    --suffix=B --format=%.1f'
alias 2upper=toupper
alias Cut='\cut -c 1-$COLUMNS'
alias Pgreplast="greplast -P"
alias _2spaces="sed 's/[_-]/ /g'"
alias acp='\advcp -gpuv'
alias amv='\advmv -gvi'
alias any2dos="\perlSed 's/\R/\r\n/g'"
alias any2man="\pandoc -s -t man"
alias any2unix="\perlSed 's/\R/\n/'"
alias arch="arch 2>/dev/null || uname -m"
alias arp="\ip -4 neigh"
alias arpShow="\ip -4 neigh show"
alias audioInfo="\mplayer -identify -vo null -ao null -frames 0"
alias audioRenameFromTags=renameFromTags
alias bc="\bc -l"
alias binxi="\binxi -c17 -z"
alias binxiSummary="binxi -SMBmCGANEdPjsIJ -xx"
alias bthctl=bluetoothctl
alias brewUnInstall='\bash -c "$(\curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"'
alias brewUpdate="time \brew update -v"
alias burnaudiocd='\burnclone'
alias burncdrw='\cdrecord -v -dao driveropts=burnfree fs=14M speed=12 gracetime=10 -eject'
alias burnclone='\cdrecord -v -clone -raw driveropts=burnfree fs=14M speed=16 gracetime=10 -eject -overburn'
alias burniso='\cdrecord -v -dao driveropts=burnfree fs=14M speed=24 gracetime=10 -eject -overburn'
alias bzgrep="\bzgrep --color"
alias bzip2="\bzip2 -v"
alias calcSigs="time $find . -type f -exec sha1sum {} \;"
alias cclive="\cclive -c"
alias cdda_info="\icedax -gHJq -vtitles"
alias cdinfo='\cdrdao disk-info'
alias cdrdao='\df | grep -q $CDR_DEVICE && umount $CDR_DEVICE ; \cdrdao'
alias cegrep="cgrep -E"
alias cget="\curl -O"
alias checkMyPrinterConnection="\ping -c2 192.168.1.1"
alias checkcer="\openssl x509 -noout -inform PEM -in"
alias checkcertif="\openssl verify -verbose"
alias checkcrt="\openssl x509 -noout -inform PEM -in"
alias checkder="\openssl x509 -noout -inform DER -in"
alias chmod="\chmod -v"
alias chown="\chown -v"
alias clearXFCESessions="\rm -fv ~/.cache/sessions/xf*"
alias clearurlclassifier3="$find . -type f -name urlclassifier3.sqlite -exec rm -vf {} \;"
alias closecd='\eject -t $CDR_DEVICE'
alias columns='\column -c $COLUMNS -t'
alias conky_restart=restart_conky
type -P xclip >/dev/null && alias copy2Clipboard="\xclip -i -selection clipboard" || alias copy2Clipboard="\xsel -bi"
alias cp2FAT32="rsync --modify-window=1"
alias cp2NTFS="rsync -ogpuv"
alias cp2NTFSPartition="rsync -ogpuv -x -r"
alias cp2SDCard="rsync --size-only"
alias cp2exFAT="rsync -ogpuv"
alias cp2exFATPartition="rsync -ogpuv -x -r"
alias cp2ext234="rsync -ogpuv -lSH"
alias cp2ext234Partition="rsync -ogpuv -lSH -x -r"
alias cp2ftpfs="\rsync -uth --progress --inplace --size-only"
alias cpanRepair="cpan -f -i Term::ReadLine::Gnu"
alias cpuUsage="mpstat 1 1 | awk 'END{print 100-\$NF\"%\"}'"
alias cssSelect='hxselect -s "\n"'
alias ct=cleartool
alias curl="\curl -L" && alias curlnoconfig="\curl -q"
alias curlResposeCode="\curl -sw "%{http_code}" -o /dev/null"
alias d="\du -sh *"
alias da="\du -sh * .??*"
alias dbus-halt='\dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop'
alias dbus-hibernate='\dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate'
alias dbus-logout-force-kde='\qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout 0 0 0'
alias dbus-logout-gnome='dbus-send --session --type=method_call --print-reply --dest=org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.Logout uint32:1'
alias dbus-logout-kde='\qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1'
alias dbus-reboot='\dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart'
alias dbus-suspend='\dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend || \dbus-send --system --print-reply --dest="org.freedesktop.login1" /org/freedesktop/login1 org.freedesktop.login1.Manager.Suspend boolean:true'
alias deborphan="\deborphan | sort"
alias dig="\dig +search +short"
alias disconnectB206_BT_From_DAC="ssh b206.local. myScripts/shl/bluetoothDisconnectAllBlueZ5.sh"
alias document2doc="libreofficeTo doc"
alias document2docx="libreofficeTo docx"
alias document2fodt="libreofficeTo fodt"
alias document2odt="libreofficeTo odt"
alias document2pdf="libreofficeTo pdf"
alias presentation2fodp="libreofficeTo fodp"
alias presentation2odp="libreofficeTo odp"
alias presentation2ppt="libreofficeTo ppt"
alias presentation2pptx="libreofficeTo pptx"
alias presentation2pdf="libreofficeTo pdf"
alias sheet2fods="libreofficeTo fods"
alias sheet2ods="libreofficeTo ods"
alias sheet2pdf="libreofficeTo pdf"
alias sheet2xls="libreofficeTo xls"
alias sheet2xlsx="libreofficeTo xlsx"
alias dos2unix="\sed -i 's/\r//'"
alias doublons='\fdupes -rnASd'
alias driveinfo='\cdrecord -prcap'
alias du="LANG=C \du -h"
alias dvdinfo='\cdrecord -minfo'
alias egrepfirst="grepfirst -E"
alias egreplast="greplast -E"
alias ejectcd='\eject $CDR_DEVICE'
alias enman="\man -L en"
alias erasecd='\cdrecord -v speed=12 blank=fast gracetime=10 -eject'
alias erasewholecd='\cdrecord -v speed=12 blank=all gracetime=10 -eject'
alias errors="egrep -wiC2 'err:|:err|error|erreur|java.*exception'"
alias findFunctions="grep -P '(^| )\w+\(\)|\bfunction\b'"
alias findSpecialFiles="$find . -xdev '(' -type b -o -type c -o -type p -o -type s ')' -a -ls"
alias findbin='$find $(echo $PATH | tr : "\n" | \egrep "/(s?bin|shl|py|rb|pl)") /system/{bin,xbin} 2>/dev/null | egrep'
alias findcrlf="\grep -slr "
alias fprintMostSupportedDevices="fprintSupportedDevices | awk '{print\$2}' | sort | uniq -c | sort -nr"
alias fprintSupportedDevices="\curl -s https://fprint.freedesktop.org/supported-devices.html | html2text.py | tail -n +10 | \grep -v '^$' | \sed -zr 's/([a-f0-9]{4}:[a-f0-9]{4})\n/\1 /g'"
alias free="\free -m"
alias frman="\man -Lfr"
alias ftp="\pftp" # Passive FTP
alias fuser="\fuser -v"
alias fuserumount="\fusermount -u"
alias gateWay="\route -n | awk '/^(0.0.0.0|default)/{print\$2}'"
alias gateWayFQDN='\dig +short -x $(gateWay)'
alias gateWayOPEN='open https://$(gateWayFQDN)'
alias gateWayURL='echo https://$(gateWayFQDN)'
alias gdmlogout="\gnome-session-quit --force"
alias geoipjson="( \curl -sLA '' freegeoip.app/json 2>/dev/null || \wget -qU '' -O- freegeoip.app/json ) | jq"
alias geoipjson2="( \curl -sA '' ipinfo.io/json 2>/dev/null || \wget -qU '' -O- ipinfo.io/json ) | jq"
alias geoipv4="geoipjson2 .ip -r"
alias geoipv6="geoipjson .ip -r"
alias geoipAS="geoipjson2 .org -r"
alias geoipCity="geoipjson '.city+\" \"+.country_code' -r"
alias geoipHostname="geoipjson2 .hostname -r"
alias getFS_TYPE="\blkid -o value -s TYPE"
alias getPip="wget -qO- https://bootstrap.pypa.io/get-pip.py | python"
alias getUUID="\blkid -o value -s UUID"
alias grepInHome="time \grep --exclude-dir=Audios --exclude-dir=Music --exclude-dir=Podcasts --exclude-dir=Videos --exclude-dir=Karambiri --exclude-dir=iso --exclude-dir=Downloads --exclude-dir=Documents --exclude-dir=src --exclude-dir=Pictures --exclude-dir=.thunderbird --exclude-dir=deb --exclude-dir=apks --exclude-dir=.mozilla --exclude-dir=.PlayOnLinux --exclude-dir=PlayOnLinux\'s\ virtual\ drives --exclude-dir=.cache --exclude-dir=Sauvegarde_MB525 --exclude-dir=A_Master_RES --exclude-dir=SailFishSDK --exclude=.*history"
alias grepfirst="grep -m1"
alias grepfirst="grepfirst -P"
alias grub-emu="xterm -e grub-emu"
alias gtop="\watch -n1 gps"
alias gunzip="\gunzip -Nv"
alias gzcat="\gunzip -c"
alias gzgrep="zgrep"
alias gzip="\gzip -Nv"
alias h5dump="\h5dump -n 1"
alias halt="\halt && exit"
alias headlines='\head -n $((LINES-2))'
alias hexdump="\hexdump -Cc" || alias hexdump="\od -tx1z"
alias highlight="\highlight -O ansi --force"
alias html2json="\pup 'json{}'"
alias html2jsonXIDEL="\xidel -s --output-format=json-wrapped -e //html"
alias html2xml=html2xml_via_xmllint
alias html2xml_via_xmllint="\xmllint --html --format --recover --xmlout"
alias html2xml_via_xmlstarlet="\xmlstarlet format --quiet --html --recover"
alias htmldecode="perl -MHTML::Entities -pe 'decode_entities(\$_)'"
alias htmlencode="perl -MHTML::Entities -pe 'encode_entities(\$_)'"
alias imageInfo="\identify -ping -format '=> %f\nFormat: %m\nPixels: %w x %h\nDensity: %x x %y\nImage Resolution Units: %U\n'"
alias install="\install -pv"
alias integer="$local -i"
alias inxi="LC_ALL=C \inxi -z -c2"
alias inxiSummary="inxi -SMBmCGANEdPjsIJ -xx"
alias ip@=lanip
alias ipNeighbours="ip neighbour | column -t"
alias is32or64bits='\getconf LONG_BIT'
alias jpeg2pdf="\convert +density"
alias jpeg2pdfA4="jpeg2pdf -page A4"
alias jpeg2pdfA4R="jpeg2pdf -page 842x595"
alias jpeg2pdfletter="jpeg2pdf -page letter"
alias jpeg2pdfletterR="jpeg2pdf -page 792x612"
alias jpegRotate=jpgRotate
alias jpg2pdf=jpeg2pdf
alias jpg2pdfA4=jpeg2pdfA4
alias jpg2pdfA4R=jpeg2pdfA4R
alias jpg2pdfletter=jpeg2pdfletter
alias jpg2pdfletterR=jpeg2pdfletterR
alias killall="\killall -v"
alias kshOldVersion="strings $(type -P ksh) | grep Version | tail -2"
alias kshVersion='ksh -c "echo \$KSH_VERSION" 2>/dev/null'
alias l1="ls -1"
alias lastfiles='$find . -xdev -type f -mmin -2'
alias lastloggin='\lastlog -u $USER'
alias less="\less -ir"
alias libreofficeTo="\lowriter --headless --convert-to"
alias lkshVersion='lksh -c "echo \$KSH_VERSION" 2>/dev/null'
alias ll="ls -lF"
alias lla="ll -a"
alias llah="ll -ah"
alias lld="ll -d"
alias llh="ll -h"
alias llha="ll -ha"
alias ln="\ln -v"
alias loadsshkeys='eval $(keychain --eval --agents ssh)'
alias loffice=soffice
alias lobase="loffice --base"
alias localc="loffice --calc"
alias lodraw="loffice --draw"
alias loimpress="loffice --impress"
alias lomath="loffice --math"
alias loquickstart="loffice --quickstart"
alias loweb="loffice --web"
alias lowriter="loffice --writer"
alias lofromtemplate="loffice .uno:NewDoc"
alias lpq="\lpq -a +3"
alias lpr2ppsheet="\lpr -o number-up=2"
alias ls="ls -F"
alias lsb_release="\lsb_release -s"
alias lsdvd="\lsdvd -avcs"
alias lshw="\lshw -numeric -sanitize"
alias lshwBUSINFO='lshw -businfo'
alias lsqm='dspmq | sed "s/[()]/ /g" | awk "/Running/{print \$2}" | paste -sd" ";echo'
alias lxterm="\lxterm -sb -fn 9x15"
alias lzgrep="\lzgrep --color"
alias man2ps="\man -Tps"
alias manen=enman
alias manfile="\man -l"
alias manfr=frman
alias mdns-browse="\avahi-browse -t -k -p"
alias mdns-service-db="\avahi-browse -b -k | sort"
alias memInfo=ramInfo
alias memOccupation='\smem -t -c "user pid swap pss rss uss vss command" -k -p -a -s rss'
alias memSnapshot='\smem -t -c "user pid swap pss rss uss vss command" -k -p -a -s command'
alias mkdir="\mkdir -pv"
alias mkshVersion='mksh -c "echo \$KSH_VERSION" 2>/dev/null'
alias mount="mount -v"
alias mountfreebox="mount | \grep -wq freebox-server || curlftpfs 'freebox@freebox-server.local/Disque dur' /mnt/freebox/ ; mount | \grep -w freebox-server"
alias mountfreeboxanna="mount | \grep -wq freeboxanna || curlftpfs 'freebox@78.201.68.5/Disque dur' /freeboxanna/ ; mount | \grep -w freeboxanna"
alias mp3RenameFromTags=renameFromTags
alias mpath='\echo $PATH | tr ":" "\n"'
alias mutt="LANG=C.UTF-8 \mutt"
alias muttDebug="LANG=C.UTF-8 \mutt -nd5"
alias mv2FAT32="cp2FAT32 --remove-source-files"
alias mv2NTFS="cp2NTFS --remove-source-files"
alias mv2SDCard="cp2SDCard --remove-source-files"
alias mv2exFAT="cp2exFAT --remove-source-files"
alias mv2ext234="cp2ext234 --remove-source-files"
alias mv2ftpfs="cp2ftpfs --remove-source-files"
alias mv='\mv -vi'
alias myCity="time curl ipinfo.io/city"
alias myCountry="time curl ipinfo.io/country"
alias myIP="time curl ipinfo.io/ip"
alias nautilus="\nautilus --no-desktop"
alias no='yes n'
alias nocomment="egrep -v '^(#|$)'"
alias od="\od -ctx1z"
alias openedFiles="\strace -e trace=open,close,read,write,connect,accept"
alias openwrtMostSupportedRouterBrands="openwrtTOH | awk '/ Router/{print\$4}' | sort | uniq -c | sort -rn"
alias openwrtSupportedRouters="openwrtTOH | awk '/ Router/{for(i=4;i<=5;i++)printf\$i\" \";print\$i}'"
alias openwrtTOH="\curl -sIf -o /dev/null https://openwrt.org/_media/toh_dump_tab_separated.gz && \curl -s https://openwrt.org/_media/toh_dump_tab_separated.gz | \gunzip -c"
alias osFamily='echo $OSTYPE | grep android || uname -s'
alias page="\head -50"
alias paperSizeInDots="\paperconf -s -N"
alias paperSizeInPixels=paperSizeInDots
alias paperSizeInCM="paperSizeInDots -c"
alias paperSizeInMM="paperSizeInDots -m"
alias paperSizeInInches="paperSizeInDots -i"
alias paperSizesInDots="\paperconf -s -N -a"
alias paperSizesInPixels=paperSizesInDots
alias paperSizesInCM="paperSizesInDots -c"
alias paperSizesInMM="paperSizesInDots -m"
alias paperSizesInInches="paperSizesInDots -i"
alias patchCreate="\diff -Nau"
alias pcmanfm="\pcmanfm --no-desktop"
alias pdfjamhelp="\pdfjam --help | less"
alias pdkshVersion='pdksh -c "echo \$KSH_VERSION" 2>/dev/null'
alias perlInterpreter="\perl -de ''"
alias perlScript="\perl -n -ale"
alias perlSed="\perl -pe"
alias perlfunc="\perldoc -f"
alias phpInterpreter="\php -a"
alias pic2pdf=jpeg2pdf
alias pic2pdfA4=jpeg2pdfA4
alias pic2pdfA4R=jpeg2pdfA4R
alias port="lsof -ni -P | grep LISTEN"
alias ports="lsof -ni -P | grep LISTEN"
alias pps2pdf=odp2pdf
alias ppsx2pdf=odp2pdf
alias ppt2pdf=odp2pdf
alias pptx2pdf=odp2pdf
alias prettyjson='\python -m json.tool'
alias psu='ps -u $USER -O user:12,ppid,pcpu,pmem,start'
alias pup2json="\pup 'json{}'"
alias putty='\putty -geometry 157x53 -l $USER -t -A -C -X'
alias qrdecode="\zbarimg -q --raw"
alias ramInfo="inxi -mx"
alias rcp="\rsync -uth -P"
alias rdesktop="\rdesktop -k fr"
alias rdiff="diff -rq"
alias recode="\recode -v"
alias regrep="rgrep -EI"
alias renameFromTags="\kid3-cli -c 'fromtag \"%{track}__%{album}__%{title}\" 2'"
alias rename_without_spaces='rename "s/ /_/g"'
alias repeat="\watch -n1"
alias res=screenResolution
alias reset="\clear;\clear;\reset"
alias resize2fs="\resize2fs -p"
alias resolution="\identify -ping -format '%f : %x x %y\n'"
alias restore_my_stty="\stty erase ^?"
alias rm="\rm -i"
alias rpml="\rpm --root ~/local -Uvh"
alias rpmt="\rpm --test"
alias rsync2SDCard="rsync --size-only"
alias rsyncMove="rsync --remove-source-files"
alias rubyInterpreter="\irb"
alias scp_unix='time \rsync -h --progress --rsync-path=$HOME/gnu/bin/rsync -ut'
alias screenDPI=$'xdpyinfo | awk \'/dots per inch/{$1="";sub("^ ","");print}\''
alias screenDPI_Calculated=$'xrandr | awk -F "[ x+]" \'/ connected/{gsub("mm","");print$4*25.4/$(NF-3)" dpi x "$5*25.4/$NF" dpi"}\''
alias screenDiagonal=$'xrandr | awk \'/ connected/{print sqrt( ($(NF-2)/10)^2 + ($NF/10)^2 )/2.54" inches"}\''
alias screenInfo='xdpyinfo | egrep "dimensions:|resolution:|depths.*:|depth.*root"'
alias screenResolution=$'xrandr | awk \'/\*/{print$1}\''
alias screenSize=$'xrandr | awk \'/ connected/{print$(NF-2)" x "$NF}\''
alias sdiff='\sdiff -w $COLUMNS'
alias sink-inputs='\pactl list sink-inputs short'
alias sinks='\pactl list sinks short'
alias sortip="\sort -nt. -k1,1 -k2,2 -k3,3 -k4,4"
alias sources="grep -woP '[Ss]ource\s[^{ ]*\"?'"
alias spaces2_="sed 's/ /_/g'"
alias speedtestSimple="time \speedtest --simple"
alias sshStatusLocalForward="command ssh -O check"
alias sshStopLocalForward="command ssh -O exit"
alias startSSHAgent='\pgrep -lfu $USER ssh-agent || eval $(ssh-agent -s)'
alias sudo="\sudo "
alias swapUsage="\free -m | awk '/^Swap/{print 100*\$3/\$2}'"
alias systemType='strings $(\ps -p 1 -o cmd= | cut -d" " -f1) | \egrep -o "upstart|sysvinit|systemd" | head -1'
alias taillines='\tail -n $((LINES-2))'
alias tcpPorts="\netstat -ntl"
alias terminfo='echo "=> C est un terminal $(tput cols 2>/dev/null)x$(tput lines 2>/dev/null)."'
alias thunderbirdUnlock='\ps -C thunderbird >/dev/null || rm ~/.thunderbird/default/lock'
alias timestamp='\date +"%Y%m%d_%HH%M"'
alias today="$find . -type f -ctime -1"
alias tolower="awk '{print tolower(\$0)}'"
alias tolowerPerl="\perl -pe 'tr/A-Z/a-z/'"
alias tolowerSed="sed 's/.*/\L&/'"
alias topd10="topd $((10+1))"
alias topd5="topd $((5+1))"
alias topd="\du -cxhd 1 2>/dev/null | grep -v '\s*\.$' | sort -hr | head -n"
alias topdlines='topd $(($LINES-2))'
alias toupper="awk '{print toupper(\$0)}'"
alias toupperPerl="\perl -pe 'tr/a-z/A-Z/'"
alias toupperSed="sed 's/.*/\U&/'"
alias traceroute="\traceroute -I"
alias ulogerrors="egrep -iB4 -A1 'error|erreur|Err: [^0]'"
alias ulogtodayerrors="egrep -iB4 -A1 'error|erreur|Err: [^0]' $ulog"
alias url2qrcode=string2qrcode
alias umask="\umask -S"
alias umount="umount -v"
alias uncompress="\uncompress -v"
alias uncpio="\cpio -idcmv <"
alias unix2dos="\sed -i 's/$/\r/'"
alias unjar='\unjar || \unzip'
alias untar='\untar || \tar -xvf'
alias unzipFromPipeToStdout="\zcat"
alias updateBrew="time \brew update -v"
alias updatePip="pip install -U pip"
alias updateThumbnails="\exiftran -gpi"
alias updateYoutube-dl="pip install -U youtube-dl"
alias uuidGet="\blkid -o value -s UUID"
alias venv="\python3 -m venv"
alias vict2c="vim +'setf xml' $LOGDIR/ct2c.log"
alias vidInfo=videoInfo
alias view='vim -R'
alias viewcer="\openssl x509 -noout -text -inform DER -subject -issuer -dates -purpose -nameopt multiline -in"
alias viewcrt="viewcer"
alias viewcsr="\openssl req -noout -text -inform PEM -in"
alias viewder="\openssl x509 -noout -text -inform DER -in"
alias viewpem="\openssl x509 -noout -text -inform PEM -subject -issuer -dates -purpose -nameopt multiline -in"
alias vihistory='\vim ~/.bash_history'
alias vim="LANG=C.UTF-8 \vim" && alias vi=vim
alias vimatlab="vim +'setf matlab'"
alias vioctave=vimatlab
alias vlclocal='DISPLAY=:0 vlc'
alias wanIP="\dig -4 +short @resolver1.opendns.com A myip.opendns.com 2>/dev/null || time host -4 -t A myip.opendns.com resolver1.opendns.com | awk '/\<has\>/{print\$NF}'"
alias wanIPv6="\dig -6 +short @resolver1.opendns.com AAAA myip.opendns.com 2>/dev/null || time host -6 -t AAAA myip.opendns.com resolver1.opendns.com | awk '/\<has\>/{print\$NF}'"
alias wavemon="xterm -e wavemon &"
alias web2pdf='wkhtmltopdf --no-background --outline --header-line --footer-line --header-left [webpage] --footer-left "[isodate] [time]" --footer-right [page]/[toPage]'
alias wegrep="wgrep -E"
alias wget1='\wget'
alias wget2noconfig="\wget2 --no-config"
alias wgetnoconfig="\wget --config=/dev/null"
alias which="\type -P"
alias xargs="\xargs -ri"
alias xclock="\xclock -digital -update 1"
alias xfree="\xterm -geometry 73x5 -e watch -n2 free -m &"
alias xlock="\xdg-screensaver lock"
alias xmlsh="\xmllint --shell"
alias xpath="\xmllint --xpath"
alias xprop='\xprop WM_CLASS _NET_WM_PID WM_ICON_NAME'
alias xterm="\xterm -bc -fn 9x15 -geometry 144x40 -sb"
alias xwinDPI="xdpyinfo | awk '/resolution:/{print\$2}'"
alias xwinProcessInfo="\ps -fp \$(\xprop _NET_WM_PID | awk -F'=' '/_NET_WM_PID/{print\$NF}')"
alias xwinResolution="xdotool selectwindow getwindowgeometry | awk '/Geometry:/{print\$NF}'"
alias xwinSize=$'xwininfo | awk \'/geometry/{gsub("[+-].+","",$2);print$2}\''
alias xz="\xz -v"
alias xzgrep="\xzgrep --color"
alias ytGetAudio="\youtube-dl -x -f 249/250/251/171/m4a"
alias zgrep="\zgrep --color"
alias zip="\zip -vr"
egrep --help 2>&1 | \grep -qw "\--color" && alias egrep="egrep --color"
grep  --help 2>&1 | \grep -qw "\--color" && alias grep="grep --color"
uname -s | grep -q AIX && alias stat="istat"

set +x
test "$debug" -gt 0 && \echo "=> END of $bold${colors[blue]}$(basename ${BASH_SOURCE[0]})$normal"
