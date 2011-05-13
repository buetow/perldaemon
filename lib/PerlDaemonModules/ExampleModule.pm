package PerlDaemonModules::ExampleModule;

sub new ($$$) {
	my ($class, $conf) = @_;

	return bless { conf => $conf }, $class;
}

sub do ($) {
	my $self = shift;
	my $conf = $self->{conf};
	my $logger = $conf->{logger};

	$logger->logmsg('ExampleModule Test');
}

1;
