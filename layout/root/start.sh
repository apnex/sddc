#!/bin/bash

function none {
	/root/code/config-show.pl
}
function get_cluster {
	/root/code/clusters-get.pl
}
function set_cluster {
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

