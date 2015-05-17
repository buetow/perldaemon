package PerlDaemon::ThreadedLogger;

use strict;
use warnings;

$| = 1;

sub new ($$) {
  my ($class, $conf) = @_;
  my $self = $SELF = bless { conf => $conf }, $class;

  return $self;
}

sub _pushmsg ($$) {
  my ($self, $msg) = @_;
  my $conf = $self->{conf};
  my $msgqueue = $conf->{msgqueue};

  push @$msgqueue, $msg;
}

sub logmsg ($$) {
  my ($self, $msg) = @_;

  my $logline = localtime()." (PID $$): $msg\n";
  $self->_pushmsg($logline);

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

1;
