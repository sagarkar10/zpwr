#!/usr/bin/env bash
#{{{                    MARK:Header
#**************************************************************
#####   Author: JACOBMENKE
#####   Date: Wed May 31 22:54:32 EDT 2017
#####   Purpose: bash script for custom terminal setup
#####   Notes: goal - work on mac and linux
#####   Notes: this script should a one liner installer
#}}}***********************************************************
#{{{                    MARK:zinit
#**************************************************************
export ZPWR_PLUGIN_MANAGER_HOME="$HOME/.zinit"
export ZPWR_PLUGIN_MANAGER="zinit"
# do not want any surprises when relative cd to other dirs
unset CDPATH
declare zpwrBaseDir

VERSION="2.1.0"
# resolve all symlinks
ZPWR_PWD="$(pwd -P)"
#}}}***********************************************************

#{{{                    MARK:Env vars
#**************************************************************

INSTALL_VIM_SRC=false

# shows count of steps in installer
INSTALL_COUNTER=0

# for the width of the install messages
export COLUMNS="$(tput cols)"

#}}}***********************************************************

#{{{                    MARK:sanity
#**************************************************************
# source common functions
if ! source common.sh; then
    echo "$ZPWR_PWD/common.sh source failed.  Are you in \$ZPWR/install directory?" >&2
    exit 1
fi

if [[ ! -d $ZPWR ]]; then
    echo "Must be in $ZPWR/install directory" >&2
    exit 1
fi
echo "installing to $ZPWR"

if [[ ! -d $ZPWR_LOCAL ]]; then
    echo "Must be in $ZPWR/install directory" >&2
    exit 1
fi

if [[ $ZPWR == "$ZPWR_PWD" ]]; then
    echo "Must be in $ZPWR/install directory" >&2
    exit 1
fi

if [[ ! -d $ZPWR_SCRIPTS ]]; then
    echo "Must be in $ZPWR/install directory" >&2
    exit 1
fi

ESCAPE_REMOVER="$ZPWR_SCRIPTS/escapeRemover.pl"
# the destination directory for zpwr specific installed files
LOGFILE="$ZPWR_INSTALLER_OUTPUT/escaped_logfile.txt"
LOGFILE_CARGO_YCM="$ZPWR_INSTALLER_OUTPUT/cargoYCM_logfile.txt"

if ! test -f "$ESCAPE_REMOVER"; then
    echo "where is ESCAPE_REMOVER '$ESCAPE_REMOVER'?" >&2
    exit 1
fi

if ! test -x "$ESCAPE_REMOVER"; then
    echo "why '$ESCAPE_REMOVER' not exe?" >&2
    exit 1
fi


BACKUP_DIR="$ZPWR_LOCAL/$USER.rc.bak.$(date +'%m.%d.%Y')"


zpwrCommandExists vim && vimV="$(vim --version | head -n 1 | awk '{print $5}')"
if [[ -n $vimV ]]; then
    if echo "$vimV >= 8.0" | bc 2>/dev/null | grep -q 1 || vim --version 2>&1 | grep -q '\-python3';then
        INSTALL_VIM_SRC=true
    fi
fi

#}}}***********************************************************

#{{{                    MARK:mkdir if needed
#**************************************************************
if [[ ! -d $ZPWR_INSTALLER_OUTPUT ]]; then
    mkdir -p $ZPWR_INSTALLER_OUTPUT
fi

if [[ ! -d $ZPWR_LOCAL ]]; then
    mkdir -p $ZPWR_LOCAL
fi

# the destination directory for zpwr specific temp files
if [[ ! -d $ZPWR_LOCAL_TEMP ]]; then
    mkdir -p $ZPWR_LOCAL_TEMP
fi
#}}}***********************************************************

#{{{                    MARK:Stream tee to LOGFILE
#**************************************************************
clear
# replicate stdout and sterr to LOGFILE
exec > >(tee -a "$LOGFILE")
exec 2>&1
#}}}***********************************************************

#{{{                    MARK:Banner
#**************************************************************
cat<<\EOF
    ...     ..      ..                                    ..                 
  x*8888x.:*8888: -"888:                            < .z@8"`                 
 X   48888X `8888H  8888                 u.    u.    !@88E                   
