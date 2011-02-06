#!/bin/bash

case $1 in
	start)
	perl perldaemon.pl perldaemon.conf
	;;

	stop)
	kill $(cat perldaemon.pid)
	;;

	logrotate)
	kill -HUP $(cat perldaemon.pid)
	;;

	*)
	echo "Usage: $0 <start|stop|logrotate>"
	exit 1
	;;
esac
