#!/bin/bash

function none {
	echo "no options"
	/root/code/config-show.pl
}
function get_cluster {
	echo "fancy get operation"
	/root/code/clusters-get.pl
}
function set_cluster {
	echo "fancy set operation"
	/root/code/clusters-set.pl
}

if [ -z "$1" ]
then
	none
else
	case $1 in
		get)
			get_cluster
		;;
		set)
			set_cluster
		;;
	esac
fi

