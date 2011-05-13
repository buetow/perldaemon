package PerlDaemon::RunModules;

sub new ($$$) {
	my ($class, $conf) = @_;

	my $self = bless { conf => $conf }, $class;

	my $modulesdir = $conf->{'daemon.modulesdir'};
	my $logger = $conf->{logger};
        my %loadedmodules;

        if (-d $modulesdir) {
                $logger->logmsg("Loading modules from $modulesdir");
                for my $module (<$modulesdir/*.pm>) {
                        $logger->logmsg("Loading $module");
                        require $module;
                }

                for my $name (grep /PerlDaemonModules/, keys %INC) {
                        $name =~ s#.*(PerlDaemonModules)/(.*)\.pm$#$1::$2#;
                        $logger->logmsg("Creating module instance of $name");
                        $loadedmodules{$name} = eval "${name}->new(\$conf)";
                }

        } else {
                $logger->warn("Modules dir $modulesdir does not exist!");        
        }

        $conf->{modules} = \%loadedmodules;
        return $self;
}

sub do ($) {
	my $self = shift;
	my $conf = $self->{conf};
	my $logger = $conf->{logger};
	my $modules = $conf->{modules};

        unless (%$modules) {
                $logger->warn("No modules are loaded!");
        } else {
                while (my ($k, $v) = each %$modules) {
                        $logger->logmsg("Triggering $k");
                        $v->do();
                }
        }
}

1;
