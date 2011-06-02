package PerlDaemon::RunModules;

use Time::HiRes qw(gettimeofday tv_interval);

sub new ($$) {
	my ($class, $conf) = @_;

	my $self = bless { conf => $conf }, $class;

	my $modulesdir = $conf->{'daemon.modules.dir'};
	my $logger = $conf->{logger};
        my %loadedmodules;
        my %scheduler;

        if (-d $modulesdir) {
                $logger->logmsg("Loading modules from $modulesdir");
                for my $module (<$modulesdir/*.pm>) {
                        $logger->logmsg("Loading $module");
                        eval "require '$module'";
                        $logger->warn("Could not load module source file $module: $@")
                                if defined $@ and length $@;
                }

                for my $name (grep /PerlDaemonModules/, keys %INC) {
                        $name =~ s#.*(PerlDaemonModules)/(.*)\.pm$#$1::$2#;
                        my $module = eval "${name}->new(\$conf)";

                        if (defined $@ and length $@) {
                                $logger->warn("Could not create module instance $name: $@");        

                        } else {
                                $loadedmodules{$name} = $module;
                                $scheduler{$name}{lastrun} = [0,0];
                                $scheduler{$name}{interval} = $conf->{'daemon.modules.runinterval'};
                                $logger->logmsg("Created module instance $name");
                        }
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
                        my $now = [gettimeofday];
                        my $timediff = tv_interval($scheduler->{$k}{lastrun}, $now);
                        my $interval = $scheduler->{$k}{interval};

                        if ($timediff >= $interval) {
                                $logger->logmsg("Triggering $k (last run before ${timediff}s; wanted interval: ${interval}s)");
                                $scheduler->{$k}{lastrun} = $now;
                                $v->do();
                        }
                }
        }
}

1;
