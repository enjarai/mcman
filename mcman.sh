#!/bin/bash

function usage {
  echo "Usage: $(basename $0) [ARGS] [OPTION]" 2>&1
  echo 'Manage Minecraft servers using screens.'
  echo  
  echo '   start        Start a server'
  echo '     -d DIRECTORY	Specify the server directory'
  echo '     -f FILE      Specify the file to run to start the server, has to be directly executable'
  echo '     -t           Dont attach to the screen'
	echo '   attach       Reattach to a running server console'
	echo '     -s           Start server if not running already, works with arguments from the start option'
	echo '   stop         Stop a running server'
	echo '     -k           Force stopping the server'
	echo '   restart      Restart a running server'
	echo
	echo '   -n NAME      Specify the server name, defaults to "mc-auto"'
  echo 
	echo 'v1.1'
  echo 'Made by enjarai'
  exit 1
}

function start_server {
	
	if [ -f "$directory/$startfile" ]; then
		screen $noattach -S $screenname -m bash -c "echo 'Starting server, press ctrl+a and ctrl+d in succession to detach from the console.'
cd $directory
while true; do
	$directory/$startfile
	rm '/tmp/mcman.$screenname.no_restart' &> /dev/null && break
	if screen -list | grep '$screenname' | grep '(Attached)' &> /dev/null; then 
		read -n 1 -s -r -p 'Press any key to continue'
		break
	fi
done"
	else # screen -list | grep "test" | grep "(Attached)"
		echo "Create '$startfile' first."
		exit 2
	fi
}													

function wait_for_screen {
	while screen -list | grep -q "$screenname"; do
		sleep 1
	done
}

function stop_server {
	if $forcekill; then
    screen -XS "$screenname" quit
  else
  	screen -XS "$screenname" -p 0 stuff "stop^M"
	fi
}

if [[ ${#} -eq 0 ]]; then
  usage
fi

startfile="start.sh"
directory="./"
screenname="mc-auto"
startserver=false
forcekill=false

while [ $# -gt 0 ] && [ "$1" != "--" ]; do
	while getopts ":d:f:tn:sk" arg; do
		case ${arg} in
			d)
				directory="${OPTARG}"
				;;
			f)
				startfile="${OPTARG}"
				;;
			t)
				noattach="-d"
				;;
			n)
				screenname="${OPTARG}"
				;;
			s)
				startserver=true
				;;
			k)
				forcekill=true
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
		if screen -list | grep -q "$screenname"; then
			echo "A server is already running."
			exit 2
		fi
		start_server
		;;
	attach)
		screen -x "$screenname" || (
			if $startserver; then
				start_server
			else
				echo "Start a server first."
				exit 2
			fi
		) 
		;;
	stop)
		touch "/tmp/mcman.$screenname.no_restart"
		stop_server
		wait_for_screen
		;;
	restart)
		stop_server
		;;
	*)
		usage
		;;
esac
