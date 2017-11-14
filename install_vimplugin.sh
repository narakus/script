#!/bin/bash

test -e /bin/git || yum install git -y > /dev/null 2>&1

if [ -e ~/.vimrc ];then
	cp ~/.vimrc ~/.vimrc.bak
fi

test -d ~/.vim/bundle &&\
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

cat ~/.vimrc < EOF
filetype off              
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
Plugin 'davidhalter/jedi-vim'
Plugin 'nvie/vim-flake8'
call vundle#end()
filetype plugin indent on
let python_highlight_all=1
syntax on
EOF

vim +PluginInstall +qall 

#update vim to 8.0

yum install -y ruby ruby-devel lua lua-devel luajit \
	     luajit-devel ctags git python python-devel \
	     python3 python3-devel tcl-devel \
	     perl perl-devel perl-ExtUtils-ParseXS \
	     perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
	     perl-ExtUtils-Embed

cd
git clone https://github.com/vim/vim.git
cd vim
./configure --with-features=huge \
	    --enable-multibyte \
            --enable-rubyinterp \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib/python2.7/config \
            --enable-python3interp \
            --with-python3-config-dir=/usr/lib/python3.5/config \
            --enable-perlinterp \
            --enable-luainterp \
            --enable-gui=gtk2 --enable-cscope --prefix=/usr

make VIMRUNTIMEDIR=/usr/share/vim/vim80
sudo make install