X8x.  8888X  8888X  !888>       .u     x@88k u@88c.  '888E   u         .u    
X8888 X8888  88888   "*8%-   ud8888.  ^"8888""8888"   888E u@8NL    ud8888.  
'*888!X8888> X8888  xH8>   :888'8888.   8888  888R    888E`"88*"  :888'8888. 
  `?8 `8888  X888X X888>   d888 '88%"   8888  888R    888E .dN.   d888 '88%" 
  -^  '888"  X888  8888>   8888.+"      8888  888R    888E~8888   8888.+"    
   dx '88~x. !88~  8888>   8888L        8888  888R    888E '888&  8888L      
 .8888Xf.888x:!    X888X.: '8888c. .+  "*88*" 8888"   888E  9888. '8888c. .+ 
:""888":~"888"     `888*"   "88888%      ""   'Y"   '"888*" 4888"  "88888%   
    "~'    "~        ""       "YP'                     ""    ""      "YP'    



    .....                                                                     
 .H8888888h.  ~-.                         .uef^"                              
 888888888888x  `>                      :d88E          u.    u.          u.   
X~     `?888888hx~      .u          .   `888E        x@88k u@88c.  ...ue888b  
'      x8.^"*88*"    ud8888.   .udR88N   888E .z8k  ^"8888""8888"  888R Y888r 
 `-:- X8888x       :888'8888. <888'888k  888E~?888L   8888  888R   888R I888> 
      488888>      d888 '88%" 9888 'Y"   888E  888E   8888  888R   888R I888> 
    .. `"88*       8888.+"    9888       888E  888E   8888  888R   888R I888> 
  x88888nX"      . 8888L      9888       888E  888E   8888  888R  u8888cJ888  
 !"*8888888n..  :  '8888c. .+ ?8888u../  888E  888E  "*88*" 8888"  "*888*P"   
'    "*88888888*    "88888%    "8888P'  m888N= 888>    ""   'Y"      'Y"      
        ^"***"`       "YP'       "P'     `Y"   888                            
                                              J88"                            
                                              @%                              
                                            :"                                
      ..                            .                  .x+=:.   
x .d88"                            @88>               z`    ^%  
 5888R          u.                 %8P                   .   <k 
 '888R    ...ue888b       uL        .         .u       .@8Ned8" 
  888R    888R Y888r  .ue888Nc..  .@88u    ud8888.   .@^%8888"  
  888R    888R I888> d88E`"888E` ''888E` :888'8888. x88:  `)8b. 
  888R    888R I888> 888E  888E    888E  d888 '88%" 8888N=*8888 
  888R    888R I888> 888E  888E    888E  8888.+"     %8"    R88 
  888R   u8888cJ888  888E  888E    888E  8888L        @8Wou 9%  
 .888B .  "*888*P"   888& .888E    888&  '8888c. .+ .888888P`   
 ^*888%     'Y"      *888" 888&    R888"  "88888%   `   ^"F     
   "%                 `"   "888E    ""      "YP'                
                     .dWi   `88E                                
                     4888~  J8%                                 
                      ^"===*"`                                  
EOF

#}}}***********************************************************

#{{{                    MARK:Setup deps
#**************************************************************
# Dependencies
# 1) neovim
# 2) tmux
# 3) lolcat in go
# 4) cmatrix
# 5) htop
# 6) cmake
# 7) youcompleteme
# 8) ultisnips
# 9) supertab
# 10) zinit
# 11) powerlevel10k prompt
# 12) pathogen
# 13) nerdtree
# 14) fzf
# 15) powerline
# 16) vim-airline
# 17) zsh
#etc

dependencies_ary=(subversion openssl moreutils cmake tig hexedit boxes tal iperf vim tmux chkrootkit wget cowsay cmatrix htop bpython sl mutt \
    screenfetch ccze htop figlet zsh docker.io docker erlang elixir links \
    rlwrap tor nvm nginx nmap mtr mytop tcpdump redis toilet mysql \
    mongodb postgresql jnettop iotop fping ctags texinfo lsof \
    whois weechat gradle ant maven telnet tree mc ocaml groovy slurm \
    bmon ruby parallel pssh shfmt global)

addDependenciesLinux(){
    dependencies_ary=(neovim pkg-config libclang1 clang llvm ${dependencies_ary[@]})
    dependencies_ary+=(python-pip inxi build-essential traceroute proxychains atop tcl mlocate php-bcmath php-mysql php-sockets \
        php-mbstring php-gettext nmon clamav gparted sysstat git reptyr iptraf dstat ecryptfs-utils at netatalk dnsutils ltrace zabbix-agent \
        lua5.1 lua5.1-dev rl-dev software-properties-common sysv-rc-conf afpfs-ng \
        samba samba-common scrot syslog-ng sshfs fuse tomcat8 golang xclip strace)
    }
