#!/bin/bash

case $1 in
	start)
	perl PerlDaemon/PerlDaemon.pl ./conf/perldaemon.conf
	;;

	stop)
	kill $(cat ./run/perldaemon.pid)
	;;

	logrotate)
	kill -HUP $(cat ./run/perldaemon.pid)
	;;

	*)
	echo "Usage: $0 <start|stop|logrotate>"
	exit 1
	;;
esac
