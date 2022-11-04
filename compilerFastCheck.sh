#!/usr/bin/env bash

#From https://github.com/JEnduriumK/unofficial-angelo-edu-helpers/blob/main/compilerFastCheck.sh
#By Joel King. Sorta. Nov 18th, 2021.
######################################################################
#WARNING:
#
#USE AT YOUR OWN RISK
#
#This script was cobbled together by someone with a rudimentary 
#understanding of Linux, and by mostly cobbling together portions of
#other people's scripts found online. 
#
#It was only tested on the Angelo State University CSUnix box
#on or around November 28th, 2021. 
#
#It was only tested on stage1 of the compiler project.
#
#No guarantees that it will continue to work are provided.
#No guarantees of any kind are provided.
#This script may delete all your files and set fire to your house. 
#
#THIS SCRIPT IS PROVIDED AS-IS, WITH NO WARRANTIES.
#
#THIS SCRIPT MAY NUKE YOUR ENTIRE MACHINE AND EVERYTHING IN IT.
#
#USE AT YOUR OWN RISK
#
#USE AT YOUR OWN RISK
#
#USE AT YOUR OWN RISK
#
#Read the INFORMATION and INSTRUCTIONS sections.
#
######################################################################

######################################################################
#INFORMATION: 
#
#Configuration options are provided to change some behavior. If those
#settings are changed, the behavior described below will differ.
#
#Change configuration options at your own risk.
#
#This script, by default, assumes the following basic directory layout
#
#./        <-- this script and the executable compiler.
#./input/  <-- provided .dat, .lst, and .asm files, as well as 
#              user generated ###.in test input and output files.
#./output/ <-- where this script will store most of the 
#              compiler's output. The one exception is alldiffs.txt
#              and allout.txt. These will output in ./ by default.
#
#alldiffs.txt and allout.txt provide a single-file option to visually
#inspect the output of running your compiler on all .dat files without
#having to open up dozens or a hundred+ individual files. 
#
######################################################################

######################################################################
#INSTRUCTIONS:
#
#By default, place this script in the same directory as your 
#built/compiled executable compiler. 
#
#You'll want to make this file executable. I suggest 
#
#   chmod 755 <the name of this file>
#
#to do so.
#
#Set COMPILERNAME to the name of your compiler program executable.
#
COMPILERNAME=./stage0
#COMPILERNAME=./stage1
#COMPILERNAME=./stage2
#
#Set the ASM_NAME_STRING to contain the same string as your list of
#names of people who worked on your compiler. For example, if your 
#generated .asm files say something like:
#
#; Santa Claus and The Easter Bunny Wed Nov 17 12:52:38 2021
#
#You would set the following:
#ASM_NAME_STRING="Santa Claus and The Easter Bunny"
#
###SET ASM_NAME_STRING to disable help text.###
###SET ASM_NAME_STRING to disable help text.###
###SET ASM_NAME_STRING to disable help text.###
###SET ASM_NAME_STRING to disable help text.###
###SET ASM_NAME_STRING to disable help text.###
#
#DEFAULT:
#ASM_NAME_STRING=""
ASM_NAME_STRING=""
#
#Lines in your generated .asm files containing this text will 
#not cause color changes in the output chart at the end.
#
#Using:
#ASM_NAME_STRING="Santa Claus and The Easter Bunny"
#
#Will prevent a diff that shows a difference like so:
#1c1
#< ; YOUR NAME(S)       Mon Oct 19 17:06:18 2020
#---
#> ; Santa Claus and The Easter Bunny Wed Nov 17 12:52:38 2021
#from being flagged as a problem.
#
#
#By default this script will run something like...
#> ./stage0 ./input/001.dat ./output/001.my.lst ./output/001.my.asm
#
#If you want everything to just be piled in to a single directory,
#you can just set all the directory settings to ./ (I think? try it)
#and it will probably work?
#
#.lst and .asm colors
#--------------------
#
#GREEN  : Your .asm or .lst file matches the file it's checking against.
#         Good job. Maybe. Or maybe this script is lying to you. 
#
#YELLOW : Your output doesn't match the output of provided comparison
#         files. I suggest you look at them.
#
#CYAN   : No testing file was provided for this .dat file. 
#
#RED    : Something broke diff? I think? Or the files are missing? 
#         I forget.
#
#executable file colors
#----------------------
#
#This checks provided test .asm files OR your compiler's generated
#.asm file if a test file was not provided. It looks for 
#"Exit    {0}". If "Exit    {0}" is present, it assumes an executable
#should also be present. 
#
#This may break in cases where an .asm contains "Exit    {0}" but an
#executable should not be generated for some other reason.
#
#GREEN  : A test .asm file was provided. You either have an executable
#         when it implies you should have one, or you don't, when it 
#         implies you shouldn't. Probably good.
#
#RED    : A test .asm file was provided. You do NOT have an executable
#         when the test file implies you should, OR you DO have an
#         executable when the test file implies you shouldn't. 
#         Probably bad.
#
#CYAN   : No test file was provided. Your compiler seems to be
#         suggesting that either you should have an executable file, 
#         and you do, or it implies you shouldn't, and you don't. 
#         Maybe good. Maybe your compiler is broken. Who knows?
#
#YELLOW : No test file was provided. Your compiler seems to be
#         suggesting that either you should have an executable file, 
#         and you don't, or it implies you shouldn't, and you do. 
#         Maybe good. Maybe your compiler is broken. Who knows?
#
#
######################################################################

