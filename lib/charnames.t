#!./perl

my @WARN;

BEGIN {
    unless(grep /blib/, @INC) {
	chdir 't' if -d 't';
	@INC = '../lib';
    }
    $SIG{__WARN__} = sub { push @WARN, @_ };
}

$| = 1;

print "1..39\n";

use charnames ':full';

print "not " unless "Here\N{EXCLAMATION MARK}?" eq "Here!?";
print "ok 1\n";

{
  use bytes;			# TEST -utf8 can switch utf8 on

  print "# \$res=$res \$\@='$@'\nnot "
    if $res = eval <<'EOE'
use charnames ":full";
"Here: \N{CYRILLIC SMALL LETTER BE}!";
1
EOE
      or $@ !~ /above 0xFF/;
  print "ok 2\n";
  # print "# \$res=$res \$\@='$@'\n";

  print "# \$res=$res \$\@='$@'\nnot "
    if $res = eval <<'EOE'
use charnames 'cyrillic';
"Here: \N{Be}!";
1
EOE
      or $@ !~ /CYRILLIC CAPITAL LETTER BE.*above 0xFF/;
  print "ok 3\n";
}

# If octal representation of unicode char is \0xyzt, then the utf8 is \3xy\2zt
if (ord('A') == 65) { # as on ASCII or UTF-8 machines
    $encoded_be = "\320\261";
    $encoded_alpha = "\316\261";
    $encoded_bet = "\327\221";
    $encoded_deseng = "\360\220\221\215";
}
else { # EBCDIC where UTF-EBCDIC may be used (this may be 1047 specific since
       # UTF-EBCDIC is codepage specific)
    $encoded_be = "\270\102\130";
    $encoded_alpha = "\264\130";
    $encoded_bet = "\270\125\130";
    $encoded_deseng = "\336\102\103\124";
}

sub to_bytes {
    pack"a*", shift;
}

{
  use charnames ':full';

  print "not " unless to_bytes("\N{CYRILLIC SMALL LETTER BE}") eq $encoded_be;
  print "ok 4\n";

  use charnames qw(cyrillic greek :short);

  print "not " unless to_bytes("\N{be},\N{alpha},\N{hebrew:bet}")
    eq "$encoded_be,$encoded_alpha,$encoded_bet";
  print "ok 5\n";
}

{
    use charnames ':full';
    print "not " unless "\x{263a}" eq "\N{WHITE SMILING FACE}";
    print "ok 6\n";
    print "not " unless length("\x{263a}") == 1;
    print "ok 7\n";
    print "not " unless length("\N{WHITE SMILING FACE}") == 1;
    print "ok 8\n";
    print "not " unless sprintf("%vx", "\x{263a}") eq "263a";
    print "ok 9\n";
    print "not " unless sprintf("%vx", "\N{WHITE SMILING FACE}") eq "263a";
    print "ok 10\n";
    print "not " unless sprintf("%vx", "\xFF\N{WHITE SMILING FACE}") eq "ff.263a";
    print "ok 11\n";
    print "not " unless sprintf("%vx", "\x{ff}\N{WHITE SMILING FACE}") eq "ff.263a";
    print "ok 12\n";
}

{
   use charnames qw(:full);
   use utf8;
   
    my $x = "\x{221b}";
    my $named = "\N{CUBE ROOT}";

    print "not " unless ord($x) == ord($named);
    print "ok 13\n";
}

{
   use charnames qw(:full);
   use utf8;
   print "not " unless "\x{100}\N{CENT SIGN}" eq "\x{100}"."\N{CENT SIGN}";
   print "ok 14\n";
}

{
  use charnames ':full';

  print "not "
      unless to_bytes("\N{DESERET SMALL LETTER ENG}") eq $encoded_deseng;
  print "ok 15\n";
}

{
  # 20001114.001	

  no utf8; # naked Latin-1

  if (ord("�") == 0xc4) { # Try to do this only on Latin-1.
      use charnames ':full';
      my $text = "\N{LATIN CAPITAL LETTER A WITH DIAERESIS}";
      print "not " unless $text eq "\xc4" && ord($text) == 0xc4;
      print "ok 16\n";
  } else {
      print "ok 16 # Skip: not Latin-1\n";
  }
}

{
    print "not " unless charnames::viacode(0x1234) eq "ETHIOPIC SYLLABLE SEE";
    print "ok 17\n";

    # Unused Hebrew.
    print "not " unless charnames::viacode(0x0590) eq chr(0xFFFD);
    print "ok 18\n";
}

{
    print "not " unless
	sprintf "%04X\n", charnames::vianame("GOTHIC LETTER AHSA") eq "10330";
    print "ok 19\n";

    print "not " if
	defined charnames::vianame("NONE SUCH");
    print "ok 20\n";
}

{
    # check that caching at least hasn't broken anything

    print "not " unless charnames::viacode(0x1234) eq "ETHIOPIC SYLLABLE SEE";
    print "ok 21\n";

    print "not " unless
	sprintf "%04X\n", charnames::vianame("GOTHIC LETTER AHSA") eq "10330";
    print "ok 22\n";

}

print "not " unless "\N{CHARACTER TABULATION}" eq "\t";
print "ok 23\n";

print "not " unless "\N{ESCAPE}" eq "\e";
print "ok 24\n";

print "not " unless "\N{NULL}" eq "\c@";
print "ok 25\n";

print "not " unless "\N{LINE FEED (LF)}" eq "\n";
print "ok 26\n";

print "not " unless "\N{LINE FEED}" eq "\n";
print "ok 27\n";

print "not " unless "\N{LF}" eq "\n";
print "ok 28\n";

my $nel = ord("A") == 193 ? qr/^(?:\x15|\x25)$/ : qr/^\x85$/;

print "not " unless "\N{NEXT LINE (NEL)}" =~ $nel;
print "ok 29\n";

print "not " unless "\N{NEXT LINE}" =~ $nel;
print "ok 30\n";

print "not " unless "\N{NEL}" =~ $nel;
print "ok 31\n";

print "not " unless "\N{BYTE ORDER MARK}" eq chr(0xFEFF);
print "ok 32\n";

print "not " unless "\N{BOM}" eq chr(0xFEFF);
print "ok 33\n";

{
    use warnings 'deprecated';

    print "not " unless "\N{HORIZONTAL TABULATION}" eq "\t";
    print "ok 34\n";

    print "not " unless grep { /"HORIZONTAL TABULATION" is deprecated/ } @WARN;
    print "ok 35\n";

    no warnings 'deprecated';

    print "not " unless "\N{VERTICAL TABULATION}" eq "\013";
    print "ok 36\n";

    print "not " if grep { /"VERTICAL TABULATION" is deprecated/ } @WARN;
    print "ok 37\n";
}

print "not " unless charnames::viacode(0xFEFF) eq "ZERO WIDTH NO-BREAK SPACE";
print "ok 38\n";

{
    use warnings;
    print "not " unless ord("\N{BOM}") == 0xFEFF;
    print "ok 39\n";
}

