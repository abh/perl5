################################################################################
#
#            !!!!!   Do NOT edit this file directly!   !!!!!
#
#            Edit mktests.PL and/or parts/inc/grok instead.
#
################################################################################

BEGIN {
  if ($ENV{'PERL_CORE'}) {
    chdir 't' if -d 't';
    @INC = ('../lib', '../ext/Devel/PPPort/t') if -d '../lib' && -d '../ext';
    require Config; import Config;
    use vars '%Config';
    if (" $Config{'extensions'} " !~ m[ Devel/PPPort ]) {
      print "1..0 # Skip -- Perl configured without Devel::PPPort module\n";
      exit 0;
    }
  }
  else {
    unshift @INC, 't';
  }

  sub load {
    eval "use Test";
    require 'testutil.pl' if $@;
  }

  if (10) {
    load();
    plan(tests => 10);
  }
}

use Devel::PPPort;
use strict;
$^W = 1;

ok(&Devel::PPPort::grok_number("42"), 42);
ok(!defined(&Devel::PPPort::grok_number("A")));
ok(&Devel::PPPort::grok_bin("10000001"), 129);
ok(&Devel::PPPort::grok_hex("deadbeef"), 0xdeadbeef);
ok(&Devel::PPPort::grok_oct("377"), 255);

ok(&Devel::PPPort::Perl_grok_number("42"), 42);
ok(!defined(&Devel::PPPort::Perl_grok_number("A")));
ok(&Devel::PPPort::Perl_grok_bin("10000001"), 129);
ok(&Devel::PPPort::Perl_grok_hex("deadbeef"), 0xdeadbeef);
ok(&Devel::PPPort::Perl_grok_oct("377"), 255);