addDependenciesArch(){
    dependencies_ary+=(cronie ncurses npm autoconf make the_silver_searcher go linux-headers net-tools)
}

addDependenciesSuse(){
    dependencies_ary=(python3-devel llvm-devel openssl-devel go ${dependencies_ary[@]})
    dependencies_ary+=(man gcc-c++ makeinfo autoconf openldap2-devel mariadb postgresql-server libcurl-devel net-snmp-devel \
        mysql-devel libevent-devel postgresql-devel fortune ruby-devel net-tools-deprecated \
        python3-pip curl libffi-devel grc libpcap-devel the_silver_searcher kernel-devel gcc libxml2-devel libxslt-devel)
    }

addDependenciesDebian(){
    dependencies_ary=(python3-dev libssl-dev ${dependencies_ary[@]})
    dependencies_ary+=(mysql-server mariadb-server gcc bc lib-gnome2-dev silversearcher-ag libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
        ncurses-dev libevent-dev libncurses5-dev libcairo2-dev libx11-dev \
        libxpm-dev libxt-dev \
        libperl-dev libpq-dev libpcap-dev fortunes ruby-dev \
        python3-pip libffi-dev libssl-dev grc automake whatweb)

    }

addDependenciesRedHat(){
    if [[ "$distroName" == centos ]]; then
        sudo yum install -y epel-release
    fi

    dependencies_ary=(python3-devel llvm-devel openssl-devel ${dependencies_ary[@]})
    dependencies_ary+=(gcc-c++ 'fortune-mod.*' mariadb-server clamav-update openldap-devel libcurl-devel net-snmp-devel mysql-devel libevent-devel libffi-devel mysql-server \
        python36-tools ncurses-devel libpcap-devel curses-devel automake the_silver_searcher kernel-devel postgresql-devel)
    }

addDependenciesFreeBSD(){
    dependencies_ary+=(go the_silver_searcher vim python3 gnome3 devel/ruby-gems)
}

addDependenciesMac(){
    dependencies_ary=(neovim macvim ${dependencies_ary[@]})
    dependencies_ary+=(tcl-tk httpie proxychains-ng s-search git ag automake autoconf fortune node the_silver_searcher \
        fswatch zzz ghc lua python readline reattach-to-user-namespace speedtest-cli aalib ncmpcpp mpd ctop hub ncurses tomcat ninvaders kotlin grails go)
}
#}}}***********************************************************

#{{{                    MARK:installer funcs
#**************************************************************

function usage(){

    echo "Usage :  $0 [options] [--]

    Options:
        -a  Install all dependencies
        -c  Copy just configs
        -n  Do not start tmux at end of installer
        -s  Skip main section
        -h  Display this message
        -v  Display script version"

}


function showDeps(){

    {
        printf "Installing ${#dependencies_ary[@]} packages on $distroName: "
        for dep in "${dependencies_ary[@]}" ; do
            printf "$dep "
        done
    } | zpwrPrettyPrintBoxStdin
    proceed
    bash "$ZPWR_SCRIPTS/zpwrBannerSleep.sh"
}

files=(.zshrc .tmux.conf .vimrc .ideavimrc .iftopcolors .iftop.conf .zpwr/.shell_aliases_functions.sh \
    conf.gls conf.df conf.ifconfig conf.mount .inputrc .zpwr/.powerlevel9kconfig.sh .my.cnf motd.sh)

dirs=(.zpwr/scripts .config/htop .config/powerline/themes/tmux)

function backup(){

    test -d "$BACKUP_DIR" || mkdir -p "$BACKUP_DIR"
    for file in ${files[@]} ; do
        test -f "$HOME/$file" && cp "$HOME/$file" "$BACKUP_DIR"
    done
    for dir in ${dirs[@]} ; do
        test -d "$HOME/$dir" && cp -R "$HOME/$dir" "$BACKUP_DIR"
    done
}

function warnOverwrite(){

    zpwrPrettyPrintBox "The following will be overwritten: .zshrc, .tmux.conf, .inputrc, .vimrc, .ideavimrc, .iftop.conf, .shell_aliases_functions.sh in $HOME"
    zpwrPrettyPrintBox "These files if they exist will be backed to $BACKUP_DIR"
    zpwrPrettyPrintBoxStdin <<EOF
The following directories if they exist will be backed to $BACKUP_DIR: 
$HOME/${dirs[0]},
$HOME/${dirs[1]},
$HOME/${dirs[2]}

EOF
    proceed
    backup

}

