#!/bin/bash
#
# Nexuiz Ninjaz Proudly Present
# 
# Nexuiz Development Toolz
#
# Version: 0.8 Beta
# Released: 05/31/2009
# Created By: Tyler "-z-" Mulligan of the Nexuiz Ninjaz (www.nexuizninjaz.com)
#
# Required Software: subversion (svn)
# For Nexuiz: sudo apt-get install build-essential xserver-xorg-dev x11proto-xf86dri-dev x11proto-xf86dga-dev x11proto-xf86vidmode-dev libxxf86dga-dev libxcb-xf86dri0-dev libxpm-dev libxxf86vm-dev libsdl1.2-dev libsdl-image1.2-dev libsdl1.2debian-alsa subversion libclalsadrv-dev libasound2-dev libxext-dev zenity
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
#  - support relative paths in folder params
#  - create a smart loop to accept multiple parameters in one line
#  - option for darkplaces CPU optimization
#
# Copyright (c) 2009 Tyler "-z-" Mulligan of www.nexuizninjaz.com
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
core_dir=$(cd $(dirname $0); pwd)
source $core_dir/default.ndt.conf

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
function checkout_netradiant {
	echo "[x] Checking out NetRadiant"
	checkout_svn $svn_netradiant $netradiant_trunk $1 # $1 = revision
}
function checkout_all {
	darkplaces_rev=$(echo $1 | awk -F , '{ print $1 }')
	fteqcc_rev=$(echo $1 | awk -F , '{ print $2 }')
	nexuiz_rev=$(echo $1 | awk -F , '{ print $3 }')
	netradiant_rev=$(echo $1 | awk -F , '{ print $4 }')
	checkout_darkplaces $darkplaces_rev
	checkout_fteqcc $fteqcc_rev
	checkout_nexuiz $nexuiz_rev
	if [[ $with_netradiant == 1 ]]; then checkout_netradiant $netradiant_rev; fi
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
function update_netradiant {
	echo "[x] Updating NetRadiant"
	update_svn $netradiant_trunk $1 # $1 = revision
}
function update_all {
	darkplaces_rev=$(echo $1 | awk -F , '{ print $1 }')
	fteqcc_rev=$(echo $1 | awk -F , '{ print $2 }')
	nexuiz_rev=$(echo $1 | awk -F , '{ print $3 }')
	netradiant_rev=$(echo $1 | awk -F , '{ print $4 }')
	update_darkplaces $darkplaces_rev
	update_fteqcc $fteqcc_rev
	update_nexuiz $nexuiz_rev
	if [[ $with_netradiant == 1 ]]; then update_netradiant $netradiant_rev; fi
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
	if [[ $1 == "" ]]; then
		folder=$(ls -dt $nexuiz_dev/*/ | head -n1);
		echo "[ WARNING ] Revision not specified, using latest exported revision in the dev folder! ($folder)";
	else
		folder=$1
	fi
	echo "[x] Compiling Nexuiz Client"
	cd "$folder/data/qcsrc/client"
	./fteqcc.bin
}
function compile_nexuiz_menu {
	if [[ $1 == "" ]]; then
		folder=$(ls -dt $nexuiz_dev/*/ | head -n1);
		echo "[ WARNING ] Revision not specified, using latest exported revision in the dev folder! ($folder)";
	else
		folder=$1
	fi
	echo "[x] Compiling Nexuiz Menu"
	cd "$folder/data/qcsrc/menu"
	./fteqcc.bin
}
function compile_nexuiz_server {
	if [[ $1 == "" ]]; then
		folder=$(ls -dt $nexuiz_dev/*/ | head -n1);
		echo "[ WARNING ] Revision not specified, using latest exported revision in the dev folder! ($folder)";
	else
		folder=$1
	fi
	echo "[x] Compiling Nexuiz Server"
	cd "$folder/data/qcsrc/server"
	./fteqcc.bin
}
function compile_nexuiz {
	if [[ $1 == "" ]]; then
		folder=$(ls -dt $nexuiz_dev/*/ | head -n1);
		echo "[ WARNING ] Revision not specified, using latest exported revision in the dev folder! ($folder)";
	else
		folder=$1
	fi
	compile_nexuiz_server $folder || { echo "Error Nexuiz Server compilation failed"; exit 0; }
	compile_nexuiz_client $folder || { echo "Error Nexuiz Client compilation failed"; exit 0; }
	compile_nexuiz_menu $folder || { echo "Error Nexuiz Menu compilation failed"; exit 0; }
}
# Compile NetRadiant
function compile_netradiant {
	echo "[x] Compiling NetRadiant"
	cd "$netradiant_trunk"
	make clean
	echo "[x] NetRadiant cleaned"
	make
	if [[ -d $nexuiz_vanilla && $update_radiant_engine == 1 ]]; then # update engine automatically
		radiant_userdir=$(ls -t ~/.netradiant | head -n1)
		engine_path=$(ls -dt $nexuiz_vanilla/*/ | head -n1)
		sed -i 's#<epair name="EnginePath">.*</epair>#<epair name="EnginePath">'$engine_path'</epair>#' ~/.netradiant/$radiant_userdir/nexuiz.game/local.pref
	fi
	if [[ -f $core_dir/netradiant ]]; then rm $core_dir/netradiant; fi
	ln -s $netradiant_trunk/install/radiant.x86 $core_dir/netradiant
}

# compiles everything and exports Nexuiz to directories
function compile_and_build_all {
	compile_darkplaces || { echo "Error Darkplaces compilation failed"; exit 0; }
	compile_fteqcc || { echo "Error FTEQCC compilation failed"; exit 0; }
	build_nexuiz $nexuiz_vanilla
	if [[ $with_dev == 1 ]]; then
		if [[ ! -d $nexuiz_dev ]]; then mkdir $nexuiz_dev; fi
		latest_build=$(ls -dt $nexuiz_vanilla/*/ | head -n1)
		echo "[x] Creating a copy for development"
		cp -Rv $latest_build $nexuiz_dev
	fi
	if [[ $with_netradiant == 1 ]]; then compile_netradiant || { echo "Error NetRadiant compilation failed"; exit 0; }; fi
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
	if [[ -f $1/data/qcsrc/server/fteqcc.bin ]]; then rm $1/data/qcsrc/server/fteqcc.bin; fi
	ln -s $fteqcc_trunk/fteqcc.bin $1/data/qcsrc/server
	if [[ -f $1/data/qcsrc/client/fteqcc.bin ]]; then rm $1/data/qcsrc/client/fteqcc.bin; fi
	ln -s $fteqcc_trunk/fteqcc.bin $1/data/qcsrc/client
	if [[ -f $1/data/qcsrc/menu/fteqcc.bin ]]; then rm $1/data/qcsrc/menu/fteqcc.bin; fi
	ln -s $fteqcc_trunk/fteqcc.bin $1/data/qcsrc/menu
}

# Builds Nexuiz in a specific directory
function build_nexuiz {
	echo "[x] Building Nexuiz in folder: $1"
	if [[ ! -d $1 ]]; then mkdir $1; fi # $1 = folder
	export_nexuiz $1
}

# Builds a stripped down Nexuiz server
function build_nexuiz_server {
	if [[ "$1" == "" ]]; then echo "[ ERROR ] Need a folder name, kthx!"; exit 0; fi
	echo "[x] Building Nexuiz Server in folder: $1"
	if [[ ! -d $1 ]]; then mkdir $1; fi # $1 = folder
	export_nexuiz $1
	server_folder=$(ls -dt $1/*/ | head -n1 | sed 's/\/*$//')
	cd $server_folder
	echo "[x] Removing unneeded files"
	rm -rf misc Docs
	cd data
	rm -rf gfx demos sound textures video qcsrc "$( if [[ "$with_maps" = 0 ]]; then echo maps;fi )"
	if [[ $zip_server_data ]]; then zip_data_dir $server_folder; fi
}

# zips the data dir
function zip_data_dir {
	if [[ ! -d $1/data ]]; then echo "[ ERROR ] this directory does no contain a data directory"; exit 0; fi
	echo "[x] Zipping Nexuiz data dir in folder: $1"
	cd $1/data
	pk3_name=data$( date +%Y%m%d ).pk3
	7za a -tzip -mx=${compression_level} $pk3_name . -x!common-spog.pk3 -x!qcsrc
	mv $pk3_name ..
	rm -r *
	mv ../$pk3_name .
}

# Developer Functions
##################################

# Creates a diff patch based on the difference between dev and vanilla
function create_patch {
	if [[ ! -d $nexuiz_vanilla/$prefix$1 ]]; then echo "[ ERROR ] Vanilla directory not found, cannot create patch!"; exit 0; fi
	if [[ ! -d $nexuiz_dev/$prefix$1 ]]; then echo "[ ERROR ] Dev directory not found, cannot create patch!"; exit 0; fi
	echo "[x] Creating patch from revision $1: $2"
	echo "[[ Patch \"$2\" created with NDT for Nexuiz revision: $1 ]]" > $nexuiz_dev/$2
	diff -Nru -x *fteqcc.log $nexuiz_vanilla/$prefix$1 $nexuiz_dev/$prefix$1 > $nexuiz_dev/${2}.tmp
	echo "[x] Cleaning patch of directory names"
	sed -i 's#'$nexuiz_vanilla'/'$prefix$1'/##g; s#'$nexuiz_dev'/'$prefix$1'/##g' $nexuiz_dev/${2}.tmp
	cat $nexuiz_dev/${2}.tmp >> $nexuiz_dev/$2
	rm $nexuiz_dev/${2}.tmp
}

# Applies a properly formatted patch file
function apply_patch {
	if [[ ! -f $nexuiz_dev/$1 ]]; then echo "[ ERROR ] Specified patch $1 does not exist in $nexuiz_dev!  Please put the patch here to continue."; exit 0; fi
	if [[ $2 == "" ]]; then
		echo "[ WARNING ] Revision not specified, using latest exported revision!";
		vanilla_rev=$(ls -dt $nexuiz_vanilla/*/ | head -n1 | sed 's/\/*$//')
		rev=$(echo $vanilla_rev | awk -F / '{ print $NF }' | awk -F _ '{ print $NF }')
	else
		if [[ "$2" =~ ^[0-9]+$ ]]; then
			vanilla_rev=$nexuiz_vanilla/$prefix$2
			rev=$2
		elif [[ "$2" =~ [/]+ ]]; then
			folder_to_patch=$2
			rev=$(echo $folder_to_patch | awk -F / '{ print $NF }')
		fi
	fi
	if [[ ! -d $vanilla_rev && "$folder_to_patch" == "" ]]; then echo "[ ERROR ] Specific revision not found in vanilla directory not found, cannot apply patch!"; exit 0; fi
	if [[ "$folder_to_patch" == "" ]]; then
		echo "[x] Creating a copy for patching"
		cp -Rv $vanilla_rev $nexuiz_dev/$prefix${rev}_patched
		folder_to_patch=$nexuiz_dev/$prefix${rev}_patched
	fi
	echo "[x] Patching $rev"
	cp $nexuiz_dev/$1 $folder_to_patch
	cd $folder_to_patch
	patch -p0 < $1
	rm $1
	link_fteqcc $folder_to_patch # only really needed when copying folder
}

# Reverts a patch on a specified directory by applying it backwards
function revert_patch {
	if [[ ! -f $nexuiz_dev/$1 ]]; then echo "[ ERROR ] Specified patch $1 does not exist in $nexuiz_dev!  Please put the patch here to continue."; exit 0; fi
	if [[ "$2" =~ [/]+ ]]; then
		folder_to_patch=$2
		rev=$(echo $folder_to_patch | awk -F / '{ print $NF }' | sed 's/\/*$//')
	else
		echo "[ ERROR ] Sorry, this command only takes folder names"
	fi
	echo "[x] Reverting patch $rev"
	cp $nexuiz_dev/$1 $folder_to_patch
	cd $folder_to_patch
	patch -p0 -R < $1
	rm $1
}

# System Functions
##################################

# Checks system for dependencies - borrowed from Soulbringer
function environment_check {
	if [[ ! ( -w "$core_dir" && -r "$core_dir" && -x "$core_dir" ) ]]; then echo "[ ERROR ] $core_dir does not have RWX permissions, please fix this and run this script again";exit 0;fi
	if [[ ! -x $( whereis svn | sed "s/svn: //" | sed "s/ .*//" ) ]]; then echo "[ ERROR ] Couldnt locate subversion, please install it and run this script again";exit 0;fi
	if [[ ! -x $( whereis 7z | sed "s/7z: //" | sed "s/ .*//" ) ]]; then echo "[ WARNING ] Couldn't locate 7z, you cannot zip the data directory without this!";fi
	if [[ ! -d "$core_dir/svn" ]]; then echo "[x] Creating svn folder"; mkdir "$core_dir/svn";fi
}

# Moo
function moo {
	echo -e 'KAAAAAAAAAAAAAAAAAAAAZbKNMwRiQKiOKa%MOonMlKCZKddddddddddddddddddddZKKKKKKKKEKKKfAAfZKKKKKKKKKEKKGoohEAAAAAAAZKKKKKKKKKKKKGAAhEKKKKKKKhEjEZKKKKKKKKKKKKKKKKIIddddpKIZKKKKKKKKKKKKKKKKIIKKKKKIIZ' | sed 's/A/_/g;s/b/</g;s/C/>/g;s/d/-/g;s/E/\\/g;s/f/\^/g;s/G/(/g;s/h/)/g;s/I/|/g;s/j/\//g;s/K/ /g;s/l/!/g;s/M/e/g;s/n/m/g;s/O/s/g;s/p/w/g;s/Q/z/g;s/w/x/g;s/R/u/g;s/Z/\n/g;s/%/w/g;'
}

# Icons
function create_icon {
	# testing this function is not ready yet
	echo "[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=true
Icon[en_US]=/home/tyler/nn_dev/nexuiz/icons/nexuiz_dev.png
Name[en_US]=Nexuiz - Dev
Exec=/home/tyler/nn_dev/nexuiz/ndt.sh --run_nexuiz d
Name=Nexuiz - Dev
Icon=/home/tyler/nn_dev/nexuiz/icons/nexuiz_dev.png" > nexuiz_dev.desktop
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
	if [[ "$1" == "vanilla" || "$1" == "v" || "$1" == "" ]]; then
		latest_build=$(ls -dt $nexuiz_vanilla/*/ | head -n1 | sed 's/\/*$//')
		echo "[x] Starting Nexuiz Vanilla: $latest_build"
		$latest_build/nexuiz-$buildtype -basedir $latest_build -userdir ~/.nexuiz_vanilla
	fi
	if [[ "$1" == "dev" || "$1" == "d" ]]; then
		latest_build=$(ls -dt $nexuiz_dev/*/ | head -n1 | sed 's/\/*$//')
		echo "[x] Starting Nexuiz Development: $latest_build"
		$latest_build/nexuiz-$buildtype -basedir $latest_build -userdir ~/.nexuiz_dev
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
	${B}ndt${N} [${B}option${N}] <${B}folder${N}>
	${B}ndt${N} [${B}option${N}] [${B}revision${N}]
	${B}ndt${N} ${B}--run_nexuiz${N} [${B}vanilla${N}|${B}dev${N}|${B}v${N}|${B}d${N}]

${B}DESCRIPTION${N}
	This script was created to help linux users create a local development environment easily.
	Making up for the downfalls of other build scripts, NDT allows you to compile each part of the build process.
	The engine, compiler and game, and modify their revisions seperately.
	
	Homepage: http://github.com/z/ndt

${B}OPTIONS${N}

  ${B}General Options${N}
	${B}--install${N}, ${B}-i${N}
		First Run ONLY!! Checks out and installs everything from SVN (darkplaces, fteqcc, Nexuiz, NetRadiant (optional in conf)).
		
	${B}--upgrade_all${N}, ${B}-u${N}
		Updates all SVN, compiles and builds all

	${B}--run_nexuiz${N} [${U}version${N}], ${B}-r${N} [${U}version${N}]
		Runs a specified version of Nexuiz (vanilla|dev|v|d).  Defaults to vanilla if no param is passed.

  ${B}SVN Related Options${N}
 	${B}--checkout_darkplaces${N} [${U}revision${N}]
		Checks Out Darkplaces SVN (optional revison in any SVN style format).
		Probably shouldn't have to use this.
		
	${B}--checkout_fteqcc${N} [${U}revision${N}]
		Checks Out FTEQCC SVN (optional revison in any SVN style format).
		Probably shouldn't have to use this.
		
	${B}--checkout_nexuiz${N} [${U}revision${N}]
		Checks Out Nexuiz SVN (optional revison in any SVN style format).
		Probably shouldn't have to use this.

	${B}--checkout_netradiant${N} [${U}revision${N}]
		Checks Out NetRadiant SVN (optional revison in any SVN style format).
		Probably shouldn't have to use this unless you didn't check it out originally
		
	${B}--checkout_all${N} [${U}revisions${N}]
		Checks Out all SVN (optional revison in any SVN style format in the following list format >> darkplaces,fteqcc,nexuiz,netradiant)
		Probably shouldn't have to use this.
 
	${B}--update_darkplaces${N} [${U}revision${N}], ${B}--ud${N} [${U}revision${N}]
		Updates Darkplaces SVN (optional revison in any SVN style format)
		
	${B}--update_fteqcc${N} [${U}revision${N}], ${B}--up${N} [${U}revision${N}]
		Updates FTEQCC SVN (optional revison in any SVN style format)
		
	${B}--update_nexuiz${N} [${U}revision${N}], ${B}--un${N} [${U}revision${N}]
		Updates Nexuiz SVN (optional revison in any SVN style format)

	${B}--update_netradiant${N} [${U}revision${N}], ${B}--ur${N} [${U}revision${N}]
		Updates NetRadiant SVN (optional revison in any SVN style format)
		
	${B}--update_all${N} [${U}revisions${N}], ${B}-a${N} [${U}revisions${N}]
		Updates All SVN (optional revison in any SVN style format in the following list format >> darkplaces,fteqcc,nexuiz,netradiant)

  ${B}Compiling and Building${N}
	${B}--compile_darkplaces${N}, ${B}--cd${N}
		Compiles Darkplaces, no folder needed, stays put.
		
	${B}--compile_fteqcc${N}, ${B}--cf${N}
		Compiles FTEQCC, no folder needed, stays put.
		
	${B}--compile_nexuiz_client${N} [${U}folder${N}], ${B}--cc${N} [${U}folder${N}]
		Compiles Nexuiz Client in the specified folder
		${U}folder example${N}: /path/to/nexuiz_dev/rev_6677
		
	${B}--compile_nexuiz_menu${N} [${U}folder${N}], ${B}--cm${N} [${U}folder${N}]
		Compiles Nexuiz Menu in the specified folder
		${U}folder example${N}: /path/to/nexuiz_dev/rev_6677
		
	${B}--compile_nexuiz_server${N} [${U}folder${N}], ${B}--cs${N} [${U}folder${N}]
		Compiles Nexuiz Server in the specified folder,
		${U}folder example${N}: /path/to/nexuiz_dev/rev_6677
		
	${B}--compile_nexuiz${N} [${U}folder${N}], ${B}--cn${N} [${U}folder${N}], ${B}-c${N} [${U}folder${N}]
		Compiles Nexuiz in the specified folder
		${U}folder example${N}: /path/to/nexuiz_dev/rev_6677
		
	${B}--compile_netradiant${N}, ${B}--cr${N}
		Compiles NetRadiant, no folder needed, stays put.

	${B}--compile_and_build_all${N}, ${B}--ca${N}
		Compiles and builds darkplaces, fteqcc, exports nexuiz to the vanilla folder, then compiles nexuiz and by default copies to nexuiz_dev.
		
	${B}--build_nexuiz${N} <${U}folder${N}>, ${B}-b${N} <${U}folder${N}>
		Builds Nexuiz in the speicified folder, it exports a copy and builds it.  This is not the same thing as ${B}--compile_nexuiz${N}
		${U}folder example${N}: /path/to/nexuiz_dev
		
	${B}--build_nexuiz_server${N} <${U}folder${N}>, ${B}--bs${N} <${U}folder${N}>
		Builds a stripped down Nexuiz Server in the speicified folder, it exports a copy and builds it.  This is not the same thing as ${B}--compile_nexuiz_server${N}
		${U}folder example${N}: /path/to/nexuiz_server

	${B}--zip_data_dir${N} <${U}folder${N}>, ${B}--zd${N} <${U}folder${N}>
		Zips the data directory of a specific server
		${U}folder example${N}: /path/to/nexuiz_vanilla/rev_6677
		
  ${B}Developer Extras${N}	
	${B}--create_patch${N} <${U}revision${N}> <${U}patch name${N}>, ${B}--cp${N} <${U}revision${N}> <${U}patch name${N}>
		Creates a diff patch by comparing the vanilla and dev folders.  The same revision must exists in both folders.
		The patch will be ouput to nexuiz_dev
		${U}folder example${N}: nexuiz_vanilla/${prefix}_6677 and nexuiz_dev/${prefix}_6677

	${B}--apply_patch${N} <${U}patch name${N}> [${U}revision${N}|${U}folder${N}], ${B}-p${N} <${U}patch name${N}> [${U}revision${N}|${U}folder${N}]
		If a revision or nothing is specified, it copies a folder from vanilla and then patches it with the specified patch name.
		If a folder is passed, it will patch the specific folder.  You can use this to patch a folder many times.
		
	${B}--revert_patch${N} <${U}patch name${N}> <${U}folder${N}>, ${B}--rp${N} <${U}patch name${N}> <${U}folder${N}>
		Reverts a patch by applying it in reverse to the specified folder.

  ${B}Getting Help${N}
	${B}--help${N}, ${B}-h${N}
		You're looking at it.
		
${B}FILES${N}
	${U}default.ndt.conf${N}
		The default configuration file for NDT will all the SVN server settings, paths and customization options.
		Feel free to create your own and change the source file in the top of ndt.sh

${B}AUTHOR${N}
	This program and help file were written by Tyler \"-z-\" Mulligan of the Nexuiz Ninjaz (www.nexuizninjaz.com).
	
	Permission is granted to copy, distribute and/or modify this document under the terms of the MIT License.
	
NDT Version 0.8 Beta  |  May 31, 2009"
}

case $1 in
  --install|-i) install;;									# First Run -- checks out and installs everything
  --upgrade_all|-u) upgrade_all;;							# Updates all SVN, compiles and builds all
  --checkout_darkplaces) checkout_darkplaces;;				# Checkout Darkplaces from SVN
  --checkout_fteqcc) checkout_fteqcc;;						# Checkout FTEQCC from SVN
  --checkout_nexuiz) checkout_nexuiz;;						# Checkout Nexuiz from SVN
  --checkout_netradiant) checkout_netradiant;;				# Checkout NetRadiant from SVN
  --checkout_all) checkout_all;;							# Checkout everything from SVN
  --update_darkplaces|--ud) update_darkplaces $2;;			# Updates Darkplaces SVN (optional revison)
  --update_fteqcc|--up) update_fteqcc $2;;					# Updates FTEQCC SVN (optional revison)
  --update_nexuiz|--un) update_nexuiz $2;;					# Updates Nexuiz SVN (optional revison)
  --update_netradiant|--ur) update_netradiant $2;;			# Updates NetRadiant SVN (optional revison)
  --update_all|-a) update_all $2;;							# Updates all SVN (optional revison -- darkplaces,fteqcc,nexuiz,netradiant)
  --compile_darkplaces|--cd) compile_darkplaces;;			# Compiles Darkplaces
  --compile_fteqcc|--cf) compile_fteqcc;;					# Compiles FTEQCC
  --compile_nexuiz|--cn|-c) compile_nexuiz $2;;				# Compiles Nexuiz in the specified folder
  --compile_nexuiz_client|--cc) compile_nexuiz_client $2;;	# Compiles Nexuiz Client in the specified folder
  --compile_nexuiz_menu|--cm) compile_nexuiz_menu $2;;		# Compiles Nexuiz Menu in the specified folder
  --compile_nexuiz_server|--cs) compile_nexuiz_server $2;;	# Compiles Nexuiz Server in the specified folder
  --compile_netradiant|--cr) compile_netradiant;;			# Compiles NetRadiant
  --compile_and_build_all|--ca) compile_and_build_all $2;;	# Compiles and builds darkplaces, fteqcc, exports to vanilla then compiles nexuiz and copies to dev
  --moo) moo;;												# Someone's good at reading source code
  --build_nexuiz|-b) build_nexuiz $2;;						# Builds Nexuiz in the speicified folder
  --build_nexuiz_server|--bs) build_nexuiz_server $2;;		# Builds a stripped down Nexuiz server in the speicified folder
  --zip_data_dir|--zd) zip_data_dir $2;;					# Zips the data directory for a specific folder
  --run_nexuiz|-r) run_nexuiz $2;;							# Runs Nexuiz (specify version v/d)
  --create_patch|--cp) create_patch $2 $3;;					# Creates a diff patch by comparing vanilla and dev
  --apply_patch|-p) apply_patch $2 $3;;						# Applies a patch -- patchname, [revision|folder]
  --revert_patch|--rp) revert_patch $2 $3;;					# Reverts a patch -- patchname, folder
  #--create_icon) create_icon;;								# Internal command, incomplete
  *|--help|-h) help;;
esac