######################################################################
#Config:
#
#Do you want it to show progress updates on a single line, rather than
#scrolling your terminal a large amount? (true/false)
FANCY_OUTPUT=true;
#
#
#Directory containing the provided Pascallite .dat files.
#Default:
#PROVIDED_DATS=./input/
PROVIDED_DATS=./input/
#
#Directory containing any provided Pascallite compiler .lst files. 
#These are the files your output will be checked against.
#DEFAULT:
#PROVIDED_LSTS=./input/
PROVIDED_LSTS=./input/
#
#Directory containing any provided Assembly language .asm files.
#These are the files your output will be checked against.
#DEFAULT:
#PROVIDED_ASMS=./input/
PROVIDED_ASMS=./input/
#
#Directory for the storage and generation of .lst files from your compiler.
#DEFAULT:
#MY_LSTS=./output/
MY_LSTS=./output/
#
#Directory for the storage and generation of .asm files from your compiler.
#DEFAULT:
#MY_ASMS=./output/
MY_ASMS=./output/
#
#Directory for the storage and generation of executable files
#from your compiler.
#DEFAULT:
#MY_EXES=./output/
MY_EXES=./output/
#
#Directory for the storage of test inputs. Filenames should be the number
#of the .dat the executable came from, followed by either .in or 
#.anythingYouLike.in. (so for 101.dat, 101.in, 101.a.in, 101.test2.in,
#and 101.123456.in would be valid options. You can do multiple input files.
MY_TEST_INPUTS=./input/
#
#Directory for the storage of files to diff against for test input results.
#So if you have an input file (101.in) that you want run through an 
#executable you generated (101.my.exe), and test its output against a
#file, you'll put the file here. (Equivalent to a file like 001.out that
#Dr. Motl might provide.) Should be named the same name as the .in file,
#but with .out instead of .in.  (101.aY73.in is what goes in to the 
#executable. 101.aY73.out is what the output is compared to.)
MY_TEST_CHECKS=./input/
#
#Directory for the storage of test output from your generated executables.
#Will be compared against files stored in MY_TEST_CHECKS. 
MY_TEST_OUTPUTS=./output/
#
#Extension of .lst files generated by the compiler.
#DEFAULT:
#LST_EXTEN=".my.lst"
LST_EXTEN=".my.lst"
#
#Extension of .asm files generated by the compiler.
#DEFAULT:
#ASM_EXTEN=".my.asm"
ASM_EXTEN=".my.asm"
#
#Extension appended to executable files generated by the compiler.
#DEFAULT:
#EXE_EXTEN=".my.exe"
EXE_EXTEN=".my.exe"
#
#Extension appended to output generated by executable files your
#compiler makes, and this script tests with input files you provide.
TEST_OUTPUT_EXTEN=".my.out"
#
#Output directory and file for every diff file generated, 
#added together in to one single compilation. It's easier to open and
#look over one file than it is to open 150. This script will not 
#generate individual diff file output. 
ALL_DIFFS="./alldiffs.txt"
#
#Output directory and file for every .lst AND .asm file generated, 
#added together in to one single compilation. It's easier to open and
#look over one file than it is to open 150. 
ALL_OUTS="./allouts.txt"
#
#Extension of temporary pipes that will be created, used, and deleted.
MAGICALPIPE_INDICATOR=".series_of_tubes"
#
#Delay between 'echo' calls in the subshell that sends data to an
#executable to be tested.
MAGICPIPE_DELAY="0.05"
######################################################################