function warnSudo(){

    zpwrPrettyPrintBox "It is highly recommended to run 'sudo visudo' to allow noninteractive install.  This allows running sudo without a password.  The following line would be added to /etc/sudoers: <Your Username> ALL=(ALL) NOPASSWD:ALL"
    proceed

}

function pluginsinstall(){

    zpwrGoInstallerDir
    zpwrFileMustExist plugins_install.sh
    bash plugins_install.sh >> "$LOGFILE_CARGO_YCM" 2>&1 &
    PLUGIN_PID=$!
    zpwrPrettyPrintBox "Installing vim and tmux plugins in background @ $PLUGIN_PID"
}

function ycminstall(){

    zpwrGoInstallerDir
    zpwrFileMustExist ycm_install.sh
    bash ycm_install.sh >> "$LOGFILE_CARGO_YCM" 2>&1 &
    YCM_PID=$!
    zpwrPrettyPrintBox "Installing YouCompleteMe in background @ $YCM_PID"
}

function cargoinstall(){

    zpwrGoInstallerDir
    zpwrFileMustExist rustupinstall.sh
    bash rustupinstall.sh >> "$LOGFILE_CARGO_YCM" 2>&1 &
    CARGO_PID=$!
    echo $CARGO_PID
    zpwrPrettyPrintBox "Installing rustup for exa, fd and bat in background @ $CARGO_PID"
}
#}}}***********************************************************

#{{{                    MARK:Getopts
#**************************************************************
# opt flags
skip=false
justConfig=false
noTmux=false
fullInstall=false
while getopts ":hnvsca" opt
do
    case $opt in

        h)  usage; exit 0   ;;

        v)  echo "$0 -- Version $VERSION"; exit 0   ;;

        a)  fullInstall=true ;;

        s)  skip=true ;;

        n)  noTmux=true ;;

        c)  justConfig=true ;;

        * )  echo -e "\n  Option does not exist : $OPTARG\n"
            usage; exit 1   ;;

        esac    # --- end of case ---
    done
    shift $(($OPTIND-1))

trap 'echo kill $YCM_PID $PLUGIN_PID $CARGO_PID; kill $YCM_PID $PLUGIN_PID $CARGO_PID 2>/dev/null;echo bye;exit' INT TERM HUP QUIT

if [[ $justConfig == true ]]; then
    zpwrPrettyPrintBox "Installing just configs"
fi

if [[ $skip == true ]]; then
    zpwrPrettyPrintBox "Skipping dependencies section"
fi


#}}}***********************************************************

#{{{                    MARK:macOS
#**************************************************************
if [[ "$ZPWR_OS_TYPE" == "darwin" ]]; then
    warnOverwrite
    warnSudo

    if [[ $justConfig != true ]]; then
        zpwrPrettyPrintBox "Checking Dependencies for Mac..."
        addDependenciesMac
        distroName=Mac
        distroFamily=mac
        showDeps

        if ! zpwrCommandExists brew; then
            # install homebrew
            zpwrPrettyPrintBox "Installing HomeBrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi

        if ! zpwrCommandExists brew; then
            zpwrPrettyPrintBox "Need Homebrew"
            exit 1
        fi

        zpwrPrettyPrintBox "We have Homebrew..."

        if ! command brew ls python > /dev/null 2>&1; then
            brew install python
            brew install pip
        fi

        zpwrPrettyPrintBox "We have Python..."

        if [[ $skip != true ]]; then
            zpwrPrettyPrintBox "Now The Main Course..."
            sleep 1

            zpwrPrettyPrintBox "Updating dependency list"
            zpwrInstallerRefresh "$distroFamily"
            zpwrPrettyPrintBox "Installing java"
            brew install --cask java
            zpwrPrettyPrintBox "Checking for curl before rustup install"
            zpwrExists curl || zpwrInstallerUpdate curl mac
            cargoinstall
            pluginsinstall

            # main loop
            for prog in "${dependencies_ary[@]}"; do
                zpwrPrettyPrintBox "Installing $prog"
                zpwrInstallerUpdate "$prog" mac
            done

            zpwrPrettyPrintBox "Upgrading packages"
            zpwrInstallerUpgrade mac
        fi

        zpwrPrettyPrintBox "Tapping Homebrew fonts"
        brew tap homebrew/cask-fonts
        zpwrPrettyPrintBox "Installing hack nerd font"
        brew install --cask font-hack-nerd-font

        zpwrPrettyPrintBox "Installing meteor"
        curl https://install.meteor.com/ | sh

        zpwrPrettyPrintBox "PostInstalling nodejs"
        brew postinstall node

        # system sed breaks extended regex
        ln -s /usr/local/bin/gsed /usr/local/bin/sed

        if test -f '/usr/local/share/zsh/site-functions/_git'; then
            zpwrPrettyPrintBox "Removing homebrew installed git zsh completion at /usr/local/share/zsh/site-functions/_git because conflicts with zsh's git completion"
            rm '/usr/local/share/zsh/site-functions/_git'
        fi

    fi
