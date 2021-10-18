# mcman

Simple bash script to manage Minecraft servers using screens.

Current options:

```
start        Start a server
  -d DIRECTORY Specify the server directory
  -f FILE      Specify the file to run to start the server, has to be directly executable
  -t           Dont attach to the screen
 attach       Reattach to a running server console
  -s           Start server if not running already, works with arguments from the start option
stop         Stop a running server
  -k           Force stopping the server
restart      Restart a running server
send         Send input to the console of a running server
  -m           Input to send
  
-n NAME      Specify the server name, defaults to "mc-auto"
  echo 
```
