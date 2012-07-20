#!/bin/bash
# Export the dbus session address on startup so it can be used by cron
touch $HOME/.Xdbus
chmod 600 $HOME/.Xdbus
env | grep DBUS_SESSION_BUS_ADDRESS > $HOME/.Xdbus
echo 'export DBUS_SESSION_BUS_ADDRESS' >> $HOME/.Xdbus
