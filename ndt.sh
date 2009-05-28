#!/bin/bash
#
# Nexuiz Ninjaz Proudly Present
# 
# Nexuiz Development Toolz
#
# Version: 0.6 Beta
# Released: 05/26/2009
# Created By: Tyler "-z-" Mulligan of the Nexuiz Ninjaz (www.nexuizninjaz.com)
#
# Required Software: subversion (svn)
# Optional Software: 7zip (in a future release)
#
# Description:
# This script was created to help linux users create a local development
# environment easily.  Making up for the downfalls of other build
# scripts, NDT allows you to compile each part of the build process 
# (engine, compiler and game) and modify their revisions seperately.
#
# By default the script exports a vanilla copy for testing of trunk
# and a development version you can hack around in.
#
# TODO:
#  - GUI
#  - option to zip the data directory
#  - option to strip out unneeded files/folders for a server environment
#  - option to build NetRadiant
#  - create a smart loop to accept multiple parameters in one line
#  - option for darkplaces CPU optimization
#
# Copyright (c) 2008 Tyler "-z-" Mulligan of www.nexuizninjaz.com
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#

# Configuration
source default.ndt.conf

# SVN Functions
##################################

# Generic SVN Checkout
function checkout_svn {
	[[ $3 ]] && rev="-r $3"
	svn co $rev $1 $2 # ($rev)revision ($1)url ($2)local folder
}
function checkout_darkplaces {
	echo "[x] Checking out Darkplaces"
	checkout_svn $svn_darkplaces $darkplaces_trunk $1 # $1 = revision
}
function checkout_fteqcc {
	echo "[x] Checking out FTEQCC"
	checkout_svn $svn_fteqcc $fteqcc_trunk $1 # $1 = revision
}
function checkout_nexuiz {
	echo "[x] Checking out Nexuiz"
	checkout_svn $svn_nexuiz $nexuiz_trunk $1 # $1 = revision
}
function checkout_all {
	darkplaces_rev=$(echo $1 | awk -F , '{ print $1 }')
	fteqcc_rev=$(echo $1 | awk -F , '{ print $2 }')
	nexuiz_rev=$(echo $1 | awk -F , '{ print $3 }')
	checkout_darkplaces $darkplaces_rev
	checkout_fteqcc $fteqcc_rev
	checkout_nexuiz $nexuiz_rev
}

# Generic SVN Update
function update_svn {
	[[ $2 ]] && rev="-r $2"
	cd $1 # $1 = folder
	svn up $rev
}
function update_darkplaces {
	echo "[x] Updating Darkplaces"
	update_svn $darkplaces_trunk $1 # $1 = revision
}
function update_fteqcc {
	echo "[x] Updating FTEQCC"
	update_svn $fteqcc_trunk $1 # $1 = revision
}
function update_nexuiz {
	echo "[x] Updating Nexuiz"
	update_svn $nexuiz_trunk $1 # $1 = revision
}
function update_all {
	darkplaces_rev=$(echo $1 | awk -F , '{ print $1 }')
	fteqcc_rev=$(echo $1 | awk -F , '{ print $2 }')
	nexuiz_rev=$(echo $1 | awk -F , '{ print $3 }')
	update_darkplaces $darkplaces_rev
	update_fteqcc $fteqcc_rev
	update_nexuiz $nexuiz_rev
}

# Compiling Functions
##################################

# Compile Engine
function compile_darkplaces {
	echo "[x] Compiling Darkplaces"
	cd "$darkplaces_trunk"
	make clean
	echo "[x] Darkplaces cleaned"
	#make CPUOPTIMIZATIONS="-pipe -O2 -march=i586 -mtune=i686" nexuiz
	make nexuiz
}
# Compile compiler
function compile_fteqcc {
	echo "[x] Compiling FTEQCC"
	cd "$fteqcc_trunk"
	make clean
	echo "[x] FTEQCC cleaned"
	make
}
# Compile Nexuiz
function compile_nexuiz_client {
	echo "[x] Compiling Nexuiz Client"
	cd "$1/data/qcsrc/client" # $1 = folder
	./fteqcc.bin
}
function compile_nexuiz_menu {
	echo "[x] Compiling Nexuiz Menu"
	cd "$1/data/qcsrc/menu" # $1 = folder
	./fteqcc.bin
}
function compile_nexuiz_server {
	echo "[x] Compiling Nexuiz Server"
	cd "$1/data/qcsrc/server" # $1 = folder
	./fteqcc.bin
}
function compile_nexuiz { # $1 = folder
	compile_nexuiz_server $1 || { echo "Error Nexuiz Server compilation failed"; exit 0; }
	compile_nexuiz_client $1 || { echo "Error Nexuiz Client compilation failed"; exit 0; }
	compile_nexuiz_menu $1 || { echo "Error Nexuiz Menu compilation failed"; exit 0; }
}

