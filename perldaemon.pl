#!/usr/bin/perl

# Minimal Daemon (c) 2011 Paul Buetow

use strict;
use warnings;
use POSIX qw(setsid);

use constant VERSION => 1;

$| = 1;

sub trimstr (@) {
	my @str = @_;

	for (@str) {
		chomp;
		s/^[\t\s]+//;
		s/[\t\s]+$//;
	}

	return @str;
}

sub trunc ($) {
	my $file = shift;
	open my $fh, ">$file" or die "Can't write $file: $!\n";
	print $fh '';
	close $fh;
}

sub logmsg ($$) {
	my ($config, $msg) = @_;
	my $logfile = $config->{'daemon.logfile'};

	open my $fh, ">>$logfile" or die "Can't write logfile $logfile: $!\n";
	print $fh localtime()." (PID $$): $msg\n";
	close $fh;
}

sub err ($$) {
	my ($config, $msg) = @_;
	logmsg $config => $msg;	
	die "$msg\n";
}

sub checkpid ($) {
	my $config = shift;

	my $pidfile = $config->{'daemon.pidfile'};

	trunc $pidfile unless -f $pidfile;

	open my $fh, $pidfile or err $config => "Can't read pidfile $pidfile: $!";
	my ($pid) = <$fh>;
	close $fh;

	if (defined $pid) {
		chomp $pid;
		err $config => "Process with pid $pid already running" if 0 < int $pid && kill 0, $pid;
	}
}

sub writepid ($) {
	my $config = shift;

	my $pidfile = $config->{'daemon.pidfile'};

	open my $fh, ">$pidfile" or err $config => "Can't write pidfile: $!";
	print $fh "$$\n";
	close $fh;
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

	foreach (qw(wd pidfile logfile truncatelog)) {
		my $key = "daemon.$_";
		die "$msg $key\n" unless exists $config{$key};
	}

	logmsg \%config => "Reading $configfile complete";
	return \%config;
}

sub daemonize ($) {
	my $config = shift;
	logmsg $config => 'Daemonizing...';

	chdir $config->{'daemon.wd'} or err $config => "Can't chdir to wd: $!";

	my $msg = 'Can\'t read /dev/null:';

	open STDIN, '>/dev/null' or err $config => "$msg $!";
	open STDOUT, '>/dev/null' or err $config => "$msg $!";
	open STDERR, '>/dev/null' or err $config => "$msg $!";

	defined (my $pid = fork) or err $config => "Can't fork: $!";	
	exit if $pid;
	
	setsid or err $config => "Can't start a new session: $!";

	writepid $config;

	logmsg $config => 'Daemonizing completed';
}

sub prestartup ($) {
	my $config = shift;
	checkpid $config;

	trunc $config->{'daemon.logfile'} if $config->{'daemon.truncatelog'} eq 'yes';
}

sub daemonloop ($) {
	my $config = shift;

	my $loop = shift;
	for (my $i = 1;;++$i) {
		logmsg $config => VERSION .  ": Hello $i";
		sleep 3;
	}
}

my $config = readconfig shift;

prestartup $config;
daemonize $config;
daemonloop $config;


