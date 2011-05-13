package PerlDaemon::RunModules;

sub new ($$$) {
	my ($class, $conf) = @_;

	my $self = bless { conf => $conf }, $class;

	my $modulesdir = $conf->{'daemon.modulesdir'};
	my $logger = $conf->{logger};

        if (-d $modulesdir) {
                $logger->logmsg("Loading modules from $modulesdir");        

        } else {
                $logger->warn("Modules dir $modulesdir does not exist!");        
        }

        return $self;
}

sub do ($) {
	my $self = shift;
	my $conf = $self->{conf};
	my $logger = $conf->{logger};

        $logger->warn("No modules are loaded!");
}

1;
