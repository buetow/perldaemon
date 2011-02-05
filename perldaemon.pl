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

	# Check
	my $msg = 'Missing property:';

	foreach (qw(wd pidfile)) {
		my $key = "daemon.$_";
		die "$msg $key\n" unless exists $config{$key};
	}

	return \%config;
}

sub daemonize ($) {
	my $config = shift;

	chdir $config->{wd} or die "Can't chdir to wd: $!\n";

	my $msg = 'Can\'t read /dev/null:';

	open STDIN, '>/dev/null' or die "$msg $!\n";
	open STDOUT, '>/dev/null' or die "$msg $!\n";
	open STDERR, '>/dev/null' or die "$msg $!\n";

	defined (my $pid = fork) or die "Can't fork: $!\n";	
	exit if $pid;
	
	setsid or die "Can't start a new session: $!\n";
}

sub signals ($) {
	my $config = shift;
}

sub daemonloop ($) {
	my $config = shift;

	for (;;) {
		sleep 1;
	}
}

my $config = readconfig shift;

#daemonize $config;
signals $config;
daemonloop $config;