#}}}***********************************************************

#{{{                    MARK:Linux distros
#**************************************************************
elif [[ "$ZPWR_OS_TYPE" == "linux" ]]; then

    addDependenciesLinux
    distroName=$(perl -lne 'do{($_=$1)=~s/"//g;print;exit0}if/^ID=(.*)/' /etc/os-release)

    warnOverwrite
    warnSudo

    if [[ $justConfig != true ]]; then
        case $distroName in
            (debian | ubuntu* | pop* | elementary* | raspbian | kali | linuxmint | zorin | parrot)
                distroFamily=debian
                zpwrPrettyPrintBox "Fetching Dependencies for $distroName with the Advanced Package Manager..."
                addDependenciesDebian
                ;;
            (arch | endeavouros | garuda | manjaro*)
                distroFamily=arch
                zpwrPrettyPrintBox "Fetching Dependencies for $distroName with zypper"
                addDependenciesArch
                ;;
            (*suse*)
                distroFamily=suse
                zpwrPrettyPrintBox "Fetching Dependencies for $distroName with zypper"
                addDependenciesSuse
                ;;
            (centos | fedora | rhel | amzn)
                distroFamily=redhat
                zpwrPrettyPrintBox "Fetching Dependencies for $distroName with the Yellowdog Updater Modified"
                addDependenciesRedHat
                ;;
            (*)
                zpwrPrettyPrintBox "Your distroFamily $distroName is unsupported!" >&2
                exit 1
                ;;
        esac

        showDeps

        zpwrPrettyPrintBox "Updating dependency list"
        zpwrInstallerRefresh "$distroFamily"

        if [[ $skip != true ]]; then
            zpwrPrettyPrintBox "Now The Main Course..."
            sleep 1
            zpwrPrettyPrintBox "Checking for curl before rustup install"
            zpwrCommandExists curl || zpwrInstallerUpdate curl "$distroFamily"
            cargoinstall
            pluginsinstall
            # main loop
            for prog in "${dependencies_ary[@]}"; do
                zpwrPrettyPrintBox "Installing $prog"
                zpwrInstallerUpdate "$prog" "$distroFamily"
            done
            zpwrPrettyPrintBox "Upgrading $distroFamily"
            zpwrInstallerUpgrade "$distroFamily"
        fi

        zpwrPrettyPrintBox "Installing Powerline fonts"
        if [[ -d /usr/share/fonts ]] && [[ -d /etc/fonts/conf.d ]]; then
            zpwrGoInstallerOutputDir
            wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
            wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
            # move font to valid font path
            sudo mv PowerlineSymbols.otf /usr/share/fonts/
            # Update font cache for the path the font
            sudo fc-cache -vf /usr/share/fonts/
            # Install the fontconfig file
            sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/
        else
            zpwrPrettyPrintBox "/usr/share/fonts and /etc/fonts/conf.d must exist for powerline fonts." >&2
        fi
    fi
#}}}***********************************************************

#{{{                    MARK:other unix
#**************************************************************
else
    #unix
    if [[ "$ZPWR_OS_TYPE" == freebsd ]]; then
        distroFamily=freebsd
        distroName=FreeBSD

        warnOverwrite
        warnSudo

        if [[ $justConfig != true ]]; then
            zpwrPrettyPrintBox "Fetching Dependencies for $distroName with pkg"
            addDependenciesFreeBSD
            showDeps

            zpwrPrettyPrintBox "Updating dependency list"
            zpwrInstallerRefresh "$distroFamily"

            if [[ $skip != true ]]; then
                zpwrPrettyPrintBox "Now The Main Course..."
                sleep 1
                zpwrPrettyPrintBox "Checking for curl before rustup install"
                zpwrCommandExists curl || zpwrInstallerUpdate curl "$distroFamily"
                cargoinstall
                pluginsinstall

                # main loop

                for prog in "${dependencies_ary[@]}"; do
                    zpwrPrettyPrintBox "Installing $prog"
                    zpwrInstallerUpdate "$prog" "$distroFamily"
                done

                zpwrPrettyPrintBox "Upgrading $distroFamily"

                zpwrInstallerUpgrade "$distroFamily"
            fi

            zpwrPrettyPrintBox "Installing Powerline fonts"
            if [[ -d /usr/share/fonts ]] && [[ -d /etc/fonts/conf.d ]]; then
                wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
                wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
                # move font to valid font path
                sudo mv PowerlineSymbols.otf /usr/share/fonts/
                # Update font cache for the path the font
                sudo fc-cache -vf /usr/share/fonts/
                # Install the fontconfig file
                sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/
            else
                zpwrPrettyPrintBox "/usr/share/fonts and /etc/fonts/conf.d must exist for powerline fonts." >&2
            fi
        else
            zpwrPrettyPrintBox "Your OS $ZPWR_OS_TYPE is unsupported!" >&2
            exit 1
        fi

    fi

