package Sub::Install;

use warnings;
use strict;

use Carp qw(croak);

=head1 NAME

Sub::Install - install subroutines into packages easily

=head1 VERSION

version 0.01

 $Id: /my/rjbs/subinst/lib/Sub/Install.pm 16598 2005-11-22T03:30:52.663848Z rjbs  $

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use Sub::Install;

  Sub::Install::install_sub({
    code => sub { ... },
    into => $package,
    as   => $subname
  });

=head1 DESCRIPTION

This module makes it easy to install subroutines into packages without the
unslightly mess of C<no strict> or typeglobs lying about where just anyone can
see them.

=head1 FUNCTIONS

=head2 C< install_sub >

  Sub::Install::install_sub({
   code => \&subroutine,
   into => "Finance::Shady",
   as   => 'launder',
  });

This routine installs a given code reference into a package as a normal
subroutine.  The above is equivalent to:

  no strict 'refs';
  *{"Finance::Shady" . '::' . "launder"} = \&subroutine;

If C<into> is not given, the sub is installed into the calling package.

If C<code> is not a code reference, it is looked for as an existing sub in the
package named in the C<from> parameter.  If C<from> is not given, it will look
in the calling package.

If C<as> is not given, and if C<code> is a name, C<as> will default to C<code>.
If C<as> is not given, but if C<code> is a code ref, Sub::Install will try to
find the name of the given code ref and use that as C<as>.

That means that this code:

  Sub::Install::install_sub({
    code => 'twitch',
    from => 'Person::InPain',
    into => 'Person::Teenager',
    as   => 'dance',
  });

is the same as:

  package Person::Teenager;

  Sub::Install::install_sub({
    code => Person::InPain->can('twitch'),
    as   => 'dance',
  });

=cut

sub install_sub {
  _process_arg_and_install($_[0]);
}

=head2 C< reinstall_sub >

This routine behaves exactly like C<L</install_sub>>, but does not emit a
warning if warnings are on and the destination is already defined.

=cut

sub reinstall_sub {
  _process_arg_and_install($_[0], \&_reinstall);
}

# do the heavy lifting
sub _process_arg_and_install {
  my ($arg, $installer) = @_;

  $installer ||= \&_install;

  my ($calling_pkg) = caller(1);

  $arg->{into} ||= $calling_pkg;
  $arg->{from} ||= $calling_pkg;

  croak "named argument 'code' is not optional" unless $arg->{code};

  if (ref $arg->{code} eq 'CODE') {
    unless ($arg->{as}) {
      require B;
      my $name = B::svref_2object($arg->{code})->GV->NAME;  
      $name =~ s/\A.+:://g;
      $arg->{as} = $name;
    }
  } else {
    my $code = $arg->{from}->can($arg->{code});

    croak "couldn't find subroutine named $arg->{code} in package $arg->{from}"
      unless $code;

    $arg->{as} ||= $arg->{code};
    $arg->{code} = $code;
  }

  croak "couldn't determine name under which to install subroutine"
    unless $arg->{as};

  $installer->($arg->{code} => $arg->{into} . '::' . $arg->{as});

  return $arg->{code};
}

# do the ugly work
sub _install {
  my ($code, $fullname) = @_;
  no strict 'refs';
  *$fullname = $code;
}

sub _reinstall {
  my ($code, $fullname) = @_;
  no strict 'refs';
  no warnings;
  *$fullname = $code;
}

sub import {
  my $class  = shift;
  my %import = map { $_ => 1 } @_;
  my ($target) = caller(0);

  for (qw(install_sub reinstall_sub)) {
    install_sub({ code => $_, into => $target }) if ($import{$_});
  }
}

=head1 AUTHOR

Ricardo Signes, C<< <rjbs@cpan.org> >>

This module is (obviously) a reaction to L<Sub::Installer>, which does the same
thing, but does it by getting its greasy fingers all over UNIVERSAL.

=head1 TODO

This module needs more tests.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-sub-install@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2005 Ricardo Signes, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
