#!/usr/bin/expect

set timeout 20
spawn "/root/vmware-vsphere-cli-distrib/vmware-install.pl"

sleep 1
expect "Press enter to display it." { send "\r" }
sleep 1
expect {
	"*More*" {send " "; exp_continue}
	"*Do you accept?*" {send -- "\ryes\r"}
}
expect "Do you accept? (yes/no)" { send "yes\r" }
expect "Do you want to install precompiled Perl modules for RHEL?" { send "\r" }
sleep 3
expect "In which directory do you want to install the executable files?" { send "\r" }

#interact