# compiles everything and exports Nexuiz to directories
function compile_and_build_all {
	compile_darkplaces || { echo "Error Darkplaces compilation failed"; exit 0; }
	compile_fteqcc || { echo "Error FTEQCC compilation failed"; exit 0; }
	build_nexuiz $nexuiz_vanilla
	if [[ $with_dev == 1 ]]; then
		if [[ ! -d $nexuiz_dev ]]; then mkdir $nexuiz_dev; fi
		latest_build=$(ls -t $nexuiz_vanilla | head -n1)
		echo "[x] Creating a copy for development"
		cp -Rv $nexuiz_vanilla/$latest_build $nexuiz_dev
	fi
}

# Nexuiz Export and Prep Functions
##################################

# Copy bins to Nexuiz dir
function copy_bins {
	echo "[x] Moving and renaming the compiled binaries files from $darkplaces_trunk to $1"
	cp "$darkplaces_trunk/nexuiz-dedicated" "$1"
	cp "$darkplaces_trunk/nexuiz-glx" "$1"
	cp "$darkplaces_trunk/nexuiz-sdl" "$1"
}

# Export a copy of Nexuiz to a directory
# Darkplaces needs to be compiled first
function export_nexuiz {
	rev=$(svn info $nexuiz_trunk |grep Revision |awk -F ": " '{ print $2 }')
	echo "[x] Exporting Nexuiz revision: $rev"
	svn export $nexuiz_trunk $1/$prefix$rev # $1 = folder
	copy_bins $1/$prefix$rev
	link_fteqcc $1/$prefix$rev
	compile_nexuiz $1/$prefix$rev
}

# links fteqcc to the nexuiz directories that use the compiler
function link_fteqcc { # $1 = folder
	ln -s $fteqcc_trunk/fteqcc.bin $1/data/qcsrc/server
	ln -s $fteqcc_trunk/fteqcc.bin $1/data/qcsrc/client
	ln -s $fteqcc_trunk/fteqcc.bin $1/data/qcsrc/menu
}

# Builds Nexuiz in a specific directory
function build_nexuiz {
	# $1 = folder
	if [[ ! -d $1 ]]; then mkdir $1; fi
	export_nexuiz $1
}

# Developer Functions
##################################

# Creates a diff patch based on the difference between dev and vanilla
function create_patch {
	if [[ ! -d $nexuiz_vanilla/$prefix$1 ]]; then echo "[ ERROR ] Vanilla directory not found, cannot create patch!"; exit 0; fi
	if [[ ! -d $nexuiz_dev/$prefix$1 ]]; then echo "[ ERROR ] Dev directory not found, cannot create patch!"; exit 0; fi
	echo "[x] Creating patch from revision $1: $2"
	diff -Nru -x *fteqcc.log $nexuiz_vanilla/$prefix$1 $nexuiz_dev/$prefix$1 > $nexuiz_dev/$2
	echo "[x] Cleaning patch of directory names"
	sed -i 's#'$nexuiz_vanilla'/'$prefix$1'/##g; s#'$nexuiz_dev'/'$prefix$1'/##g' $nexuiz_dev/$2
}

# System Functions
##################################

# Checks system for dependencies - borrowed from Soulbringer
function environment_check {
	if [[ ! ( -w "$rootdir" && -r "$rootdir" && -x "$rootdir" ) ]]; then echo "[ ERROR ] $rootdir does not have RWX permissions, please fix this and run this script again";exit 0;fi
	if [[ ! -x $( whereis svn | sed "s/svn: //" | sed "s/ .*//" ) ]]; then echo "[ ERROR ] Couldnt locate subversion, please install it and run this script again";exit 0;fi
	#if [[ ! -x $( whereis 7z | sed "s/7z: //" | sed "s/ .*//" ) ]]; then has7zip=0 ;else has7zip=1;fi
	if [[ ! -d "$rootdir/svn" ]]; then echo "[x] Creating svn folder"; mkdir "$rootdir/svn";fi
}

# Main Functions
##################################

# Install (all) -- first run
function install {
	environment_check
	checkout_all
	compile_and_build_all
}

# Upgrade all - the lazy way to upgrade and start fresh
function upgrade_all {
	update_all
	compile_and_build_all
}

function run_nexuiz {
	latest_build=$(ls -t $nexuiz_vanilla | head -n1)
	if [[ "$1" == "vanilla" || "$1" == "v" || "$1" == "" ]]; then
		echo "[x] Starting Nexuiz Vanilla: $latest_build"
		$nexuiz_vanilla/$latest_build/nexuiz-$buildtype -basedir $nexuiz_vanilla/$latest_build -userdir ~/.nexuiz_vanilla
	fi
	if [[ "$1" == "dev" || "$1" == "d" ]]; then
		echo "[x] Starting Nexuiz Development: $latest_build"
		$nexuiz_dev/$latest_build/nexuiz-$buildtype -basedir $nexuiz_dev/$latest_build -userdir ~/.nexuiz_dev
	fi
}

