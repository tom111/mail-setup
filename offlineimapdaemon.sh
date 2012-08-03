#!/bin/bash

# This script will check a if offlineimap is not running and an
# internet connections exists. In this case it will check the file
# ~/.offlineimap_lastlongsynctime for the last (unix-) time of a full
# sync.  If this is shorter than ${longsyncdiff} ago then do a quick
# sync, otherwise do a long one.

# Additionally this will send mail that has been saved using
# msmtp-queing everytime it finds an internet connection.

# WARNING: No guarentees. This might eat your mail in the case that it
# wrongly detects that offlineimap is not running and runs it
# again. (although offlineimap will also try to catch that case)

# Useful offlineimap options:
# -o run only once
# -f specify folders to sync
# -u choose interface to be quiet except in case of errors
# -l log to ~/.offlineimap.log

longcommand="offlineimap -o -u quiet"
shortcommand="offlineimap -o -f INBOX,acc1,acc2 -u quiet"
sendmailcommand="/home/tom/bin/msmtp-runqueue.sh"
# Time in seconds between long syncs:
longsyncdiff=1800 # 30 Minutes

# Check connection status
if ! ping -c1 www.google.com > /dev/null 2>&1; then 
    # Ping could be firewalled ...
    # '-O -' will redirect the actual html to stdout and thus to /dev/null
    if ! wget -O - www.google.com > /dev/null 2>&1; then
	# Both tests failed. We are probably offline 
	# (or google is offline, i.e. the end has come)
	exit 1;
    fi
fi

# We are online: So let's get mail going first
(${sendmailcommand} &> ~/.msmtp-queue.log) &

# Check if offlineimap is running:
pid=$(pgrep -f "/usr/bin/offlineimap")
if [[ ${pid} -gt 0 ]] ; then
    echo "Offlineimap is running with pid ${pid}"
    exit 1
fi

# Now we determine what to do based on the last time we did things:

curtime=$(date +%s)
if [ -e ~/.offlineimap_lastlongsynctime ] ; then 
    # Last sync file exists
    lastlongsync=$(<~/.offlineimap_lastlongsynctime) >/dev/null # The unix time of the last long sync
    timediff=$(( curtime - lastlongsync ))
    if [ ${timediff} -gt ${longsyncdiff} ]; then
	echo ${curtime} > ~/.offlineimap_lastlongsynctime
	exec ${longcommand}
    else
	exec ${shortcommand}
    fi
else
    # Do the long sync
    echo ${curtime} > ~/.offlineimap_lastlongsynctime
    exec ${longcommand}
fi 