#https://stackoverflow.com/questions/2297510/linux-shell-script-for-each-file-in-a-directory-grab-the-filename-and-execute-a
#https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#https://stackoverflow.com/questions/4434346/how-to-ignore-some-differences-in-diff-command
#https://stackoverflow.com/questions/6971284/what-are-the-error-exit-values-for-diff
#https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
#https://linuxize.com/post/basename-command-in-linux/
#https://linuxcommand.org/lc3_adv_tput.php
#https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
#https://unix.stackexchange.com/questions/444946/how-can-we-run-a-command-stored-in-a-variable
#https://stackoverflow.com/questions/11307257/is-there-a-bash-command-which-counts-files
#Credit also to https://github.com/mloftis for pointing out trap and mktemp after I showed him the first version of this script.
#And also using "#!/usr/bin/env bash" rather than "#!/usr/bin/bash"

#Provided AS-IS, no warranties. I won't promise it won't delete your root structure.
#USE AT YOUR OWN RISK

######################################################################
#Test input for compiled executables IS NOT WORKING AT THIS TIME.
#
#The intention is that for all files in ./input/ named 001*in
#the script will feed the contents of those files to 001.my.exe 
#and put the output at 001*out inside ./output/, then diff
#them against a matching 001*out file in ./input/.
#
#An error free Pascallite file called 101.dat in the directory
#./input/ will result in the following files being generated:
#./output/101.my.lst
#./output/101.my.asm
#./output/101.my.exe
#
#Then, if there are two files in ./input/ named
#101.a.in and
#101.in
#it will feed those two files to the executable 001.my.exe
#and output the results to ./output/ as
#001.a.out and
#001.out
#and then diff those files against matching files (if provided) in
#./input/ (e.g. diff ./input/001.out ./output/001.out)
#
#As an example, inside ./input/ place a file named 101.in. The
#file should contain the following:
#-4301
#3304
#2336
#
#and place a file named 101.out inside the directory ./input/
#The file should contain the following:
#-4301
#+3304
#+5
#+185
#+370
#+2336
#+5
#+0
#
#The script will input -4301, 3304, and 2336 to your executable 
#101.my.exe and test the output against the 101.out file. It will let
#you know if the outputs match, or differ. 
######################################################################

######################################################################
#CHANGELOG:
#
#v4: Temp-file usage for cleaner pipe creation.
#    More informative output, possibly might work for people without
#    color support on their terminal?
#    Control the fancy output where it does/n't scroll endlessly.
#    First steps towards input/output in to executables.
#
#v3: Configuration options added. Now you can have your files in 
#    other directories!
#
#v2: It compares files generated against files provided, highlights
#    differences in red, no differences in green.
#
#v1: It smashes all the diffs together in to one file. 
#    It also smashes all the .lsts together in to one file.
######################################################################


######################################################################
######################################################################
######################################################################
##############IF YOU EDIT BELOW, DO SO AT YOUR OWN RISK.##############
######################################################################
######################################################################
######################################################################

