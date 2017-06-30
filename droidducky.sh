#!/bin/bash

# DroidDucky
# Simple Duckyscript interpreter in Bash. Based on android-keyboard-gadget and hid-gadget-test utility.
#
function usage() { echo "Usage: $0 [-h help -d dryrun -v verbose -k {us, fr}] -f <duckfile_to_execute>" 1>&2; exit 1; }
#
# Copyright (C) 2015 - Andrej Budinčević <andrew@hotmail.rs>
# Copyright (C) 2017 - Rockeek <rockeek@yahoo.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

do_dry=0
do_verbose=0
duckfile=""
key_layout="us" #default layout

defdelay=0
kb="/dev/hidg0 keyboard"
last_cmd=""
last_string=""
line_num=0

if [[ -z $1 ]]; then
    usage
fi

while getopts f:k:dhv opt
do
    case $opt in
    (f) duckfile=${OPTARG} ;;
    (d) do_dry=1 ;;
    (v) do_verbose=1 ;;
    (h) usage ;;
    (k) key_layout=${OPTARG} ;;
    (*) printf "Illegal option '-%s'\n" "$opt" && exit 1 ;;
    esac
done

function execute(){
    # if dry run is enabled then simply return 
    (( do_dry && !do_verbose )) && echo "${@}"
    (( !do_dry && do_verbose )) && echo "#${@}"
     
    (( do_dry )) && return 0
        
    # if dry run is disabled, then execute the command
    eval "$@"
} #function execute()

function convert() 
{
	local kbcode=""

	if [ "$1" == " " ]
	then
		kbcode='space'
	elif [ "$1" == "!" ]
	then
		kbcode='left-shift 1'
	elif [ "$1" == "." ]
	then
		kbcode='period'
	elif [ "$1" == "\`" ]
	then
		kbcode='backquote'
	elif [ "$1" == "~" ]
	then
		kbcode='left-shift tilde'
	elif [ "$1" == "+" ]
	then
		kbcode='kp-plus'
	elif [ "$1" == "=" ]
	then
		kbcode='equal'
	elif [ "$1" == "_" ]
	then
		kbcode='left-shift minus'
	elif [ "$1" == "-" ]
	then
		kbcode='minus'
	elif [ "$1" == "\"" ]
	then
		kbcode='left-shift quote'
	elif [ "$1" == "'" ]
	then
		kbcode='quote'
	elif [ "$1" == ":" ]
	then
		kbcode='left-shift semicolon'
	elif [ "$1" == ";" ]
	then
		kbcode='semicolon'
	elif [ "$1" == "<" ]
	then
		kbcode='left-shift comma'
	elif [ "$1" == "," ]
	then
		kbcode='comma'
	elif [ "$1" == ">" ]
	then
		kbcode='left-shift period'
	elif [ "$1" == "?" ]
	then
		kbcode='left-shift slash'
	elif [ "$1" == "\\" ]
	then
		kbcode='backslash'
	elif [ "$1" == "|" ]
	then
		kbcode='left-shift backslash'
	elif [ "$1" == "/" ]
	then
		kbcode='slash'
	elif [ "$1" == "{" ]
	then
		kbcode='left-shift lbracket'
	elif [ "$1" == "}" ]
	then
		kbcode='left-shift rbracket'
	elif [ "$1" == "(" ]
	then
		kbcode='left-shift 9'
	elif [ "$1" == ")" ]
	then
		kbcode='left-shift 0'
	elif [ "$1" == "[" ]
	then
		kbcode='lbracket'
	elif [ "$1" == "]" ]
	then
		kbcode='rbracket'
	elif [ "$1" == "#" ]
	then
		kbcode='left-shift 3'
	elif [ "$1" == "@" ]
	then
		kbcode='left-shift 2'
	elif [ "$1" == "$" ]
	then
		kbcode='left-shift 4'
	elif [ "$1" == "%" ]
	then
		kbcode='left-shift 5'
	elif [ "$1" == "^" ]
	then
		kbcode='left-shift 6'
	elif [ "$1" == "&" ]
	then
		kbcode='left-shift 7'
	elif [ "$1" == "*" ]
	then
		kbcode='kp-multiply'

	else
		case $1 in
		[[:upper:]])
			tmp=$1
			kbcode="left-shift ${tmp,,}"
			;;
		*)
			kbcode="$1"
			;;
		esac
	fi

	echo "$kbcode"
}

