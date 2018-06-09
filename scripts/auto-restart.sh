#!/usr/bin/env bash

ps auxw | grep UE4Server-Linux-Shipping | grep -v grep > /dev/null

# if not found - equals to 1, start it
if [ $? != 0 ]; then
  echo "Server is not running"
  echo "Attempting to start ..."
  su -c "/home/ec2-user/LinuxServer/Engine/Binaries/Linux/UE4Server-Linux-Shipping UnrealTournament UT-Entry?Game=Lobby -log" ec2-user
else
  echo "The Server is already running"
fi
