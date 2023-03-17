#!/bin/bash

# Minecraft server configuration

mc_world=""
version=""
minecraft_dir="/path/to/$version/serverfiles"
world_dir="/path/to/$version/serverfiles/$mc_world"
backup_dir="/path/to/backups"
log_dir="/path/to/backups/logs/"
date_stamp=$(date +%Y-%m-%d)
minecraft_jar='fabric-server-launch.jar'
screen_zip='screenZip'
screen_session='minecraft_server'
jvm_options="nogui"
jvm_arguments="java -Xms25G -Xmx25G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dlog4j2.formatMsgNoLookups=true"

number_of_backups=3
help_menu="
    The commands are...
mcserver -start    --> Starts your minecraft server.
mcserver -stop     --> Stops your minecraft server.
mcserver -restart  --> Restarts your minecraft server.
mcserver -backup   --> Backs up your server folder and creates a zip file in your backup folder.
mcserver -help     --> Gets you to this menu.
"
