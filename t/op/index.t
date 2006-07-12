#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
}

use strict;
require './test.pl';
plan( tests => 66 );

my $foo = 'Now is the time for all good men to come to the aid of their country.';

my $first = substr($foo,0,index($foo,'the'));
is($first, "Now is ");

my $last = substr($foo,rindex($foo,'the'),100);
is($last, "their country.");

$last = substr($foo,index($foo,'Now'),2);
is($last, "No");

$last = substr($foo,rindex($foo,'Now'),2);
is($last, "No");

$last = substr($foo,index($foo,'.'),100);
is($last, ".");

$last = substr($foo,rindex($foo,'.'),100);
is($last, ".");

is(index("ababa","a",-1), 0);
is(index("ababa","a",0), 0);
is(index("ababa","a",1), 2);
is(index("ababa","a",2), 2);
is(index("ababa","a",3), 4);
is(index("ababa","a",4), 4);
is(index("ababa","a",5), -1);

is(rindex("ababa","a",-1), -1);
is(rindex("ababa","a",0), 0);
is(rindex("ababa","a",1), 0);
is(rindex("ababa","a",2), 2);
is(rindex("ababa","a",3), 2);
is(rindex("ababa","a",4), 4);
is(rindex("ababa","a",5), 4);

# tests for empty search string
is(index("abc", "", -1), 0);
is(index("abc", "", 0), 0);
is(index("abc", "", 1), 1);
is(index("abc", "", 2), 2);
is(index("abc", "", 3), 3);
is(index("abc", "", 4), 3);
is(rindex("abc", "", -1), 0);
is(rindex("abc", "", 0), 0);
is(rindex("abc", "", 1), 1);
is(rindex("abc", "", 2), 2);
is(rindex("abc", "", 3), 3);
is(rindex("abc", "", 4), 3);

$a = "foo \x{1234}bar";

is(index($a, "\x{1234}"), 4);
is(index($a, "bar",    ), 5);

is(rindex($a, "\x{1234}"), 4);
is(rindex($a, "foo",    ), 0);

{
    my $needle = "\x{1230}\x{1270}";
    my @needles = split ( //, $needle );
    my $haystack = "\x{1228}\x{1228}\x{1230}\x{1270}";
    foreach ( @needles ) {
	my $a = index ( "\x{1228}\x{1228}\x{1230}\x{1270}", $_ );
	my $b = index ( $haystack, $_ );
	is($a, $b, q{[perl #22375] 'split'/'index' problem for utf8});
    }
    $needle = "\x{1270}\x{1230}"; # Transpose them.
    @needles = split ( //, $needle );
    foreach ( @needles ) {
	my $a = index ( "\x{1228}\x{1228}\x{1230}\x{1270}", $_ );
	my $b = index ( $haystack, $_ );
	is($a, $b, q{[perl #22375] 'split'/'index' problem for utf8});
    }
}

{
    my $search;
    my $text;
    if (ord('A') == 193) {
	$search = "foo \x71 bar";
	$text = "a\xb1\xb1a $search    $search quux";
    } else {
	$search = "foo \xc9 bar";
	$text = "a\xa3\xa3a $search    $search quux";
    }

    my $text_utf8 = $text;
    utf8::upgrade($text_utf8);
    my $search_utf8 = $search;
    utf8::upgrade($search_utf8);

    is (index($text, $search), 5);
    is (rindex($text, $search), 18);
    is (index($text, $search_utf8), 5);
    is (rindex($text, $search_utf8), 18);
    is (index($text_utf8, $search), 5);
    is (rindex($text_utf8, $search), 18);
    is (index($text_utf8, $search_utf8), 5);
    is (rindex($text_utf8, $search_utf8), 18);

    my $text_octets = $text_utf8;
    utf8::encode ($text_octets);
    my $search_octets = $search_utf8;
    utf8::encode ($search_octets);

    is (index($text_octets, $search_octets), 7, "index octets, octets")
	or _diag ($text_octets, $search_octets);
    is (rindex($text_octets, $search_octets), 21, "rindex octets, octets");
    is (index($text_octets, $search_utf8), -1);
    is (rindex($text_octets, $search_utf8), -1);
    is (index($text_utf8, $search_octets), -1);
    is (rindex($text_utf8, $search_octets), -1);

    is (index($text_octets, $search), -1);
    is (rindex($text_octets, $search), -1);
    is (index($text, $search_octets), -1);
    is (rindex($text, $search_octets), -1);
}

foreach my $utf8 ('', ', utf-8') {
    foreach my $arraybase (0, 1, -1, -2) {
	my $expect_pos = 2 + $arraybase;

	my $prog = "\$[ = $arraybase; \$big = \"N\\xabN\\xab\"; ";
	$prog .= '$big .= chr 256; chop $big; ' if $utf8;
	$prog .= 'print rindex $big, "N", 2 + $[';

	fresh_perl_is($prog, $expect_pos, {}, "\$[ = $arraybase$utf8");
    }
}