function help {
	B=$(tput bold) # bold
	U=$(tput smul) # underline
	N=$(tput sgr0) # normal
	echo "
${B}NAME${N}
	ndt - Nexuiz Development Toolz

${B}SYNOPSIS${N}
	${B}ndt${N} [${B}option${N}]
	${B}ndt${N} [${B}option${N}] [${B}folder${N}]
	${B}ndt${N} [${B}option${N}] [${B}revision${N}]

${B}DESCRIPTION${N}
	This script was created to help linux users create a local development environment easily.
	Making up for the downfalls of other build scripts, NDT allows you to compile each part of the build process.
	The engine, compiler and game, and modify their revisions seperately.
	
	Homepage: http://github.com/z/ndt

${B}OPTIONS${N}
	${B}--install${N}, ${B}-i${N}
		First Run -- checks out and installs everything
	--upgrade_all, -u
		Updates all SVN, compiles and builds all
	--update_darkplaces, --ud) update_darkplaces $2;;		# Updates Darkplaces SVN (optional revison)
	--update_fteqcc|--up) update_fteqcc $2;;				# Updates FTEQCC SVN (optional revison)
	--update_nexuiz|--un) update_nexuiz $2;;				# Updates Nexuiz SVN (optional revison)
	--update_all|-a) update_all $2;;						# Updates all SVN (optional revison -- darkplaces,fteqcc,nexuiz)
	--compile_darkplaces|--cd) compile_darkplaces;;			# Compiles Darkplaces
	--compile_fteqcc|--cf) compile_fteqcc;;					# Compiles FTEQCC
	--compile_nexuiz|--cn|-c) compile_nexuiz $2;;				# Compiles Nexuiz in the specified folder
	--compile_nexuiz_client|--cc) compile_nexuiz_client $2;;	# Compiles Nexuiz Client in the specified folder
	--compile_nexuiz_menu|--cm) compile_nexuiz_menu $2;;		# Compiles Nexuiz Menu in the specified folder
	--compile_nexuiz_server|--cs) compile_nexuiz_server $2;;	# Compiles Nexuiz Server in the specified folder
	--compile_and_build_all|--ca) compile_and_build_all $2;;	# Compiles and builds darkplaces, fteqcc, exports nexuiz to the given folder, then compiles nexuiz
	--build_nexuiz|-b) build_nexuiz $2;;						# Builds Nexuiz in the speicified folder
	--run_nexuiz|-r) run_nexuiz $2;;							# runs Nexuiz (specify version v/d)
	--create_patch|-p) create_patch $2 $3;;					# creates a diff patch by comparing vanilla and dev
	*||--help|-h) --help;;"
}

case $1 in
  --install|-i) install;;									# First Run -- checks out and installs everything
  --upgrade_all|-u) upgrade_all;;							# Updates all SVN, compiles and builds all
  --update_darkplaces|--ud) update_darkplaces $2;;			# Updates Darkplaces SVN (optional revison)
  --update_fteqcc|--up) update_fteqcc $2;;					# Updates FTEQCC SVN (optional revison)
  --update_nexuiz|--un) update_nexuiz $2;;					# Updates Nexuiz SVN (optional revison)
  --update_all|-a) update_all $2;;							# Updates all SVN (optional revison -- darkplaces,fteqcc,nexuiz)
  --compile_darkplaces|--cd) compile_darkplaces;;			# Compiles Darkplaces
  --compile_fteqcc|--cf) compile_fteqcc;;					# Compiles FTEQCC
  --compile_nexuiz|--cn|-c) compile_nexuiz $2;;				# Compiles Nexuiz in the specified folder
  --compile_nexuiz_client|--cc) compile_nexuiz_client $2;;	# Compiles Nexuiz Client in the specified folder
  --compile_nexuiz_menu|--cm) compile_nexuiz_menu $2;;		# Compiles Nexuiz Menu in the specified folder
  --compile_nexuiz_server|--cs) compile_nexuiz_server $2;;	# Compiles Nexuiz Server in the specified folder
  --compile_and_build_all|--ca) compile_and_build_all $2;;	# Compiles and builds darkplaces, fteqcc, exports nexuiz to the given folder, then compiles nexuiz
  --build_nexuiz|-b) build_nexuiz $2;;						# Builds Nexuiz in the speicified folder
  --run_nexuiz|-r) run_nexuiz $2;;							# runs Nexuiz (specify version v/d)
  --create_patch|-p) create_patch $2 $3;;					# creates a diff patch by comparing vanilla and dev
  *|--help|-h) help;;
esac