# w => z
# ( => 9
# - => )
# m => .
# . => :
# ) => 0
# a => q
# ' => ù
# : => M
# / => !
# , => ;
# % => 5
# M => ?
# \ => *
# ; => m
# " => %

function convert-fr() 
{
	local kbcode=""

	if [ "$1" == " " ]; then kbcode='space';
	elif [ "$1" == "à" ]; then kbcode='0';
	elif [ "$1" == "0" ]; then kbcode='kp-0';
	elif [ "$1" == "1" ]; then kbcode='kp-1';
	elif [ "$1" == "2" ]; then kbcode='kp-2';
	elif [ "$1" == "3" ]; then kbcode='kp-3';
	elif [ "$1" == "4" ]; then kbcode='kp-4';
	elif [ "$1" == "5" ]; then kbcode='kp-5';
	elif [ "$1" == "6" ]; then kbcode='kp-6';
	elif [ "$1" == "7" ]; then kbcode='kp-7';
	elif [ "$1" == "8" ]; then kbcode='kp-8';
	elif [ "$1" == "9" ]; then kbcode='kp-9';
	
	elif [ "$1" == "é" ]
	then
		kbcode='2'
		
	elif [ "$1" == "!" ]
	then
		kbcode='slash'
	
	elif [ "$1" == "." ]
	then
		kbcode='left-shift comma'
	
	elif [ "$1" == "\`" ]
	then
		kbcode='left-alt 7'
	
	elif [ "$1" == "~" ]
	then
		kbcode='left-alt 2'
	
	elif [ "$1" == "+" ]
	then
		kbcode='kp-plus'
	
	elif [ "$1" == "=" ]
	then
		kbcode='equal'
	
	elif [ "$1" == "ç" ]
	then
		kbcode='9'
	
	elif [ "$1" == "_" ]
	then
		kbcode='8'
	
	elif [ "$1" == "-" ]
	then
		kbcode='6'
	
	elif [ "$1" == "è" ]
	then
		kbcode='7'
	
	elif [ "$1" == "\"" ]
	then
		kbcode='3'
	
	elif [ "$1" == "'" ]
	then
		kbcode='4'
	
	elif [ "$1" == ":" ]
	then
		kbcode='period'
	
	elif [ "$1" == ";" ]
	then
		kbcode='comma'
	
	elif [ "$1" == "<" ]
	then
		kbcode='europe-2'
	
	elif [ "$1" == "," ]
	then
		kbcode='m'
	
	elif [ "$1" == ">" ]
	then
		kbcode='left-shift europe-2'
	
	elif [ "$1" == "?" ]
	then
		kbcode='left-shift m'
	
	elif [ "$1" == "\\" ]
	then
		kbcode='right-alt 8'
	
	elif [ "$1" == "|" ]
	then
		kbcode='right-alt 6'
	
	elif [ "$1" == "/" ]
	then
		kbcode='left-shift period'
	
	elif [ "$1" == "{" ]
	then
		kbcode='right-alt 4'
	
	elif [ "$1" == "}" ]
	then
		kbcode='right-alt equal'
	
	elif [ "$1" == "(" ]
	then
		kbcode='5'
	
	elif [ "$1" == ")" ]
	then
		kbcode='minus'
	
	elif [ "$1" == "[" ]
	then
		kbcode='right-alt 5'
	
	elif [ "$1" == "]" ]
	then
		kbcode='right-alt minus'
	
	elif [ "$1" == "#" ]
	then
		kbcode='right-alt 3'
	
	elif [ "$1" == "@" ]
	then
		kbcode='right-alt 0'
	
	elif [ "$1" == "$" ]
	then
		kbcode='rbracket'
	
	elif [ "$1" == "%" ]
	then
		kbcode='left-shift quote'
	
	elif [ "$1" == "^" ]
	then
		kbcode='lbracket'
	
	elif [ "$1" == "&" ]
	then
		kbcode='1'
	
	elif [ "$1" == "*" ]
	then
		kbcode='kp-multiply'
		
    #letter management (case is important)
    else
        isUpperCase=false
        tmp=$1
        case "$1" in
        [[:upper:]])
            isUpperCase=true
            #convert to lower case
            tmp="${tmp,,}"
        esac

        if [ "$tmp" == "q" ]
        then
            tmp='a'

        elif [ "$tmp" == "a" ]
        then
            tmp='q'

        elif [ "$tmp" == "z" ]
        then
            tmp='w'

        elif [ "$tmp" == "w" ]
        then
            tmp='z'

        elif [ "$tmp" == "m" ]
        then
            tmp='semicolon'
        else
            tmp=$tmp
        fi

        if [ "$isUpperCase" == true ]
        then
            #restoring the 'caseness'
            kbcode="left-shift $tmp"
        else
            kbcode="$tmp"
        fi
    fi

    echo "$kbcode"
}
#convert to swiss-french
# ( => )
# - => '
# y => z
# ) => =
# ' => à
# : => ö
# / => -
# \ => $
# ; => é
# " => ä
function convert-ch-fr() 
{
	local kbcode=""

	if [ "$1" == " " ]
	then
		kbcode='space'
	
	elif [ "$1" == "!" ]
	then
		kbcode='left-shift rbracket'
	
	elif [ "$1" == "." ]
	then
		kbcode='period'
	
	elif [ "$1" == "\`" ]
	then
		kbcode='backquote'
	
	elif [ "$1" == "~" ]
	then
		kbcode='right-alt plus'
	
	elif [ "$1" == "+" ]
	then
		kbcode='kp-plus'
	
	elif [ "$1" == "=" ]
	then
		kbcode='left-shift 0'
	
	elif [ "$1" == "_" ]
	then
		kbcode='left-shift slash'
	
	elif [ "$1" == "-" ]
	then
		kbcode='slash'
	
	elif [ "$1" == "\"" ]
	then
		kbcode='left-shift 2'
	
	elif [ "$1" == "'" ]
	then
		kbcode='minus'
	
	elif [ "$1" == ":" ]
	then
		kbcode='left-shift period'
	
	elif [ "$1" == ";" ]
	then
		kbcode='left-shift comma'
	
	elif [ "$1" == "<" ]
	then
		kbcode='europe-2'
	
	elif [ "$1" == "," ]
	then
		kbcode='comma'
	
	elif [ "$1" == ">" ]
	then
		kbcode='left-shift europe-2'
	
	elif [ "$1" == "?" ]
	then
		kbcode='left-shift minus'
	
	elif [ "$1" == "\\" ]
	then
		kbcode='right-alt europe-2'
	
	elif [ "$1" == "|" ]
	then
		kbcode='right-alt 7'
	
	elif [ "$1" == "/" ]
	then
		kbcode='left-shift 7'
	
	elif [ "$1" == "{" ]
	then
		kbcode='right-alt semicolon'
	
	elif [ "$1" == "}" ]
	then
		kbcode='right-alt quote'
	
	elif [ "$1" == "(" ]
	then
		kbcode='left-shift 8'
	
	elif [ "$1" == ")" ]
	then
		kbcode='left-shift 9'
	
	elif [ "$1" == "[" ]
	then
		kbcode='right-atl lbracket'
	
	elif [ "$1" == "]" ]
	then
		kbcode='right-alt rbracket'
	
	elif [ "$1" == "#" ]
	then
		kbcode='alt-right 3'
	
	elif [ "$1" == "@" ]
	then
		kbcode='alt-right 2'
	
	elif [ "$1" == "$" ]
	then
		kbcode='quote'
	
	elif [ "$1" == "%" ]
	then
		kbcode='left-shift 5'
	
	elif [ "$1" == "^" ]
	then
		kbcode='equal'
	
	elif [ "$1" == "&" ]
	then
		kbcode='left-shift 6'
	
	elif [ "$1" == "*" ]
	then
		kbcode='kp-multiply'
	
	elif [ "$1" == "z" ]
	then
	    kbcode='y'
	    
	elif [ "$1" == "y" ]
	then
	    kbcode='z'

    #letter management (case is important)
    else
        isUpperCase=false
        tmp=$1
        case "$1" in
        [[:upper:]])
            isUpperCase=true
            #convert the character to lower case
            tmp="${tmp,,}"
        esac

        if [ "$tmp" == "z" ]
        then
            tmp='y'

        elif [ "$tmp" == "y" ]
        then
            tmp='z'

        else
            tmp=$tmp
        fi

        if [ "$isUpperCase" == true ]
        then
            #restoring the 'caseness'
            kbcode="left-shift $tmp"
        else
            kbcode="$tmp"
        fi
    fi

    echo "$kbcode"
}