fi
#}}}***********************************************************


#{{{                    MARK:vim
#**************************************************************

zpwrPrettyPrintBox "Common Installer Section"

if [[ $justConfig != true ]]; then
    if [[ $INSTALL_VIM_SRC == true ]]; then
        #if neovim already installed, vim already points to neovim
        zpwrPrettyPrintBox "Vim Version less than 8.0 or without python! Installing Vim from Source."

        zpwrGoInstallerDir
        zpwrFileMustExist vim_install.sh
        source vim_install.sh
    fi

    zpwrGoInstallerDir

    zpwrCommandExists nvim || {
        zpwrFileMustExist neovim_install.sh
        source neovim_install.sh
    }

    zpwrGoInstallerDir
    zpwrFileMustExist npm_install.sh
    source npm_install.sh

    zpwrGoInstallerDir

fi

#}}}***********************************************************

#{{{                    MARK:Tmux
#**************************************************************
if [[ $justConfig != true ]]; then
    ycminstall

    zpwrGoInstallerDir
    zpwrFileMustExist pip_install.sh

    source pip_install.sh

    zpwrGoInstallerOutputDir

    zpwrPrettyPrintBox "Installing Pipes.sh from source"

    git clone https://github.com/pipeseroni/pipes.sh.git

    builtin cd pipes.sh && {
        sudo make install
    }

fi

case "$distroName" in
    (*suse*|ubuntu|debian|linuxmint|raspbian|Mac)
        zpwrNeedSudo=yes
        ;;
    (fedora)
        zpwrNeedSudo=no
        ;;
    (*)
        zpwrNeedSudo=no
        ;;
esac

zpwrPrettyPrintBox "Installing Iftop config..."
ip=$(ifconfig | grep "inet\s" | grep -v 127 | awk '{print $2}' | sed 's@addr:@@')
iface=$(ifconfig | grep -B3 "inet .*$ip" | grep '^[a-zA-Z0-9].*' | awk '{print $1}' | tr -d ":")

if [[ -n "$iface" ]]; then
    echo "IPv4: $ip and interface: $iface"
    if [[ -f "$HOME/.iftop.conf" ]]; then
        if ! grep -E '^interface:\S+' "$HOME/.iftop.conf"; then
            echo "no interface in $HOME/.iftop.conf"
            echo cp "$HOME/.iftop.conf" "$ZPWR_INSTALLER_OUTPUT"
            cp "$HOME/.iftop.conf" "$ZPWR_INSTALLER_OUTPUT"
            echo "interface:$iface" >> "$ZPWR_INSTALLER_OUTPUT/.iftop.conf"
            echo cp "$ZPWR_INSTALLER_OUTPUT/.iftop.conf" "$HOME"
            cp "$ZPWR_INSTALLER_OUTPUT/.iftop.conf" "$HOME"
        else
            echo "interface in $HOME/.iftop.conf. No mod"
        fi
    else
            echo "no $HOME/.iftop.conf"
            echo cp "$ZPWR_INSTALL/.iftop.conf" "$ZPWR_INSTALLER_OUTPUT"
            cp "$ZPWR_INSTALL/.iftop.conf" "$ZPWR_INSTALLER_OUTPUT"
            echo "interface:$iface" >> "$ZPWR_INSTALLER_OUTPUT/.iftop.conf"
            echo cp "$ZPWR_INSTALLER_OUTPUT/.iftop.conf" "$HOME"
            cp "$ZPWR_INSTALLER_OUTPUT/.iftop.conf" "$HOME"
    fi
