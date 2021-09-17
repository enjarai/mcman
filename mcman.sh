#!/bin/bash

function usage {
	echo "Usage: $(basename $0) [ARGS] [OPTION]" 2>&1
	echo 'Manage Minecraft servers using screens.'
	echo 
	echo '   start        Start a server'
	echo '   attach       Reattach to a running server console'
	echo 
  	echo '   -d DIRECTORY	Specify the server directory'
	echo '   -s FILE      Specify the file to run to start the server, has to be directly executable'
	echo '   -t           Dont attach to the screen'
	echo 
	echo 'v1.0'
	echo 'Made by enjarai'
	exit 1
}

if [[ ${#} -eq 0 ]]; then
  usage
fi

startfile="start.sh"
directory="./"

while [ $# -gt 0 ] && [ "$1" != "--" ]; do
	while getopts ":d:s:t" arg; do
		case ${arg} in
			d)
				directory="${OPTARG}"
				;;
			s)
				startfile="${OPTARG}"
				;;
			t)
				noattach="-d"
				;;
			?)
				echo "Invalid option: -${OPTARG}."
				echo
				usage
				;;
		esac
	done

	shift $((OPTIND-1))
	if [ $# -gt 0 ]; then
		option="$1"
		shift
	fi
done


case $option in
	start)
		if screen -list | grep -q "mc-auto"; then
			echo "A server is already running."
			exit 2
		fi
		if [ -f "$directory/$startfile" ]; then
			screen $noattach -S mc-auto -m bash -c "echo 'Starting server, press ctrl+a and ctrl+d in succession to detach from the console.'
cd $directory
$directory/$startfile
read -n 1 -s -r -p 'Press any key to continue'"
		else
			echo "Create '$startfile' first."
			exit 2
		fi
		;;
	attach)
		screen -x mc-auto || (echo "Start a server first."; exit 2) 
		;;
	*)
		usage
		;;
esac
