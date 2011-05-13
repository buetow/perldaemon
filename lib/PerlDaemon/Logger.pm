package PerlDaemon::Logger;

use Shell qw(mv);
use POSIX qw(strftime);

$| = 1;

sub new ($$) {
	my ($class, $conf) = @_;
	return bless { conf => $conf }, $class;
}

sub logmsg ($$) {
	my ($self, $msg) = @_;
	my $conf = $self->{conf};
	my $logfile = $conf->{'daemon.logfile'};

	open my $fh, ">>$logfile" or die "Can't write logfile $logfile: $!\n";
	print $fh localtime()." (PID $$): $msg\n";
	close $fh;

        return undef;
}

sub err ($$) {
	my ($self, $msg) = @_;
	$self->logmsg($msg);
	die "$msg\n";
}

sub warn ($$) {
	my ($self, $msg) = @_;
	$self->logmsg("WARNING: $msg");

        return undef;
}

sub rotatelog ($) {
	my $self = shift;
	my $conf = $self->{conf};
	my $logfile = $conf->{'daemon.logfile'};

	$self->logmsg('Rotating logfile');

	my $timestr = strftime "%Y%m%d-%H%M%S", localtime();
	mv($logfile, "$logfile.$timestr");	

        return undef;
}

1;
