#!/usr/bin/env bash

#Created by jacobmenke at Wed May 31 22:54:32 EDT 2017

#{{{                    MARK:Setup
#**************************************************************

#set -x

OS_TYPE="$(uname -s)"
INSTALLER_DIR="$(pwd -P)"

#bold
printf "\e[1m"

#Dependencies
# 1) vim 8.0
# 2) tmux 2.1
# 3) lolcat
# 4) cmatrix
# 5) htop
# 6) cmake
# 7) youcompleteme
# 8) ultisnips
# 9) supertab
# 10) oh-my-zsh
# 11) agnosterzak
# 12) pathogen
# 13) nerdtree
# 14) ctrlp
# 15) powerline
# 16) powerline-mem-segment

dependencies_ary=(vim tmux git wget lolcat cowsay cmatrix htop cmake glances bpython python-dev \
	python3-dev colortail screenfetch \
	libpcap-dev ncurses-dev iftop htop figlet silversearcher-ag zsh libevent-dev libncurses5-dev libgnome2-dev\
	libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
	libcairo2-dev libx11-dev libxpm-dev libxt-dev \
	python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev rlwrap tor npm nginx nmap mtr tcpdump \
	software-properties-common ctags speedtest-cli texinfo lsof)

#}}}***********************************************************

#{{{                    MARK:Functions
#**************************************************************

update (){

	if [[ -z "$(which $1)" ]]; then
		if [[ $2 == mac ]]; then
			brew install "$1"
		else
			sudo apt-get install -y "$1"
		fi
	else
		printf "Already have $1\n"
	fi
}

#}}}***********************************************************

if [[ "$OS_TYPE" == "Darwin" ]]; then
	#{{{                    MARK:Mac
	#**************************************************************
	printf "Checking Dependencies for Mac...\n"

	if [[ -z "$(which brew)" ]]; then
		#install homebrew
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	echo brew ls python > /dev/null 2>&1
	if [[ $? == 1 ]]; then
		brew install python
		brew install pip
	fi

	for prog in ${dependencies_ary[@]}; do
		update $prog mac
	done

	#}}}***********************************************************

else

	#{{{                    MARK:Linux
	#**************************************************************

	printf "Installing Dependencies for Linux with APT...\n"

	sudo apt-get -y install build-essential

	for prog in ${dependencies_ary[@]}; do
		update $prog linux
	done

	#}}}***********************************************************

fi

#printf "Installing Vim8\n"
#git clone https://github.com/vim/vim.git vim-master
#cd vim-master
#./configure --with-features=huge \
	#--enable-multibyte \
	#--enable-rubyinterp=yes \
	#--enable-pythoninterp=yes \
	#--with-python-config-dir=/usr/lib/python2.7/config \
	#--enable-python3interp=yes \
	#--with-python3-config-dir=/usr/lib/python3.5/config \
	#--enable-perlinterp=yes \
	#--enable-luainterp=yes \
	#--enable-gui=gtk2 --enable-cscope --prefix=/usr
#sudo make install

printf "Installing Pathogen\n"
#install pathogen
mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle && \
	curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

printf "Installing Vim Plugins\n"
bash "./vim_plugins_install.sh"

printf "Installing psutil for Python Glances\n"
sudo pip install psutil 
printf "Installing Python Glances\n"
sudo pip install glances


printf "Installing Virtualenv\n"
pip3 install virtualenv

printf "Installing Django...\n"
pip3 install django

printf "Running Vundle\n"
#run vundle install for ultisnips, supertab
vim -c PluginInstall -c qall

printIf "Installing Vimrc\n"
cp "$INSTALLER_DIR/.vimrc $HOME"

################################################################################
## YouCompleteMe
################################################################################

printf "Installing YouCompleteMe\n"

cd $HOME/.vim/bundle/YouCompleteMe
./install.py --clang-completer

################################################################################
## Powerline
################################################################################
printf "Installing Powerline...\n"

sudo pip install powerline-status