else
    echo "IPv4 Iface missing: $ip and interface: $iface"
    if [[ -f "$HOME/.iftop.conf" ]]; then
        if ! grep -E '^interface:\S+' "$HOME/.iftop.conf"; then
            echo "no interface in $HOME/.iftop.conf. No mod"
        else
            echo "interface in $HOME/.iftop.conf. No mod"
        fi
    else
            echo "no $HOME/.iftop.conf"
            echo cp "$ZPWR_INSTALL/.iftop.conf" "$ZPWR_INSTALLER_OUTPUT"
            cp "$ZPWR_INSTALL/.iftop.conf" "$ZPWR_INSTALLER_OUTPUT"
            echo cp "$ZPWR_INSTALLER_OUTPUT/.iftop.conf" "$HOME"
            cp "$ZPWR_INSTALLER_OUTPUT/.iftop.conf" "$HOME"
    fi
fi


#}}}***********************************************************

#{{{                    MARK:Utilities
#**************************************************************
if [[ $justConfig != true ]]; then
    zpwrPrettyPrintBox "Installing IFTOP-color by MenkeTechnologies"

    zpwrGoInstallerDir
    zpwrFileMustExist iftop_install.sh
    source iftop_install.sh

    if ! zpwrCommandExists grc; then
        zpwrGoInstallerOutputDir
        zpwrPrettyPrintBox "Installing grc from source to $(pwd)"
        git clone https://github.com/garabik/grc.git
        if builtin cd grc; then
            sudo bash install.sh
        else
            zpwrFail "could not cd to grc"
        fi
    fi

    if [[ $ZPWR_OS_TYPE == darwin ]]; then
        zpwrPrettyPrintBox "Try again for ponysay and lolcat on mac"
        zpwrCommandExists ponysay || brew install ponysay
    fi

    zpwrPrettyPrintBox "Installing grc configuration for colorization...asking for passwd with sudo"
    if [[ "$(uname)" == Darwin ]]; then
        GRC_DIR=/usr/local/share/grc
    else
        GRC_DIR=/usr/share/grc
    fi

    zpwrGoInstallerOutputDir

    zpwrPrettyPrintBox "Installing ponysay from source"
    git clone https://github.com/erkin/ponysay.git && {
        builtin cd ponysay && sudo ./setup.py --freedom=partial install
    }

    zpwrPrettyPrintBox "Installing Go deps"

    zpwrGoInstallerDir
    zpwrFileMustExist go_install.sh
    source go_install.sh

    if ! test -f /usr/local/sbin/iftop;then
        zpwrPrettyPrintBox "No iftop so installing"
        zpwrInstallerUpdate iftop "$distroFamily"
    fi

    if [[ $fullInstall == true ]]; then
        if [[ "$ZPWR_OS_TYPE" != darwin ]]; then
            zpwrPrettyPrintBox "Installing snort"
            zpwrInstallerUpdate snort "$distroFamily"
            zpwrPrettyPrintBox "Installing logwatch"
            zpwrInstallerUpdate logwatch "$distroFamily"
            zpwrPrettyPrintBox "Installing postfix"
            zpwrInstallerUpdate postfix "$distroFamily"
        fi

        zpwrPrettyPrintBox "Installing wireshark"
        zpwrInstallerUpdate wireshark "$distroFamily"
        zpwrPrettyPrintBox "Installing mailutils"
        zpwrInstallerUpdate mailutils "$distroFamily"
    fi

fi

#}}}***********************************************************

#{{{                    MARK:zsh
#**************************************************************

if [[ "$ZPWR_PLUGIN_MANAGER" == zinit ]]; then
    zpwrPrettyPrintBox "Installing zinit"
    mkdir "$ZPWR_PLUGIN_MANAGER_HOME"
    git clone https://github.com/zdharma/zinit.git "$ZPWR_PLUGIN_MANAGER_HOME/bin"
    if [[ ! -d $ZPWR_PLUGIN_MANAGER_HOME/plugins ]]; then
        mkdir -pv $ZPWR_PLUGIN_MANAGER_HOME/plugins/
    fi

    zpwrPrettyPrintBox "Change default shell to zsh"
    sudo chsh -s "$(which zsh)"

    zpwrPrettyPrintBox "Clone fzf"
    git clone https://github.com/MenkeTechnologies/fzf.git "$ZPWR_PLUGIN_MANAGER_HOME/plugins/MenkeTechnologies---fzf"
    zpwrPrettyPrintBox "Link fzf"
    echo ln -sfn "$ZPWR_PLUGIN_MANAGER_HOME/plugins/MenkeTechnologies---fzf" "$ZPWR_PLUGIN_MANAGER_HOME/plugins/fzf"
    ln -sfn "$ZPWR_PLUGIN_MANAGER_HOME/plugins/MenkeTechnologies---fzf" "$ZPWR_PLUGIN_MANAGER_HOME/plugins/fzf"

    zpwrPrettyPrintBox "Installing fzf"
    "$ZPWR_PLUGIN_MANAGER_HOME/plugins/fzf/install" --bin

