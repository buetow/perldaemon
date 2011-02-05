#!/usr/bin/perl

# Minimal Daemon (c) 2011 Paul Buetow

use strict;
use warnings;
use POSIX qw(setsid);

sub trimstr (@) {
	my @str = @_;

	for (@str) {
		chomp;
		s/^[\t\s]+//;
		s/[\t\s]+$//;
	}

	return @str;
}

sub logmsg ($$) {
	my ($config, $msg) = @_;
	my $logfile = $config->{logfile};

	open my $fh, ">>$logfile" or die "Can't write logfile: $!\n";
	print $fh localtime().": $msg\n";
	close $fh;
}

sub err ($$) {
	my ($config, $msg) = @_;
	logmsg $config => $msg;	
	die "$msg\n";
}

sub readconfig ($) {
	my $configfile = shift;

	open my $fh, $configfile or die "Can't read $configfile\n";
	my %config;
	
	while (<$fh>) {
		next if /^[\t\w]+#/;
		s/#.*//;

		my ($key, $val) = trimstr split '=', $_, 2;
		next unless defined $val;

		$config{$key} = $val;	
	}

	close $fh;

	# Check
	my $msg = 'Missing property:';

	foreach (qw(wd pidfile logfile)) {
		my $key = "daemon.$_";
		die "$msg $key\n" unless exists $config{$key};
	}

	logmsg \%config => "Reading $configfile complete";
	return \%config;
}

sub daemonize ($) {
	my $config = shift;
	logmsg $config => 'Daemonizing...';

	chdir $config->{wd} or err $config => "Can't chdir to wd: $!";

	my $msg = 'Can\'t read /dev/null:';

	open STDIN, '>/dev/null' or err $config => "$msg $!";
	open STDOUT, '>/dev/null' or err $config => "$msg $!";
	open STDERR, '>/dev/null' or err $config => "$msg $!";

	defined (my $pid = fork) or err $config => "Can't fork: $!";	
	exit if $pid;
	
	setsid or err $config => "Can't start a new session: $!";

	my $pidfile = $config->{pidfile};

	open my $fh, ">$pidfile" or err $config => "Can't write pidfile: $!";
	print $fh $$;
	close $fh;

	logmsg $config => 'Daemonizing completed';
}

sub signals ($) {
	my $config = shift;
}

sub daemonloop ($) {
	my $config = shift;

	for (;;) {
		logmsg $config => 'Hello';
		sleep 1;
	}
}

my $config = readconfig shift;

daemonize $config;
signals $config;
daemonloop $config;


