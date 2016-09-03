#!/usr/bin/env bash
# A simple script to tidy up a machine. May not be entirely forensically sound.
#
# This script works best if it is never written to disk. Consider storing it
# temporarily in memory (e.g. in /dev/shm). Or if you must, download it directly
# from an Internet location and pipe it directly into BASH:#
#
#   curl -ksL https://example.com/tidy_up.sh | sudo bash
#
clear

if [[ $UID -ne 0 ]]; then
    echo "This script runs best when you're root."
fi

pin=$(expr $RANDOM % 10000)

read -p "This script will tidy your machine clean. If you understand the
implications of what that means, proceed by typing in this PIN: $pin
# " u_pin
if [[ "$u_pin" == $pin ]]; then
    echo "PIN matched. Proceeding in 5..."
    echo "^C to cancel"
    sleep 5
else
    echo "PIN did not match. Exiting.."
    exit 1
fi

tidy_rm () {
    # Choose a better alternative to 'rm' and delete files asynchronously.

    tidy_rm=""
    if [[ $(type srm &> /dev/null; echo $?) == "0" ]]; then
        tidy_rm="srm -fz "
    elif [[ $(type shred &> /dev/null; echo $?) == "0" ]]; then
        tidy_rm="shred -fun 1 "
    else
        tidy_rm="rm -f "
    fi

    $tidy_rm $@
}

# Stop the bleeding
echo "unset HISTFILE" >> /etc/profile 
echo "history -c" >> ~/.bash_logout
unset HISTFILE
history -c
tidy_rm ~/.bash_history

# GnuPG cleanup
tidy_rm /root/.gnupg/secring.*
tidy_rm /root/.gnupg/trustdb.*
tidy_rm /root/.gnupg/pubring.*
tidy_rm /home/*/.gnupg/secring.*
tidy_rm /home/*/.gnupg/trustdb.*
tidy_rm /home/*/.gnupg/pubring.*

# SSH cleanup
tidy_rm /root/.ssh/*
tidy_rm /home/*/.ssh/*
tidy_rm /tmp/ssh*
# Password database cleanup
# find all *.kdb, *.kdbx files

# Sweep up home dir
tidy_rm ~/*
tidy_rm ~/.*

# Sweep up pesky logs
tidy_rm /var/log/wtmp
tidy_rm /var/log/btmp
tidy_rm /var/run/utmp
tidy_rm /var/log/dmesg
tidy_rm /var/log/*.log
tidy_rm /var/log/*.gz
tidy_rm /var/log/*
tidy_rm -r /var/log/*

# Invalidate password cache on sudo
sudo -k 

echo "done."
exit
