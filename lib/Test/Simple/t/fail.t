use strict;

# Can't use Test.pm, that's a 5.005 thing.
package My::Test;

print "1..2\n";

my $test_num = 1;
# Utility testing functions.
sub ok ($;$) {
    my($test, $name) = @_;
    my $ok = '';
    $ok .= "not " unless $test;
    $ok .= "ok $test_num";
    $ok .= " - $name" if defined $name;
    $ok .= "\n";
    print $ok;
    $test_num++;
}


package main;

require Test::Simple;

@INC = ('../lib', 'lib/Test/Simple');
require Catch;
my($out, $err) = Catch::caught();

Test::Simple->import(tests => 5);

ok( 1, 'passing' );
ok( 2, 'passing still' );
ok( 3, 'still passing' );
ok( 0, 'oh no!' );
ok( 0, 'damnit' );


END {
    My::Test::ok($$out eq <<OUT);
1..5
ok 1 - passing
ok 2 - passing still
ok 3 - still passing
not ok 4 - oh no!
not ok 5 - damnit
OUT

    My::Test::ok($$err eq <<ERR);
#     Failed test ($0 at line 35)
#     Failed test ($0 at line 36)
# Looks like you failed 2 tests of 5.
ERR

    # Prevent Test::Simple from exiting with non zero
    exit 0;
}
