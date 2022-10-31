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
	echo '   send         Send input to the console of a running server'
	echo '     -m           Input to send'
	echo '   create       Create a new server in a directory'
	echo '     -j           Java binary to use, defaults to "java"'
	echo '     -M           Minecraft version to use, defaults to latest'
	echo '     -d DIRECTORY	The server directory'
	echo
	echo '   -n NAME      Specify the server name, defaults to "mc-auto"'
	echo 
	echo 'v1.3'
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
		send_input "stop"
	fi
}

function send_input {
	screen -XS "$screenname" -p 0 stuff "^M$1^M"
}

function create {
	read -n 1 -s -r -p "Press any key to accept the Minecraft EULA, or ctrl+C to cancel."

	installer="fabric-installer-${fabricinstallerversion}.jar"
	installerpath="$directory/$installer"
	
	wget "https://maven.fabricmc.net/net/fabricmc/fabric-installer/$fabricinstallerversion/$installer" -P "$directory/"
	opts=""

	opts+="-dir $directory "
	if [ "$minecraftversion" != "latest" ]; then
		opts+="-mcversion $minecraftversion "
	fi
	opts+="-downloadMinecraft "

	$java -jar "$installerpath" server $opts
	echo "$sensibleserverproperties" > $directory/server.properties

	echo "$java -Xmx2G -jar fabric-server-launch.jar nogui" > $directory/start.sh
	chmod u+x start.sh
}

if [[ ${#} -eq 0 ]]; then
  usage
fi

startfile="start.sh"
directory="./"
screenname="mc-auto"
startserver=false
forcekill=false
java="java"
fabricinstallerversion="0.11.1"
minecraftversion="latest"
sensibleserverproperties="
	motd=A Minecraft Server
	server-port=25565
	difficulty=normal
	level-seed=
	white-list=false
	enforce-whitelist=false

	enable-jmx-monitoring=false
	rcon.port=25575
	enable-command-block=true
	gamemode=survival
	enable-query=false
	generator-settings={}
	enforce-secure-profile=false
	level-name=world
	query.port=25565
	pvp=true
	generate-structures=true
	max-chained-neighbor-updates=1000000
	network-compression-threshold=256
	max-tick-time=60000
	require-resource-pack=false
	max-players=20
	use-native-transport=true
	online-mode=true
	enable-status=true
	allow-flight=true
	broadcast-rcon-to-ops=true
	view-distance=10
	resource-pack-prompt=
	server-ip=
	allow-nether=true
	enable-rcon=false
	sync-chunk-writes=true
	op-permission-level=4
	prevent-proxy-connections=false
	hide-online-players=false
	resource-pack=
	entity-broadcast-range-percentage=100
	simulation-distance=10
	rcon.password=
	player-idle-timeout=0
	force-gamemode=false
	rate-limit=0
	hardcore=false
	broadcast-console-to-ops=true
	previews-chat=false
	spawn-npcs=true
	spawn-animals=true
	function-permission-level=2
	level-type=minecraft\:normal
	text-filtering-config=
	spawn-monsters=true
	spawn-protection=0
	resource-pack-sha1=
	max-world-size=29999984
"

while [ $# -gt 0 ] && [ "$1" != "--" ]; do
	while getopts ":d:f:tn:skm:j:M:" arg; do
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
			m)
				message="${OPTARG}"
				;;
			j)
				java="${OPTARG}"
				;;
			M)
				minecraftversion="${OPTARG}"
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
	send)
		send_input "$message"
		;;
	create)
		create
		;;
	*)
		usage
		;;
esac
