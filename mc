#!/bin/bash
minecraftDir=""
backupDir=""
logDir="/home/mcserver/log/"
dateStamp=$(date +%Y-%m-%d)
minecraftJar='fabric-server-launch.jar'
mcWorld=''
screenZip='screenZip'
screenSession='minecraft_server'
JVM_Options="nogui"
JVM_Arguments="java -Xmx50G -Xms50G -XX:+UnlockExperimentalVMOptions -XX:ParallelGCThreads=16 \
-XX:ConcGCThreads=2 -XX:+UseStringDeduplication -XX:+OptimizeStringConcat -XX:+UseSuperWord \
-XX:+OptimizeFill -XX:+UseBiasedLocking -XX:LoopUnrollMin=4 -XX:LoopMaxUnroll=16 -XX:+UseLoopPredicate \
-XX:+RangeCheckElimination -XX:+DisableExplicitGC -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1MaxNewSizePercent=30 \
-XX:G1MixedGCLiveThresholdPercent=35 -XX:-UsePerfData -XX:G1ReservePercent=20 -XX:G1HeapRegionSize=32M \
-XX:MaxGCPauseMillis=100 -XX:SurvivorRatio=8 -XX:TargetSurvivorRatio=90 -XX:MaxTenuringThreshold=15 \
-XX:+UseCompressedOops -XX:+UseCodeCacheFlushing -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled \
-XX:+PerfDisableSharedMem  -XX:InitiatingHeapOccupancyPercent=10 -XX:+DoEscapeAnalysis -XX:+EliminateLocks"
helpMenu="
		The commands are...
	mc -start	-->	Starts your minecraft server.
	mc -stop	-->	Stops your minecraft server.
	mc -restart	-->	Restarts your minecraft server.
	mc -backup	-->	Backs up your server folder and creates a zip file in your backup folder.
	mc -help	-->	Gets you to this menu.
	"
mc_start() {
	if  pgrep -f $minecraftJar > /dev/null ; then
		echo "$minecraftJar is already running!"
	else
		echo "Starting $minecraftJar..."
		cd $minecraftDir
		screen -dmS $screenSession -L -Logfile $logDir/$mcWorld-$dateStamp.log $JVM_Arguments -jar $minecraftJar $JVM_Options
		sleep 7
		if pgrep -f $minecraftJar > /dev/null ; then
			echo "$minecraftJar is now running type screen -r $screenSession to monitor."
		else
			echo "Error! Could not start $minecraftJar!"
		fi
	fi
}
mc_saveoff() {
	if pgrep -f $minecraftJar > /dev/null ; then
		echo "$minecraftJar is running... suspending saves"
		screen -S $screenSession -X eval "stuff \"save-off\"\015"
		screen -S $screenSession -X eval "stuff \"save-all\"\015"
		sync
		sleep 10
    else
		echo "$minecraftJar is not running. Not suspending saves."
    fi
}
mc_saveon() {
    if pgrep -f $minecraftJar > /dev/null ; then
		echo "$minecraftJar is running... re-enabling saves"
		screen -S $screenSession -X eval "stuff \"save-on\"\015"
		screen -S $screenSession -X eval "stuff \"save-all\"\015"
    else
		echo "$minecraftJar is not running. Not resuming saves."
    fi
}
mc_stop() {
	if pgrep -f $minecraftJar > /dev/null ; then
		echo "Stopping $minecraftJar"
		screen -S $screenSession -X eval "stuff \"save-all\"\015"
		screen -S $screenSession -X eval "stuff \"stop\"\015"
		sleep 10
	else
		echo "$minecraftJar was not running."
		exit
    fi
    if pgrep -f $minecraftJar > /dev/null ; then
		echo "Error! $minecraftJar could not be stopped."
	else
		echo "$minecraftJar is stopped."
    fi
}
mc_backup() {
	if pgrep -f $minecraftJar > /dev/null ; then
		screen -S $screenSession -X eval "stuff \"say Backup Started.\"\015"
		mc_saveoff
		sleep 5
		rm -rvf $backupDir-$dateStamp*
		mkdir $backupDir-$dateStamp
		rsync -avr $minecraftDir/* $backupDir-$dateStamp
		sleep 1
		screen -S $screenSession -X eval "stuff \"say Serverfiles backuped up, making zip file. Automatic Saving can be turned back on.\"\015"
		mc_saveon
		sleep 1
		rm -rvf $backupDir-$dateStamp.zip
		echo "Compressing backup..."
		sleep 1 &
		rm -rvf $logDir/serverZip.log
		screen -dmS $screenZip -L -Logfile $logDir/serverZip-$dateStamp.log zip -rv -dcdb -3 $backupDir-$dateStamp $backupDir-$dateStamp
		echo "Compression Started in screen (type screen -r for status)."
	else
		rm -rvf $backupDir-$dateStamp*
		mkdir $backupDir-$dateStamp
		rsync -avr $minecraftDir/* $backupDir-$dateStamp
		sleep 1
		rm -rvf $backupDir-$dateStamp.zip
		echo "Compressing backup..."
		sleep 1
		rm -rvf $logDir/serverZip.log
		screen -dmS $screenZip -L -Logfile $logDir/serverZip.log zip -rv -dcdb -3 $backupDir-$dateStamp $backupDir-$dateStamp
		echo "Compression Started in screen (type screen -r $screenZip for status)."
	fi
}
case "$1" in
	-start)
	mc_start
	exit;;
	-stop)
	screen -S $screenSession -X eval "stuff \"say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map...\"\015"
	mc_stop
	exit;;
	-restart)
	screen -S $screenSession -X eval "stuff \"say Server Restarting.\"\015"
	sleep 5
	mc_stop
	mc_start
	exit;;
	-backup)
	mc_backup
	exit;;
	-help)
	echo "$helpMenu"
	exit;;
	*)
	echo "$helpMenu"
	exit;;
esac