function cleanup()
{
	[[ -n $THE_TEMP_DIRECTORY ]] && [[ -d $THE_TEMP_DIRECTORY ]] && rm -r $THE_TEMP_DIRECTORY;
}

THE_TEMP_DIRECTORY=$(mktemp -d)
trap cleanup EXIT
#Did you know that...
#/tmp is typically stored in RAM, not on disk, on Linux?
#Which would make /tmp *very* fast...
#And that trap works like a C signal handler?
#And there's an entire command (mktemp) that revolves around creating
#temporary files on /tmp for use by other programs!
#Also, /tmp gets cleaned up every reboot, because it's on RAM!
#So we can create all our temporary FIFO pipes in a /tmp directory,
#do our best to clean all of it up,
##even on a ^C##
#but if we miss something, it'll just clutter /tmp for a little while
#until reboot! Neat!


RED=$'\e[0;31m'
GREEN=$'\e[1;32m'
YELLOW=$'\e[0;33m'
GREY=$'\e[0;37m'
#BLACK=$'\e[0;30m'
CLEAR=$'\e[0m'
CYAN=$'\e[0;36m'

if [ -z "$ASM_NAME_STRING" ]; then
	echo -e "\nHello! It appears this may be your first time running this script.\n"
	echo "This script is provided as-is, with no warranties, guarantees, or promises."
	echo "It was cobbled together by someone who barely understands Linux," 
	echo "so it may set your house on fire."
	echo -e "\n$RED""USE AT YOUR OWN RISK""$CLEAR\n"
	echo "$CYAN""No promises that this file will give you good information. It may lie"
	echo "about whether or not your compiler's output is good. Do not blindly trust"
	echo "this script.""$CLEAR"
	echo -e "\n$RED""USE AT YOUR OWN RISK""$CLEAR\n"
	echo "$GREEN""In order to make this script usable, you will need to open it up and edit"
	echo "one or two variables.""$CLEAR"
	echo -e "\nPlease read over the short INFORMATION section which will give you an"
	echo "idea of the default structure it expects all files to exist in. Then read the"
	echo -e "INSTRUCTIONS to see how to disable this message.\n"
	echo "Configuration options/settings are provided below the INSTRUCTIONS section if"
	echo -e "you want the directory structure to be different from default.\n"
	#You haven't set the necessary variable to make clean diffs. I won't let you run yet. 
	exit
fi

if [ ! -d "$PROVIDED_DATS" ]; then
	echo "$PROVIDED_DATS"" directory does not exist. Check the instructions and configuration settings and/or make that directory and try again."
	exit
fi
if [ ! -d "$PROVIDED_LSTS" ]; then
	echo "$PROVIDED_LSTS"" directory does not exist. Check the instructions and configuration settings and/or make that directory and try again."
	exit
fi
if [ ! -d "$PROVIDED_ASMS" ]; then
	echo "$PROVIDED_ASMS"" directory does not exist. Check the instructions and configuration settings and/or make that directory and try again."
	exit
fi
if [ ! -d "$MY_ASMS" ]; then
	echo "$MY_ASMS"" directory does not exist. Check the instructions and configuration settings and/or make that directory and try again."
	exit
fi
if [ ! -d "$MY_LSTS" ]; then
	echo "$MY_LSTS"" directory does not exist. Check the instructions and configuration settings and/or make that directory and try again."
	exit
fi
if [ ! -d "$MY_EXES" ]; then
	echo "$MY_EXES"" directory does not exist. Check the instructions and configuration settings and/or make that directory and try again."
	exit
fi
if [ ! -f "$COMPILERNAME" ]; then
	echo "I don't see a compiler named $COMPILERNAME, are you sure you have one, and this script is pointing at it?"
	exit
fi

#Yes, I know I could just make the directories for you. But I'd rather not do a bunch of directory
#structure changes without you knowing about them.

