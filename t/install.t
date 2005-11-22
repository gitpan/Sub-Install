use Sub::Install;
use Test::More 'no_plan';
use warnings;

# These tests largely copied from Damian Conway's Sub::Installer tests.

# Install a sub in a package...

my $sub_ref = Sub::Install::install_sub({ code => \&ok, as => 'ok1' });

is ref $sub_ref, 'CODE'                  => 'install returns code ref';

is_deeply \&ok, $sub_ref                 => 'install returns correct code ref';

ok1(1                                    => 'installed sub runs');


# Install the same sub in the same package...

$SIG{__WARN__} = sub { ok 1 => 'warned as expected' if $_[0] =~ /redefined/ };


$sub_ref = Sub::Install::install_sub({ code => \&is, as => 'ok1' });

is ref $sub_ref, 'CODE'                  => 'install2 returns code ref';

is_deeply \&is, $sub_ref                 => 'install2 returns correct code ref';

ok1(1,1                                  => 'installed sub reruns');

# Install in another package...

$sub_ref = Sub::Install::install_sub({
  code => \&ok,
  into => 'Other',
  as   => 'ok1'
});

is ref $sub_ref, 'CODE'                  => 'install3 returns code ref';

is_deeply \&ok, $sub_ref                 => 'install3 returns correct code ref';

ok1(1,1                                  => 'installed sub reruns');

package Other;

ok1(1                                    => 'remotely installed sub runs');