elif [[ "$ZPWR_PLUGIN_MANAGER" == oh-my-zsh ]]; then
    zpwrPrettyPrintBox "Installing OhMyZsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    zpwrPrettyPrintBox "Installing fzf"
    "$ZPWR_PLUGIN_MANAGER_HOME/custom/plugins/fzf/install" --bin
fi

zpwrPrettyPrintBox "Linking zshrc configuration file to home directory"
zpwrGoInstallerDir

echo ln -sf $ZPWR_INSTALL/.zshrc $HOME/.zshrc
ln -sf $ZPWR_INSTALL/.zshrc $HOME/.zshrc

if [[ "$ZPWR_PLUGIN_MANAGER" == oh-my-zsh ]]; then
    zpwrPrettyPrintBox "Installing Zsh plugins"
    zpwrGoInstallerDir
    zpwrFileMustExist zsh_plugins_install.sh

    source zsh_plugins_install.sh
fi

zpwrPrettyPrintBox "Running Vundle"
#run vundle install for ultisnips, supertab
vim -c PluginInstall -c qall

if [[ "$ZPWR_PLUGIN_MANAGER" == oh-my-zsh ]]; then
    zpwrPrettyPrintBox "Installing Powerlevel9k"
    git clone https://github.com/MenkeTechnologies/powerlevel9k.git "$ZPWR_PLUGIN_MANAGER_HOME/themes/powerlevel9k"
fi

if [[ $justConfig != true ]]; then
    zpwrPrettyPrintBox "Final updating of dependency list"
    zpwrInstallerRefresh "$distroFamily"
fi

#}}}***********************************************************

#{{{                    MARK:Final sym links
#**************************************************************
zpwrGoInstallerDir

zpwrPrettyPrintBox "Generating $ZPWR_INSTALLER_OUTPUT/zpwr_log.txt with $ESCAPE_REMOVER from $LOGFILE"
"$ESCAPE_REMOVER" "$LOGFILE" > "$ZPWR_INSTALLER_OUTPUT/zpwr_log.txt"

if [[ $justConfig != true ]] && [[ $skip != true ]]; then
    zpwrPrettyPrintBox "Waiting for cargo installer to finish"
    wait $CARGO_PID
    wait $YCM_PID
    wait $PLUGIN_PID
fi

if [[ $justConfig != true ]] && [[ $skip != true ]]; then
    zpwrPrettyPrintBox "Done!!!!!!"
    zpwrPrettyPrintBox "Starting Tmux..."
    zpwrPrettyPrintBox "Starting the matrix"
fi

# must have zsh at this point
export SHELL="$(which zsh)"

dir="$(sudo -EH python3 -m pip show powerline-status | \grep --color=always '^Location' | awk '{print $2}')/powerline"

zpwrPrettyPrintBox "linking $dir to ~/.tmux/powerline"

if [[ -z $TMUX_HOME ]]; then
    TMUX_HOME="$HOME/.tmux"
fi

if [[ ! -d "$TMUX_HOME" ]]; then
    zpwrPrettyPrintBox "$TMUX_HOME does not exist"
else
    if [[ ! -d "$dir" ]]; then
        zpwrPrettyPrintBox "$dir does not exist"
    else
        if zpwrNeedSudo "$dir"; then
            zpwrPrettyPrintBox "linking $dir to $TMUX_HOME/powerline with sudo"
            echo sudo ln -sfn "$dir" "$TMUX_HOME/powerline"
            sudo ln -sfn "$dir" "$TMUX_HOME/powerline"
        else
            zpwrPrettyPrintBox "linking $dir to $TMUX_HOME/powerline"
            echo ln -sfn "$dir" "$TMUX_HOME/powerline"
            ln -sfn "$dir" "$TMUX_HOME/powerline"
        fi
    fi
fi

#}}}***********************************************************

#{{{                    MARK:start tmux
#**************************************************************
if [[ $justConfig != true ]] && [[ $skip != true ]]; then
    if [[ $noTmux != true ]];then
        zpwrGoInstallerDir
        source "startMux.sh"
    fi
fi
#}}}***********************************************************