(( do_dry )) && echo "#####dry mode#####"
#Force numlock on. 
execute "if [ \"\$(echo numlock | ./hid-gadget-test /dev/hidg0 keyboard | tr -dc '0-9')\" = '01' ]; then echo numlock | ./hid-gadget-test /dev/hidg0 keyboard; fi > /dev/null"
while IFS='' read -r line || [[ -n "$line" ]]; do
	((line_num++))
	read -r cmd info <<< "$line"
	if [ "$cmd" == "STRING" ] 
	then
		last_string="$info"
		last_cmd="$cmd"

		for ((  i=0; i<${#info}; i++  )); do

            #add keyboard layout commandlines parameters here
            if [ "$key_layout" == "ch-fr" ]
            then
			    kbcode=$(convert-ch-fr "${info:$i:1}")

            elif [ "$key_layout" == "fr" ]
            then 
            	kbcode=$(convert-fr "${info:$i:1}")
            else
                kbcode=$(convert "${info:$i:1}")
            fi

			if [ "$kbcode" != "" ]
			then
				execute "echo \"$kbcode\" | ./hid-gadget-test $kb > /dev/null"
			fi
		done
	elif [ "$cmd" == "ENTER" ] 
	then
		last_cmd="enter"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"
	
	elif [ "$cmd" == "DELAY" ] 
	then
		last_cmd="UNS"
		((info = info*1000))
		execute "usleep $info"

	elif [ "$cmd" == "WINDOWS" -o "$cmd" == "GUI" ] 
	then
		last_cmd="left-meta ${info,,}"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "MENU" -o "$cmd" == "APP" ] 
	then
		last_cmd="menu"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "DOWNARROW" -o "$cmd" == "DOWN" ] 
	then
		last_cmd="down"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "LEFTARROW" -o "$cmd" == "LEFT" ] 
	then
		last_cmd="left"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "RIGHTARROW" -o "$cmd" == "RIGHT" ] 
	then
		last_cmd="right"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "UPARROW" -o "$cmd" == "UP" ] 
	then
		last_cmd="up"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "DEFAULT_DELAY" -o "$cmd" == "DEFAULTDELAY" ] 
	then
		last_cmd="UNS"
		((defdelay = info*1000))

	elif [ "$cmd" == "BREAK" -o "$cmd" == "PAUSE" ] 
	then
		last_cmd="pause"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "ESC" -o "$cmd" == "ESCAPE" ] 
	then
		last_cmd="escape"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "PRINTSCREEN" ] 
	then
		last_cmd="print"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "CAPSLOCK" -o "$cmd" == "DELETE" -o "$cmd" == "END" -o "$cmd" == "HOME" -o "$cmd" == "INSERT" -o "$cmd" == "NUMLOCK" -o "$cmd" == "PAGEUP" -o "$cmd" == "PAGEDOWN" -o "$cmd" == "SCROLLLOCK" -o "$cmd" == "SPACE" -o "$cmd" == "TAB" \
	-o "$cmd" == "F1" -o "$cmd" == "F2" -o "$cmd" == "F3" -o "$cmd" == "F4" -o "$cmd" == "F5" -o "$cmd" == "F6" -o "$cmd" == "F7" -o "$cmd" == "F8" -o "$cmd" == "F9" -o "$cmd" == "F10" -o "$cmd" == "F11" -o "$cmd" == "F12" ] 
	then
		last_cmd="${cmd,,}"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "REM" ] 
	then
		#execute "echo \"$info\""
		:
	elif [ "$cmd" == "SHIFT" ] 
	then
		if [ "$info" == "DELETE" -o "$info" == "END" -o "$info" == "HOME" -o "$info" == "INSERT" -o "$info" == "PAGEUP" -o "$info" == "PAGEDOWN" -o "$info" == "SPACE" -o "$info" == "TAB" ] 
		then
			last_cmd="left-shift ${info,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == *"WINDOWS"* -o "$info" == *"GUI"* ] 
		then
			read -r gui char <<< "$info"
			last_cmd="left-shift left-meta ${char,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "DOWNARROW" -o "$info" == "DOWN" ] 
		then
			last_cmd="left-shift down"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "LEFTARROW" -o "$info" == "LEFT" ] 
		then
			last_cmd="left-shift left"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "RIGHTARROW" -o "$info" == "RIGHT" ] 
		then
			last_cmd="left-shift right"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "UPARROW" -o "$info" == "UP" ] 
		then
			last_cmd="left-shift up"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		else
			execute "echo \"($line_num) Parse error: Disallowed $cmd $info\""
		fi

	elif [ "$cmd" == "CONTROL" -o "$cmd" == "CTRL" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl pause"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl ${cmd,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl escape"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		else 
			last_cmd="left-ctrl ${info,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"
		fi

	elif [ "$cmd" == "ALT" ] 
	then
		if [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" \
		-o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-alt ${info,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-alt escape"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "" ]
		then
			last_cmd="left-alt"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		else 
			last_cmd="left-alt ${info,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"
		fi

	elif [ "$cmd" == "ALT-SHIFT" ] 
	then
		last_cmd="left-shift left-alt"
		execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

	elif [ "$cmd" == "CTRL-ALT" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl left-alt pause"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" -o "$info" == "DELETE" -o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl left-alt ${cmd,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl left-alt escape"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl left-alt"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		else 
			last_cmd="left-ctrl left-alt ${info,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"
		fi

	elif [ "$cmd" == "CTRL-SHIFT" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl left-shift pause"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" -o "$info" == "DELETE" -o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl left-shift ${cmd,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl left-shift escape"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl left-shift"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"

		else 
			last_cmd="left-ctrl left-shift ${info,,}"
			execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"
		fi

	elif [ "$cmd" == "REPEAT" ] 
	then
		if [ "$last_cmd" == "UNS" -o "$last_cmd" == "" ]
		then
			echo "($line_num) Parse error: Using REPEAT with DELAY, DEFAULTDELAY or BLANK is not allowed."
		else
			for ((  i=0; i<$info; i++  )); do
				if [ "$last_cmd" == "STRING" ] 
				then
					for ((  j=0; j<${#last_string}; j++  )); do
						kbcode=$(convert "${last_string:$j:1}")

						if [ "$kbcode" != "" ]
						then
							execute "echo \"$kbcode\" | ./hid-gadget-test $kb > /dev/null"
						fi
					done
				else
					execute "echo \"$last_cmd\" | ./hid-gadget-test $kb > /dev/null"
				fi
				execute "usleep $defdelay"
			done
		fi

	elif [ "$cmd" != "" ] 
	then
		execute "echo \"($line_num) Parse error: Unexpected $cmd.\""
	fi

	execute "usleep $defdelay"
done < "$duckfile"
echo