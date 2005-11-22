use Sub::Install qw(reinstall_sub);
use Test::More 'no_plan';
use warnings;

# These tests largely copied from Damian Conway's Sub::Installer tests.

# Install a sub in a package...

my $sub_ref = reinstall_sub({ code => \&ok, as => 'ok1' });

is ref $sub_ref, 'CODE'                  => 'reinstall returns code ref';

is_deeply \&Test::More::ok, $sub_ref     => 'reinstall returns correct code ref';

$sub_ref->(1                             => 'returned code ref runs');
ok1(1                                    => 'reinstalled sub runs');


# Install the same sub in the same package...

$SIG{__WARN__} = sub { ok 0 => "warned unexpected: @_" if $_[0] =~ /redefined/ };

$sub_ref = reinstall_sub({ code => \&is, as => 'ok1' });

is ref $sub_ref, 'CODE'                  => 'reinstall2 returns code ref';

is_deeply \&Test::More::is, $sub_ref     => 'reinstall2 returns correct code ref';

$sub_ref->(1, 1                          => 'returned code ref runs');
ok1(1,1                                  => 'reinstalled sub reruns');

# Install in another package...

my $new_code = sub { ok(1, "remotely installed sub runs") };

$sub_ref = reinstall_sub({
  code => $new_code,
  into => 'Other',
  as   => 'ok1',
});

is ref $sub_ref, 'CODE'                  => 'reinstall3 returns code ref';

is_deeply $new_code, $sub_ref            => 'reinstall3 returns correct code ref';

ok1(1,1                                  => 'reinstalled sub reruns');

package Other;

ok1();
