#!/usr/bin/env bash

filesdir=/home/ec2-user

# Attach and mount EBS volume that contains maps to instance
aws ec2 associate-address --instance-id "$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)" --allocation-id eipalloc-eafd14d7
aws ec2 attach-volume --device /dev/sdf --volume-id vol-0978f82ba79a9b6a0 --instance-id "$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)" --region ap-southeast-2
mount /dev/xvdf /mnt/
# Sync maps in volume with those on S3
aws s3 sync s3://utaunz /mnt --delete
# Link maps to Paks directory so server will pick them up
ln -s /mnt/* $filesdir/LinuxServer/UnrealTournament/Content/Paks/
# Pull other files from S3 into server directory
aws s3 sync s3://ut4-files-location/config $filesdir/LinuxServer/UnrealTournament/Saved/Config/LinuxServer
aws s3 sync s3://ut4-files-location/rulesets $filesdir/LinuxServer/UnrealTournament/Saved/Config/Rulesets
aws s3 sync s3://ut4-files-location/binaries $filesdir/LinuxServer/UnrealTournament/Binaries/Linux
aws s3 sync s3://ut4-files-location/plugins $filesdir/LinuxServer/UnrealTournament/Plugins
# Change permissions on new files
chgrp -R ec2-user /home/ec2-user/LinuxServer/UnrealTournament/Saved/Config/LinuxServer/*
chown -R ec2-user /home/ec2-user/LinuxServer/UnrealTournament/Saved/Config/LinuxServer/*
chgrp -R ec2-user /home/ec2-user/LinuxServer/UnrealTournament/Binaries/Linux/*
chown -R ec2-user /home/ec2-user/LinuxServer/UnrealTournament/Binaries/Linux/*
chgrp -R ec2-user /home/ec2-user/LinuxServer/UnrealTournament/Plugins/*
chown -R ec2-user /home/ec2-user/LinuxServer/UnrealTournament/Plugins/*

# Generate redirect references and checksums for each map in the Game config
for filename in /mnt/*.pak; do
  basename=$(basename $filename)
  checksum=$(md5sum $filename)
  echo "RedirectReferences=(PackageName=\"${basename::-4}\",PackageURLProtocol=\"https\",PackageURL=\"s3-ap-southeast-2.amazonaws.com/utaunz/$basename\",PackageChecksum=\"${checksum::32}\")" >> $filesdir/LinuxServer/UnrealTournament/Saved/Config/LinuxServer/Game.ini
done

# Create crontab and make server autorestart script run every minute
touch /var/spool/cron/root
crontab -l | { cat; echo "*/1 * * * * bash $filesdir/scripts/auto-restart.sh > /dev/null"; } | crontab -

# Start server (note that server cannot be started as root user)
su -c "$filesdir/LinuxServer/Engine/Binaries/Linux/UE4Server-Linux-Shipping UnrealTournament UT-Entry?Game=Lobby -log" ec2-user