printf "Adding Powerline to .vimrc \n"

powerline_dir="$(pip show powerline-status | grep Location | awk '{print $2}')"
echo "set rtp+=$powerline_dir/powerline/bindings/vim" >> .vimrc

################################################################################
## Zsh
################################################################################

printf "Installing oh-my-zsh...\n"
#oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
#install custom theme based on agnosterzak
cp "$INSTALLER_DIR/agnosterzak.zsh-theme" $HOME/.oh-my-zsh/themes/

#add aliases and functions
printf "Adding common shell aliases\n"
cp "$INSTALLER_DIR/.shell_aliases_functions.sh" "$HOME"
#echo "source $HOME/.shell_aliases_functions.sh" >> "$HOME/.zshrc"

printf "Installing Zshrc\n"
cp "$INSTALLER_DIR/.zshrc" "$HOME"

printf "Instpalling zsh plugins\n"
bash "$INSTALLER_DIR/zsh_plugins_install.sh"

################################################################################
## Tmux
################################################################################
#printf "Installing Tmux Powerline\n"

#tmuxPowerlineDir=$HOME/.config/powerline/themes/tmux
#echo pip install powerline-mem-segment

#custom settings for tmux powerline
#if [[ ! -d $tmuxPowerlineDir ]]; then
#    echo mkdir -p $tmuxPowerlineDir && cat default.json >> $tmuxPowerlineDir/default.json
#fi

printf "Installing Tmux Plugin Manager\n"
if [[ ! -d $HOME/.tmux/plugins/tpm  ]]; then
	echo mkdir -p $HOME/.tmux/plugins/tpm
	echo git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

printf "Adding Powerline to .tmux.conf\n"
# add powerline to .tmux.conf
#echo "source $powerline_dir/powerline/bindings/tmux/powerline.conf >> tmux/.tmux.conf"
#echo "run '~/.tmux/plugins/tpm/tpm' >> tmux/.tmux.conf"

printf "Copying tmux configuration file to home directory\n"
cp "./.tmux.conf" "$HOME"

printf "Installing Custom Tmux Commands\n"
cp -R "$INSTALLER_DIR/.tmux" "$HOME"

printf "Installing Tmux plugins\n"
bash "$INSTALLER_DIR/tmux_plugins_install.sh"

printf "Installing Colotail Config\n"
cp "$INSTALLER_DIR/.colortailconf" "$HOME"

#printf "Installing IFTOP-color"
#if [[ ! -d "$HOME/ForkedRepos" ]]; then
#mkdir "$HOME/ForkedRepos" && cd "$HOME/ForkedRepos"
#git clone https://github.com/MenkeTechnologies/iftopcolor
#sudo ./configure && make
#fi

printf "Installing PyDf\n"
sudo pip install pydf

printf "Installing MyCLI\n"
sudo pip install mycli

if [[ ! -f "$HOME/.token.sh" ]]; then
	touch "$HOME/.tokens.sh"
fi

printf "HushLogin\n"
if [[ ! -f "$HOME/.hushlogin" ]]; then
	touch "$HOME/.hushlogin"
fi

if [[ ! -f "$HOME/.my.cnf" ]]; then
	touch "$HOME/.my.cnf"
fi

printf "Changing pager to cat for MySQL\n"
echo "[client]" >> "$HOME/.my.cnf"
echo "pager=cat" >> "$HOME/.my.cnf"

echo "Copying all Shell Scripts..."
cp $INSTALLER_DIR/*.sh $HOME/Documents/shellScripts

printf "Installing ponysay from source\n"
git clone https://github.com/erkin/ponysay.git && {
cd ponysay && sudo ./setup.py --freedom=partial install && \
    cd .. && sudo rm -rf ponysay
}

type chsh >/dev/null 2>&1 && {
printf "Changing default shell to Zsh\n"
chsh -s "$(which zsh)"
}

printf "Changing current shell to Zsh\n"
exec zsh


printf "\e[0m"
