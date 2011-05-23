package PerlDaemon::RunModules;

use Time::HiRes qw(gettimeofday tv_interval);

sub new ($$) {
	my ($class, $conf) = @_;

	my $self = bless { conf => $conf }, $class;

	my $modulesdir = $conf->{'daemon.modulesdir'};
	my $logger = $conf->{logger};
        my %loadedmodules;
        my %scheduler;

        if (-d $modulesdir) {
                $logger->logmsg("Loading modules from $modulesdir");
                for my $module (<$modulesdir/*.pm>) {
                        $logger->logmsg("Loading $module");
                        require $module;
                }

                for my $name (grep /PerlDaemonModules/, keys %INC) {
                        $name =~ s#.*(PerlDaemonModules)/(.*)\.pm$#$1::$2#;
                        $logger->logmsg("Creating module instance of $name");
                        # TODO: Add eval catching jost un case for errors
                        $loadedmodules{$name} = eval "${name}->new(\$conf)";
                        $scheduler{$name}{lastrun} = 0.0;
                        $scheduler{$name}{interval} = $conf->{modulesruninterval};
                }

        } else {
                $logger->warn("Modules dir $modulesdir does not exist!");        
        }

        $conf->{modules} = \%loadedmodules;
        $conf->{scheduler} = \%scheduler;

        return $self;
}

sub do ($) {
	my $self = shift;
	my $conf = $self->{conf};
	my $logger = $conf->{logger};
	my $modules = $conf->{modules};
	my $scheduler = $conf->{scheduler};

        unless (%$modules) {
                $logger->warn("No modules are loaded!");
        } else {
                while (my ($k, $v) = each %$modules) {
                        $logger->logmsg("Triggering $k");
                        $scheduler->{$k}{lastrun} = gettimeofday;
                        $v->do();
                }
        }
}

1;