for i in "$PROVIDED_DATS"*.dat ; do 
#Lets cycle through all your .dat files in the directory you indicate. This should be all
#the Pascallite files. Lets throw your compiler at them.
	[[ -f "$i" ]] || continue
	THENAME=$(basename "$i" .dat) #Lets just grab the name of the file, sans extension. 
	#Lets show you that I'm doing something! And... what I'm doing, really.
	echo $COMPILERNAME "$i" "$MY_LSTS""$THENAME""$LST_EXTEN" "$MY_ASMS""$THENAME""$ASM_EXTEN"
	if $FANCY_OUTPUT ; then  tput cuu1; fi
	#sleep 0.02
	#DO THE THING.
	$COMPILERNAME "$i" "$MY_LSTS""$THENAME""$LST_EXTEN" "$MY_ASMS""$THENAME""$ASM_EXTEN"
done
#Lets start our compilation files, a one-stop-shop of all your output in a single file,
#for easy browsing later. So you don't have to open up 178+ different files to see what
#your compiler is doing.
echo "All Listing and Assembly Files" > $ALL_OUTS
echo "" >> $ALL_OUTS #NEWLINE
echo "All Listing and Assembly File Diffs" > $ALL_DIFFS
echo "" >> $ALL_DIFFS #NEWLINE
#Okay, now lets loop through all the .lst files your compiler just generated.
for i in "$MY_LSTS"*"$LST_EXTEN" ; do 
	[[ -f "$i" ]] || continue
	THENAME=$(basename "$i" $LST_EXTEN)
	echo "$MY_LSTS""$THENAME""$LST_EXTEN" >> $ALL_OUTS
	echo "------------------------------" >> $ALL_OUTS
	cat "$MY_LSTS""$THENAME""$LST_EXTEN" >> $ALL_OUTS
	echo "" >> $ALL_OUTS #NEWLINE
	[[ -f "$PROVIDED_LSTS""$THENAME".lst ]] || continue
	echo "Running $COMPILERNAME $THENAME listing file diff test"
	if $FANCY_OUTPUT ; then  tput cuu1; fi
	#sleep 0.02
	echo "$THENAME".lst diffs >> $ALL_DIFFS
	diff -b "$PROVIDED_LSTS""$THENAME".lst "$MY_LSTS""$THENAME""$LST_EXTEN" >> $ALL_DIFFS
	echo "------------------------------" >> $ALL_DIFFS
	echo "" >> $ALL_DIFFS #NEWLINE
done
if $FANCY_OUTPUT ; then  tput cud1; fi
echo "Listing files generated and added to $ALL_OUTS, diffs produced and added to $ALL_DIFFS."
for i in "$MY_ASMS"*"$ASM_EXTEN" ; do 
	[[ -f "$i" ]] || continue
	THENAME=$(basename "$i" $ASM_EXTEN)
	echo "$MY_ASMS""$THENAME""$ASM_EXTEN" >> $ALL_OUTS
	echo "------------------------------" >> $ALL_OUTS
	cat "$MY_ASMS""$THENAME""$ASM_EXTEN" >> $ALL_OUTS
	echo "" >> $ALL_OUTS #NEWLINE
	[[ -f "$PROVIDED_ASMS""$THENAME".asm ]] || continue
	echo "Running $COMPILERNAME $THENAME assembly file diff test"
	if $FANCY_OUTPUT ; then  tput cuu1; fi
	#sleep 0.02
	echo "$THENAME".asm diffs >> $ALL_DIFFS
	diff -b "$PROVIDED_ASMS""$THENAME".asm "$MY_ASMS""$THENAME""$ASM_EXTEN" >> $ALL_DIFFS
	echo "------------------------------" >> $ALL_DIFFS
	echo "" >> $ALL_DIFFS #NEWLINE!!!
done
if $FANCY_OUTPUT ; then tput cud1; fi
echo "Assembly files generated and added to $ALL_OUTS, diffs produced and added to $ALL_DIFFS."

#Lets loop through any old executable files from previous runs and DELETE THEM ALL!
for i in "$MY_EXES"*"$EXE_EXTEN" ; do
	[[ -f "$i" ]] || continue
	rm "$i"
done

