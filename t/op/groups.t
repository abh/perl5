#!./perl

$ENV{PATH} = '/usr/xpg4/bin:/bin:/usr/bin:/usr/ucb';

unless (($groups = `(id -Gn || groups) 2>/dev/null`) ne '') {
    print "1..0\n";
    exit 0;
}

print "1..2\n";

$pwgid = $( + 0;
($pwgnam) = getgrgid($pwgid);
@basegroup{$pwgid,$pwgnam} = (1,1);

$seen{$pwgid}++;

for (split(' ', $()) {
    next if $seen{$_}++;
    ($group) = getgrgid($_);
    if (defined $group) {
	push(@gr, $group);
    }
    else {
	push(@gr, $_);
    }
} 

if ($^O eq "uwin") { # Or anybody else who can have spaces in group names.
	$gr1 = join(' ', grep(!$did{$_}++, sort split(' ', join(' ', @gr))));
} else {
	$gr1 = join(' ', sort @gr);
}

$gr2 = join(' ', grep(!$basegroup{$_}++, sort split(' ',$groups)));

if ($gr1 eq $gr2) {
    print "ok 1\n";
}
else {
    print "#gr1 is <$gr1>\n";
    print "#gr2 is <$gr2>\n";
    print "not ok 1\n";
}

# multiple 0's indicate GROUPSTYPE is currently long but should be short

if ($pwgid == 0 || $seen{0} < 2) {
    print "ok 2\n";
}
else {
    print "not ok 2 (groupstype should be type short, not long)\n";
}
