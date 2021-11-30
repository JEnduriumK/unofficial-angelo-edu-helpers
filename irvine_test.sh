#!/usr/bin/env bash

#Make sure this script is set to be executable.
#Running... 
#chmod 755 <this script's name>
#would work.

#Then simply type the name of this script, followed by the executable you
#are testing, and the input file you're feeding it. 

#Piping out output is supported.

#This script is useful in getting multiple lines of input in a text file into
#an Irvine32 based executable. My impression is that Irvine32 libraries were 
#designed with old-school Windows/DOS in mind, where they didn't have the 
#concept of piping contents of a text file to an executable. (Recent versions
#do, but versions that the Irvine32 libraries were built for do not.) Irvine32
#takes a ton of input, then trashes anything after the first line-feed
#character. 

#The angelo.edu Among32 port for the Linux box ported over this exact same 
#limitation to the Linux implementation. This prevents the piping-in of text
#files to the executables to be evaluated as input. This script works around
#the issue.

#Script inexpertly cobbled together by (and idea for FIFO pipe): Joel King. 
#Credit for the idea of using a subshell to pipe
#in to that FIFO pipe: https://github.com/mloftis

#https://tldp.org/LDP/abs/html/subshells.html
#https://unix.stackexchange.com/questions/442692/is-a-subshell
#https://geek-university.com/linux/determine-file-type/
#https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
#https://linuxize.com/post/basename-command-in-linux/
#https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
#https://www.linuxjournal.com/content/bash-trap-command
#Credit also to https://github.com/mloftis for pointing out trap and mktemp after I showed him the first version of this script.
#And also using "#!/usr/bin/env bash" rather than "#!/usr/bin/bash"

#Changelog
#v3 Apparently I had a wait after mkfifo that wasn't needed? 
#v2 Temp files are a thing in /tmp! Wow, who knew? Also, trap is a thing for ensured cleanup? Nice. 
#v1 Rudimentary first attempt with ""temp"" files in the same directory as the script, and an 0.1 wait.

function cleanup()
{
	[[ -n $THE_TEMP_DIRECTORY ]] && [[ -d $THE_TEMP_DIRECTORY ]] && rm -r $THE_TEMP_DIRECTORY;
}
THE_TEMP_DIRECTORY=$(mktemp -d)
trap cleanup EXIT

THE_EXECUTABLE=""
THE_TEXT=""

#Did you hand us two arguments?
[[ $# -eq 2 ]] || { echo "USAGE: $0 <executable> <input text>"; echo "OR     $0 <input text> <executable>"; exit; }
#Are they files?
[[ -f $1 ]] || { echo $1 "is not a file."; exit; }
[[ -f $2 ]] || { echo $2 "is not a file."; exit; }
#Figure out which one is the text file, and which one is the executable.
[[ $(file -bip $1 | grep -c application) -gt 0 ]] && { THE_EXECUTABLE=$1; }
[[ $(file -bip $2 | grep -c application) -gt 0 ]] && { THE_EXECUTABLE=$2; }
[[ $(file -bip $1 | grep -c text) -gt 0 ]] && { THE_TEXT=$1; }
[[ $(file -bip $2 | grep -c text) -gt 0 ]] && { THE_TEXT=$2; }
#I don't have one of each, abort!
[[ -z "$THE_EXECUTABLE" || -z "$THE_TEXT" ]] && { echo "We weren't given one text file and one executable."; echo "USAGE: $0 <executable> <input text>"; echo "OR     $0 <input text> <executable>"; exit; }

#Otherwise...
#Prepare a FIFO pipe.
THIS_MAGICAL_PIPE=$(mktemp -u "$THE_TEMP_DIRECTORY""/""$THE_TEXT""_TO_"$(basename $THE_EXECUTABLE)".fifo_pipe"".XXXXXXXX")
mkfifo "$THIS_MAGICAL_PIPE"
#Start piping the contents of that pipe in to the executable in the background. 
"./""$THE_EXECUTABLE" < "$THIS_MAGICAL_PIPE" &
#Spin up a subshell! Credit: https://github.com/mloftis
(
	while IFS="" read -r THE_LINE || [ -n "$THE_LINE" ]
	do
		echo "$THE_LINE"
		sleep 0.01
	done < "$THE_TEXT" #THE INPUT FILE CAME FROM... BEHIND!
	#Essentially: ( echo LINE1; sleep 0.01; echo LINE2; sleep 0.01; echo LINE3; sleep 0.01 ) > $THIS_MAGICAL_PIPE
) > "$THIS_MAGICAL_PIPE"
#wait until we're done with the pipe to exit, because exiting will delete it.
wait