#Lets loop through all your generated .asm code and do a rudimentary check to see if it can compile. 
#If it (probably) can, compile it!
for i in "$MY_ASMS"*"$ASM_EXTEN" ; do
	[[ -f "$i" ]] || continue
	THENAME=$(basename "$i" $ASM_EXTEN)
	declare -i CANCOMPILE=$(grep "0 ERRORS" $MY_LSTS"$THENAME"$LST_EXTEN -c)
	if [ "$CANCOMPILE" -ge 1 ]; then
		echo "$i can (probably) compile.                               "
		nasm -f elf32 -o "$i" -o "$MY_ASMS""$THENAME".o "$MY_ASMS""$THENAME""$ASM_EXTEN" -I/usr/local/4301/include/ -I.
		ld -m elf_i386 --dynamic-linker /lib/ld-linux.so.2 -o "$MY_EXES""$THENAME""$EXE_EXTEN" "$MY_ASMS""$THENAME".o /usr/local/4301/src/Along32.o -lc
	else
		echo "$i can (probably) not compile, so I won't try."
	fi
	if $FANCY_OUTPUT ; then tput cuu1; fi
	#sleep 0.02
done
if $FANCY_OUTPUT ; then tput cud1; fi
#Lets run through all the provided Pascallite files again. 
#We're going to check for provided .lst and .asm files, and compare
#your output to what was provided, if anything!
printf '%s\n' "------------------------------------------------------------------"

printf '| %7s | %16s | %14s | %12s |\n' "The .dat" ".lst diffs" ".asm diffs" "Your executable"
printf '%s\n' "------------------------------------------------------------------"
printf '| %8s | %16s | %14s | %15s |\n' " " "No Error = (.)" " " " "
printf '| %8s | %16s | %14s | %15s |\n' " " "Has Error = (E)" " " " "
printf '%s\n' "------------------------------------------------------------------"

for i in "$PROVIDED_DATS"*.dat ; do 
	[[ -f "$i" ]] || continue
	THENAME=$(basename "$i" .dat)
	FILEEXISTS="$CLEAR""$THENAME"
	declare -i NO_ERRORS=$(grep "0 ERRORS" $MY_LSTS"$THENAME"$LST_EXTEN -c)
	if [ "$NO_ERRORS" -eq 1 ]; then
		ERROR_COUNT=".";
	else
		ERROR_COUNT="E";
	fi
	if [ -f "$PROVIDED_LSTS""$THENAME".lst ]; then
		diff -b <(sed '/STAGE[0-9]:/d' "$PROVIDED_LSTS""$THENAME".lst) <(sed '/STAGE[0-9]:/d' "$MY_LSTS""$THENAME""$LST_EXTEN") > /dev/null
		case $? in
		0) LSTFILE="$GREEN""CLN lst diff(""$ERROR_COUNT"")""$CLEAR";;  #Diff's clean!
		1) LSTFILE="$YELLOW""Warn: lst!(""$ERROR_COUNT"")""$CLEAR";; #Diff's not clean!
		2) LSTFILE="$RED""ERROR (lst)(""$ERROR_COUNT"")""$CLEAR";;    #Diff... broke?
		esac
	else
		LSTFILE="$CYAN""Unknown (lst)(""$ERROR_COUNT"")""$CLEAR"
	fi
	if [ -f "$PROVIDED_ASMS""$THENAME".asm ]; then
		diff -b <(sed '/; YOUR NAME(S)/d' "$PROVIDED_ASMS""$THENAME".asm ) <(sed "/; $ASM_NAME_STRING/d" "$MY_ASMS""$THENAME""$ASM_EXTEN") > /dev/null
		case $? in
			0) ASMFILE="$GREEN""CLN asm diff$CLEAR";;
			1) ASMFILE="$YELLOW""Warn: asm!$CLEAR";;
			2) ASMFILE="$RED""ERROR (asm)$CLEAR";;
		esac
	else
		ASMFILE="$CYAN""Unknown (asm)$CLEAR"
	fi
	if [ -f "$PROVIDED_ASMS""$THENAME".asm ]; then
		declare -i MIGHTCOMPILE=$(grep "Exit    {0}" "$PROVIDED_ASMS""$THENAME".asm -c)
		if [ "$MIGHTCOMPILE" -ge 1 ]; then
			if [ -f "$MY_EXES""$THENAME""$EXE_EXTEN" ]; then
				EXEFILE="$GREEN""Compiled (Good)""$CLEAR"
			else
				EXEFILE="$RED""Missing (Bad)""$CLEAR"
			fi
		else
			if [ -f "$MY_EXES""$THENAME""$EXE_EXTEN" ]; then
				EXEFILE="$RED""Compiled (Bad)""$CLEAR"
			else
				EXEFILE="$GREEN""Missing (Good)""$CLEAR"
			fi
		fi
	else
		declare -i MIGHTCOMPILE=$(grep "Exit    {0}" "$MY_ASMS""$THENAME""$ASM_EXTEN" -c)
		if [ "$MIGHTCOMPILE" -ge 1 ]; then
			if [ -f "$MY_EXES""$THENAME""$EXE_EXTEN" ]; then
				EXEFILE="$CYAN""Compiled (?)""$CLEAR"
			else
				EXEFILE="$RED""Missing (!)""$CLEAR"
			fi
		else
			if [ -f "$MY_EXES""$THENAME""$EXE_EXTEN" ]; then
				EXEFILE="$RED""Compiled (?!)""$CLEAR"
			else
				EXEFILE="$YELLOW""Missing (?)""$CLEAR"
			fi
		fi
	fi
	printf '| %13s' "$FILEEXISTS"
	printf '| %27s | %25s | %26s |\n' "$LSTFILE" "$ASMFILE" "$EXEFILE"
