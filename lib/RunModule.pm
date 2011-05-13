package PerlDaemon::RunModule;

sub new ($$$) {
	my ($class, $conf) = @_;

	return bless { conf => $conf }, $class;
}

sub do ($) {
	my $self = shift;
	my $conf = $self->{conf};
	my $logger = $conf->{logger};

	$logger->logmsg('Test');
}

1;
