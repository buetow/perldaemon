package PerlDaemon::RunModules;

sub new ($$$) {
	my ($class, $conf) = @_;

	my $self = bless { conf => $conf }, $class;

	my $modulesdir = $conf->{'daemon.modulesdir'};
	my $logger = $conf->{logger};

        if (-d $modulesdir) {
                $logger->logmsg("Loading modules from $modulesdir");        
        }

        return $self;
}

sub do ($) {
	my $self = shift;
	my $conf = $self->{conf};
	my $logger = $conf->{logger};
}

1;