done

for an_executable in "$MY_EXES"*"$EXE_EXTEN" ; do
	[[ -f "$an_executable" ]] || continue #Lets not try to 'execute' on things that aren't officially FILES. Y'know, directories and such. Either it's a file, or we "continue" to the next loop in the cycle.
	THENAME=$(basename "$an_executable" "$EXE_EXTEN") #Lets just grab the name of the file, sans extension, so we have something to determine what test goes with what executable. 
	TEST_COUNT=$(ls -Uba1 "$MY_TEST_INPUTS"| grep -c "$THENAME".*\.in$) #Count how many tests you have for this executable. 
	[[ $TEST_COUNT -gt 0 ]] || { continue; } #echo "Tests for $an_executable not found. Skipping.";
	[[ -f "$MY_TEST_CHECKS""$TEST_NAME".out ]] || { echo "$an_executable lacks test output to compare to. Will still generate ""$MY_EXES""$THENAME""*$TEST_OUTPUT_EXTEN files."; }
	for a_test in "$MY_TEST_INPUTS""$THENAME"*.in ; do
		TESTNAME=$(basename "$a_test" .in)
		#Lets make a temporary file in /tmp/whatever_temporary_directory_we_made_at_the_start, we'll remove it after. 
		THIS_MAGICAL_PIPE=$(mktemp -u "$THE_TEMP_DIRECTORY""/""$TESTNAME""$MAGICALPIPE_INDICATOR"".XXXXXXXX")
		mkfifo "$THIS_MAGICAL_PIPE"
		wait
		( "$an_executable" < "$THIS_MAGICAL_PIPE" > "$MY_TEST_OUTPUTS""$TESTNAME""$TEST_OUTPUT_EXTEN" ) &
		#wait #DO NOT DO THIS. DO NOT WAIT. THIS WILL BREAK THE SCRIPT.
		(
		while IFS="" read -r THE_LINE || [ -n "$THE_LINE" ]
		do
			echo "$THE_LINE"
			sleep 0.01
		done < "$a_test" #THE INPUT FILE CAME FROM... BEHIND!
		) > "$THIS_MAGICAL_PIPE"
		wait
		rm "$THIS_MAGICAL_PIPE"
	done
done
