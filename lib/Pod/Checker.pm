#############################################################################
# Pod/Checker.pm -- check pod documents for syntax errors
#
# Copyright (C) 1994-1999 by Bradford Appleton. All rights reserved.
# This file is part of "PodParser". PodParser is free software;
# you can redistribute it and/or modify it under the same terms
# as Perl itself.
#############################################################################

package Pod::Checker;

use vars qw($VERSION);
$VERSION = 1.097;  ## Current version of this package
require  5.004;    ## requires this Perl version or later

use Pod::ParseUtils; ## for hyperlinks and lists

=head1 NAME

Pod::Checker, podchecker() - check pod documents for syntax errors

=head1 SYNOPSIS

  use Pod::Checker;

  $syntax_okay = podchecker($filepath, $outputpath, %options);

  my $checker = new Pod::Checker %options;

=head1 OPTIONS/ARGUMENTS

C<$filepath> is the input POD to read and C<$outputpath> is
where to write POD syntax error messages. Either argument may be a scalar
indicating a file-path, or else a reference to an open filehandle.
If unspecified, the input-file it defaults to C<\*STDIN>, and
the output-file defaults to C<\*STDERR>.

=head2 podchecker()

This function can take a hash of options:

=over 4

=item B<-warnings> =E<gt> I<val>

Turn warnings on/off. See L<"Warnings">.

=back

=head1 DESCRIPTION

B<podchecker> will perform syntax checking of Perl5 POD format documentation.

I<NOTE THAT THIS MODULE IS CURRENTLY IN THE BETA STAGE!>

It is hoped that curious/ambitious user will help flesh out and add the
additional features they wish to see in B<Pod::Checker> and B<podchecker>
and verify that the checks are consistent with L<perlpod>.

The following checks are preformed:

=over 4

=item *

Unknown '=xxxx' commands, unknown 'X<...>' interior-sequences,
and unterminated interior sequences.

=item *

Check for proper balancing of C<=begin> and C<=end>. The contents of such
a block are generally ignored, i.e. no syntax checks are performed.

=item *

Check for proper nesting and balancing of C<=over>, C<=item> and C<=back>.

=item *

Check for same nested interior-sequences (e.g. 
C<LE<lt>...LE<lt>...E<gt>...E<gt>>).

=item *

Check for malformed or nonexisting entities C<EE<lt>...E<gt>>.

=item *

Check for correct syntax of hyperlinks C<LE<lt>...E<gt>>. See L<perlpod>
for details.

=item *

Check for unresolved document-internal links. This check may also reveal
misspelled links that seem to be internal links but should be links
to something else.

=back

=head2 Additional Features

While checking, this module collects document properties, e.g. the nodes
for hyperlinks (C<=headX>, C<=item>). POD translators can use this feature
to syntax-check and get the nodes in a first pass before actually starting
to convert. This is expensive in terms of execution time, but allows for
very robust conversions.

=head1 DIAGNOSTICS

=head2 Errors

=over 4

=item * empty =headn

A heading (C<=head1> or C<=head2>) without any text? That ain't no
heading!

=item * =over on line I<N> without closing =back

The C<=over> command does not have a corresponding C<=back> before the
next heading (C<=head1> or C<=head2>) or the end of the file.

=item * =item without previous =over

=item * =back without previous =over

An C<=item> or C<=back> command has been found outside a
C<=over>/C<=back> block.

=item * No argument for =begin

A C<=begin> command was found that is not followed by the formatter
specification.

=item * =end without =begin

A standalone C<=end> command was found.

=item * Nested =begin's

There were at least two consecutive C<=begin> commands without
the corresponding C<=end>. Only one C<=begin> may be active at
a time.

=item * =for without formatter specification

There is no specification of the formatter after the C<=for> command.

=item * unresolved internal link I<NAME>

The given link to I<NAME> does not have a matching node in the current
POD. This also happend when a single word node name is not enclosed in
C<"">.

=item * Unknown command "I<CMD>"

An invalid POD command has been found. Valid are C<=head1>, C<=head2>,
C<=over>, C<=item>, C<=back>, C<=begin>, C<=end>, C<=for>, C<=pod>,
C<=cut>

=item * Unknown interior-sequence "I<SEQ>"

An invalid markup command has been encountered. Valid are:
C<BE<lt>E<gt>>, C<CE<lt>E<gt>>, C<EE<lt>E<gt>>, C<FE<lt>E<gt>>, 
C<IE<lt>E<gt>>, C<LE<lt>E<gt>>, C<SE<lt>E<gt>>, C<XE<lt>E<gt>>, 
C<ZE<lt>E<gt>>

=item * nested commands I<CMD>E<lt>...I<CMD>E<lt>...E<gt>...E<gt>

Two nested identical markup commands have been found. Generally this
does not make sense.

=item * garbled entity I<STRING>

The I<STRING> found cannot be interpreted as a character entity.

=item * Entity number out of range

An entity specified by number (dec, hex, oct) is out of range (1-255).

=item * malformed link LE<lt>E<gt>

The link found cannot be parsed because it does not conform to the
syntax described in L<perlpod>.

=item * nonempty ZE<lt>E<gt>

The C<ZE<lt>E<gt>> sequence is supposed to be empty.

=item * Spurious text after =pod / =cut

The commands C<=pod> and C<=cut> do not take any arguments.

=item * Spurious character(s) after =back

The C<=back> command does not take any arguments.

=back

=head2 Warnings

These may not necessarily cause trouble, but indicate mediocre style.

=over 4

=item * multiple occurence of link target I<name>

The POD file has some C<=item> and/or C<=head> commands that have
the same text. Potential hyperlinks to such a text cannot be unique then.

=item * line containing nothing but whitespace in paragraph

There is some whitespace on a seemingly empty line. POD is very sensitive
to such things, so this is flagged. B<vi> users switch on the B<list>
option to avoid this problem.

=item * file does not start with =head

The file starts with a different POD directive than head.
This is most probably something you do not want.

=item * No numeric argument for =over

The C<=over> command is supposed to have a numeric argument (the
indentation).

=item * previous =item has no contents

There is a list C<=item> right above the flagged line that has no
text contents. You probably want to delete empty items.

=item * preceding non-item paragraph(s)

A list introduced by C<=over> starts with a text or verbatim paragraph,
but continues with C<=item>s. Move the non-item paragraph out of the
C<=over>/C<=back> block.

=item * =item type mismatch (I<one> vs. I<two>)

A list started with e.g. a bulletted C<=item> and continued with a
numbered one. This is obviously inconsistent. For most translators the
type of the I<first> C<=item> determines the type of the list.

=item * I<N> unescaped C<E<lt>E<gt>> in paragraph

Angle brackets not written as C<E<lt>ltE<gt>> and C<E<lt>gtE<gt>>
can potentially cause errors as they could be misinterpreted as
markup commands.

=item * Unknown entity

A character entity was found that does not belong to the standard
ISO set or the POD specials C<verbar> and C<sol>.

=item * No items in =over

The list opened with C<=over> does not contain any items.

=item * No argument for =item

C<=item> without any parameters is deprecated. It should either be followed
by C<*> to indicate an unordered list, by a number (optionally followed
by a dot) to indicate an ordered (numbered) list or simple text for a
definition list.

=item * empty section in previous paragraph

The previous section (introduced by a C<=head> command) does not contain
any text. This usually indicates that something is missing. Note: A 
C<=head1> followed immediately by C<=head2> does not trigger this warning.

=item * Verbatim paragraph in NAME section

The NAME section (C<=head1 NAME>) should consist of a single paragraph
with the script/module name, followed by a dash `-' and a very short
description of what the thing is good for.

=item * Hyperlinks

There are some warnings wrt. hyperlinks:
Leading/trailing whitespace, newlines in hyperlinks,
brackets C<()>.

=back

=head1 RETURN VALUE

B<podchecker> returns the number of POD syntax errors found or -1 if
there were no POD commands at all found in the file.

=head1 EXAMPLES

I<[T.B.D.]>

=head1 AUTHOR

Brad Appleton E<lt>bradapp@enteract.comE<gt> (initial version),
Marek Rouchal E<lt>marek@saftsack.fs.uni-bayreuth.deE<gt>

Based on code for B<Pod::Text::pod2text()> written by
Tom Christiansen E<lt>tchrist@mox.perl.comE<gt>

=cut

#############################################################################

use strict;
#use diagnostics;
use Carp;
use Exporter;
use Pod::Parser;

use vars qw(@ISA @EXPORT);
@ISA = qw(Pod::Parser);
@EXPORT = qw(&podchecker);

use vars qw(%VALID_COMMANDS %VALID_SEQUENCES);

my %VALID_COMMANDS = (
    'pod'    =>  1,
    'cut'    =>  1,
    'head1'  =>  1,
    'head2'  =>  1,
    'over'   =>  1,
    'back'   =>  1,
    'item'   =>  1,
    'for'    =>  1,
    'begin'  =>  1,
    'end'    =>  1,
);

my %VALID_SEQUENCES = (
    'I'  =>  1,
    'B'  =>  1,
    'S'  =>  1,
    'C'  =>  1,
    'L'  =>  1,
    'F'  =>  1,
    'X'  =>  1,
    'Z'  =>  1,
    'E'  =>  1,
);

# stolen from HTML::Entities
my %ENTITIES = (
 # Some normal chars that have special meaning in SGML context
 amp    => '&',  # ampersand 
'gt'    => '>',  # greater than
'lt'    => '<',  # less than
 quot   => '"',  # double quote

 # PUBLIC ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML
 AElig	=> '�',  # capital AE diphthong (ligature)
 Aacute	=> '�',  # capital A, acute accent
 Acirc	=> '�',  # capital A, circumflex accent
 Agrave	=> '�',  # capital A, grave accent
 Aring	=> '�',  # capital A, ring
 Atilde	=> '�',  # capital A, tilde
 Auml	=> '�',  # capital A, dieresis or umlaut mark
 Ccedil	=> '�',  # capital C, cedilla
 ETH	=> '�',  # capital Eth, Icelandic
 Eacute	=> '�',  # capital E, acute accent
 Ecirc	=> '�',  # capital E, circumflex accent
 Egrave	=> '�',  # capital E, grave accent
 Euml	=> '�',  # capital E, dieresis or umlaut mark
 Iacute	=> '�',  # capital I, acute accent
 Icirc	=> '�',  # capital I, circumflex accent
 Igrave	=> '�',  # capital I, grave accent
 Iuml	=> '�',  # capital I, dieresis or umlaut mark
 Ntilde	=> '�',  # capital N, tilde
 Oacute	=> '�',  # capital O, acute accent
 Ocirc	=> '�',  # capital O, circumflex accent
 Ograve	=> '�',  # capital O, grave accent
 Oslash	=> '�',  # capital O, slash
 Otilde	=> '�',  # capital O, tilde
 Ouml	=> '�',  # capital O, dieresis or umlaut mark
 THORN	=> '�',  # capital THORN, Icelandic
 Uacute	=> '�',  # capital U, acute accent
 Ucirc	=> '�',  # capital U, circumflex accent
 Ugrave	=> '�',  # capital U, grave accent
 Uuml	=> '�',  # capital U, dieresis or umlaut mark
 Yacute	=> '�',  # capital Y, acute accent
 aacute	=> '�',  # small a, acute accent
 acirc	=> '�',  # small a, circumflex accent
 aelig	=> '�',  # small ae diphthong (ligature)
 agrave	=> '�',  # small a, grave accent
 aring	=> '�',  # small a, ring
 atilde	=> '�',  # small a, tilde
 auml	=> '�',  # small a, dieresis or umlaut mark
 ccedil	=> '�',  # small c, cedilla
 eacute	=> '�',  # small e, acute accent
 ecirc	=> '�',  # small e, circumflex accent
 egrave	=> '�',  # small e, grave accent
 eth	=> '�',  # small eth, Icelandic
 euml	=> '�',  # small e, dieresis or umlaut mark
 iacute	=> '�',  # small i, acute accent
 icirc	=> '�',  # small i, circumflex accent
 igrave	=> '�',  # small i, grave accent
 iuml	=> '�',  # small i, dieresis or umlaut mark
 ntilde	=> '�',  # small n, tilde
 oacute	=> '�',  # small o, acute accent
 ocirc	=> '�',  # small o, circumflex accent
 ograve	=> '�',  # small o, grave accent
 oslash	=> '�',  # small o, slash
 otilde	=> '�',  # small o, tilde
 ouml	=> '�',  # small o, dieresis or umlaut mark
 szlig	=> '�',  # small sharp s, German (sz ligature)
 thorn	=> '�',  # small thorn, Icelandic
 uacute	=> '�',  # small u, acute accent
 ucirc	=> '�',  # small u, circumflex accent
 ugrave	=> '�',  # small u, grave accent
 uuml	=> '�',  # small u, dieresis or umlaut mark
 yacute	=> '�',  # small y, acute accent
 yuml	=> '�',  # small y, dieresis or umlaut mark

 # Some extra Latin 1 chars that are listed in the HTML3.2 draft (21-May-96)
 copy   => '�',  # copyright sign
 reg    => '�',  # registered sign
 nbsp   => "\240", # non breaking space

 # Additional ISO-8859/1 entities listed in rfc1866 (section 14)
 iexcl  => '�',
 cent   => '�',
 pound  => '�',
 curren => '�',
 yen    => '�',
 brvbar => '�',
 sect   => '�',
 uml    => '�',
 ordf   => '�',
 laquo  => '�',
'not'   => '�',    # not is a keyword in perl
 shy    => '�',
 macr   => '�',
 deg    => '�',
 plusmn => '�',
 sup1   => '�',
 sup2   => '�',
 sup3   => '�',
 acute  => '�',
 micro  => '�',
 para   => '�',
 middot => '�',
 cedil  => '�',
 ordm   => '�',
 raquo  => '�',
 frac14 => '�',
 frac12 => '�',
 frac34 => '�',
 iquest => '�',
'times' => '�',    # times is a keyword in perl
 divide => '�',

# some POD special entities
 verbar => '|',
 sol => '/'
);

##---------------------------------------------------------------------------

##---------------------------------
## Function definitions begin here
##---------------------------------

sub podchecker( $ ; $ % ) {
    my ($infile, $outfile, %options) = @_;
    local $_;

    ## Set defaults
    $infile  ||= \*STDIN;
    $outfile ||= \*STDERR;

    ## Now create a pod checker
    my $checker = new Pod::Checker(%options);
    $checker->parseopts(-process_cut_cmd => 1);

    ## Now check the pod document for errors
    $checker->parse_from_file($infile, $outfile);
    
    ## Return the number of errors found
    return $checker->num_errors();
}

##---------------------------------------------------------------------------

##-------------------------------
## Method definitions begin here
##-------------------------------

## sub new {
##     my $this = shift;
##     my $class = ref($this) || $this;
##     my %params = @_;
##     my $self = {%params};
##     bless $self, $class;
##     $self->initialize();
##     return $self;
## }

sub initialize {
    my $self = shift;
    ## Initialize number of errors, and setup an error function to
    ## increment this number and then print to the designated output.
    $self->{_NUM_ERRORS} = 0;
    $self->errorsub('poderror'); # set the error handling subroutine
    $self->{_commands} = 0; # total number of POD commands encountered
    $self->{_list_stack} = []; # stack for nested lists
    $self->{_have_begin} = ''; # stores =begin
    $self->{_links} = []; # stack for internal hyperlinks
    $self->{_nodes} = []; # stack for =head/=item nodes
    # print warnings?
    $self->{-warnings} = 1 unless(defined $self->{-warnings});
    $self->{_current_head1} = ''; # the current =head1 block
}

# Invoked as $self->poderror( @args ), or $self->poderror( {%opts}, @args )
sub poderror {
    my $self = shift;
    my %opts = (ref $_[0]) ? %{shift()} : ();

    ## Retrieve options
    chomp( my $msg  = ($opts{-msg} || "")."@_" );
    my $line = (exists $opts{-line}) ? " at line $opts{-line}" : "";
    my $file = (exists $opts{-file}) ? " in file $opts{-file}" : "";
    unless (exists $opts{-severity}) {
       ## See if can find severity in message prefix
       $opts{-severity} = $1  if ( $msg =~ s/^\**\s*([A-Z]{3,}):\s+// );
    }
    my $severity = (exists $opts{-severity}) ? "*** $opts{-severity}: " : "";

    ## Increment error count and print message "
    ++($self->{_NUM_ERRORS}) 
        if(!%opts || ($opts{-severity} && $opts{-severity} eq 'ERROR'));
    my $out_fh = $self->output_handle();
    print $out_fh ($severity, $msg, $line, $file, "\n")
      if($self->{-warnings} || !%opts || $opts{-severity} ne 'WARNING');
}

# set/retrieve the number of errors found
sub num_errors {
   return (@_ > 1) ? ($_[0]->{_NUM_ERRORS} = $_[1]) : $_[0]->{_NUM_ERRORS};
}

# set and/or retrieve canonical name of POD
sub name {
    return (@_ > 1 && $_[1]) ?
        ($_[0]->{-name} = $_[1]) : $_[0]->{-name};  
}

# set/return nodes of the current POD
sub node {
    my ($self,$text) = @_;
    if(defined $text) {
        $text =~ s/\s+$//s; # strip trailing whitespace
        $text =~ s/\s+/ /gs; # collapse whitespace
        # add node, order important!
        push(@{$self->{_nodes}}, $text);
        # keep also a uniqueness counter
        $self->{_unique_nodes}->{$text}++;
        return $text;
    }
    @{$self->{_nodes}};
}

# set/return hyperlinks of the current POD
sub hyperlink {
    my $self = shift;
    if($_[0]) {
        push(@{$self->{_links}}, $_[0]);
        return $_[0];
    }
    @{$self->{_links}};
}

## overrides for Pod::Parser

sub end_pod {
    ## Do some final checks and
    ## print the number of errors found
    my $self   = shift;
    my $infile = $self->input_file();
    my $out_fh = $self->output_handle();

    if(@{$self->{_list_stack}}) {
        # _TODO_ display, but don't count them for now
        my $list;
        while(($list = $self->_close_list('EOF',$infile)) &&
          $list->indent() ne 'auto') {
            $self->poderror({ -line => 'EOF', -file => $infile,
                -severity => 'ERROR', -msg => "=over on line " .
                $list->start() . " without closing =back" }); #"
        }
    }

    # check validity of document internal hyperlinks
    # first build the node names from the paragraph text
    my %nodes;
    foreach($self->node()) {
        $nodes{$_} = 1;
        if(/^(\S+)\s+/) {
            # we have more than one word. Use the first as a node, too.
            # This is used heavily in perlfunc.pod
            $nodes{$1} ||= 2; # derived node
        }
    }
    foreach($self->hyperlink()) {
        my $line = '';
        s/^(\d+):// && ($line = $1);
        if($_ && !$nodes{$_}) {
            $self->poderror({ -line => $line, -file => $infile,
                -severity => 'ERROR',
                -msg => "unresolved internal link '$_'"});
        }
    }
    foreach(grep($self->{_unique_nodes}->{$_} > 1,
      keys %{$self->{_unique_nodes}})) {
        $self->poderror({ -line => '-', -file => $infile,
            -severity => 'WARNING',
            -msg => "multiple occurence of link target '$_'"});
    }

    ## Print the number of errors found
    my $num_errors = $self->num_errors();
    if ($num_errors > 0) {
        printf $out_fh ("$infile has $num_errors pod syntax %s.\n",
                      ($num_errors == 1) ? "error" : "errors");
    }
    elsif($self->{_commands} == 0) {
        print $out_fh "$infile does not contain any pod commands.\n";
        $self->num_errors(-1);
    }
    else {
        print $out_fh "$infile pod syntax OK.\n";
    }
}

# check a POD command directive
sub command { 
    my ($self, $cmd, $paragraph, $line_num, $pod_para) = @_;
    my ($file, $line) = $pod_para->file_line;
    ## Check the command syntax
    my $arg; # this will hold the command argument
    if (! $VALID_COMMANDS{$cmd}) {
       $self->poderror({ -line => $line, -file => $file, -severity => 'ERROR',
                         -msg => "Unknown command '$cmd'" });
    }
    else {
        # found a valid command
        if(!$self->{_commands}++ && $cmd !~ /^head/) {
            $self->poderror({ -line => $line, -file => $file,
                 -severity => 'WARNING', 
                 -msg => "file does not start with =head" });
        }
        ## check syntax of particular command
        if($cmd eq 'over') {
            # check for argument
            $arg = $self->interpolate_and_check($paragraph, $line,$file);
            my $indent = 4; # default
            if($arg && $arg =~ /^\s*(\d+)\s*$/) {
                $indent = $1;
            } else {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'WARNING', 
                     -msg => "No numeric argument for =over"});
            }
            # start a new list
            $self->_open_list($indent,$line,$file);
        }
        elsif($cmd eq 'item') {
            # are we in a list?
            unless(@{$self->{_list_stack}}) {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'ERROR', 
                     -msg => "=item without previous =over" });
                # auto-open in case we encounter many more
                $self->_open_list('auto',$line,$file);
            }
            my $list = $self->{_list_stack}->[0];
            # check whether the previous item had some contents
            if(defined $self->{_list_item_contents} &&
              $self->{_list_item_contents} == 0) {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'WARNING', 
                     -msg => "previous =item has no contents" });
            }
            if($list->{_has_par}) {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'WARNING', 
                     -msg => "preceding non-item paragraph(s)" });
                delete $list->{_has_par};
            }
            # check for argument
            $arg = $self->interpolate_and_check($paragraph, $line, $file);
            if($arg && $arg =~ /(\S+)/) {
                $arg =~ s/[\s\n]+$//;
                my $type;
                if($arg =~ /^[*]\s*(\S*.*)/) {
                  $type = 'bullet';
                  $self->{_list_item_contents} = $1 ? 1 : 0;
                  $arg = $1;
                }
                elsif($arg =~ /^\d+\.?\s*(\S*)/) {
                  $type = 'number';
                  $self->{_list_item_contents} = $1 ? 1 : 0;
                  $arg = $1;
                }
                else {
                  $type = 'definition';
                  $self->{_list_item_contents} = 1;
                }
                my $first = $list->type();
                if($first && $first ne $type) {
                    $self->poderror({ -line => $line, -file => $file,
                       -severity => 'WARNING', 
                       -msg => "=item type mismatch ('$first' vs. '$type')"});
                }
                else { # first item
                    $list->type($type);
                }
            }
            else {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'WARNING', 
                     -msg => "No argument for =item" });
		$arg = ' '; # empty
                $self->{_list_item_contents} = 0;
            }
            # add this item
            $list->item($arg);
            # remember this node
            $self->node($arg);
        }
        elsif($cmd eq 'back') {
            # check if we have an open list
            unless(@{$self->{_list_stack}}) {
                $self->poderror({ -line => $line, -file => $file,
                         -severity => 'ERROR', 
                         -msg => "=back without previous =over" });
            }
            else {
                # check for spurious characters
                $arg = $self->interpolate_and_check($paragraph, $line,$file);
                if($arg && $arg =~ /\S/) {
                    $self->poderror({ -line => $line, -file => $file,
                         -severity => 'ERROR', 
                         -msg => "Spurious character(s) after =back" });
                }
                # close list
                my $list = $self->_close_list($line,$file);
                # check for empty lists
                if(!$list->item() && $self->{-warnings}) {
                    $self->poderror({ -line => $line, -file => $file,
                         -severity => 'WARNING', 
                         -msg => "No items in =over (at line " .
                         $list->start() . ") / =back list"}); #"
                }
            }
        }
        elsif($cmd =~ /^head(\d+)/) {
            if(defined $self->{_commands_in_head} &&
              $self->{_commands_in_head} == 0 &&
              defined $self->{_last_head} &&
              $self->{_last_head} >= $1) {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'WARNING', 
                     -msg => "empty section in previous paragraph"});
            }
            $self->{_commands_in_head} = -1;
            $self->{_last_head} = $1;
            # check if there is an open list
            if(@{$self->{_list_stack}}) {
                my $list;
                while(($list = $self->_close_list($line,$file)) &&
                  $list->indent() ne 'auto') {
                    $self->poderror({ -line => $line, -file => $file,
                         -severity => 'ERROR', 
                         -msg => "=over on line ". $list->start() .
                         " without closing =back (at $cmd)" });
                }
            }
            # remember this node
            $arg = $self->interpolate_and_check($paragraph, $line,$file);
            $arg =~ s/[\s\n]+$//s;
            $self->node($arg);
            unless(length($arg)) {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'ERROR', 
                     -msg => "empty =$cmd"});
            }
            if($cmd eq 'head1') {
                $self->{_current_head1} = $arg;
            } else {
                $self->{_current_head1} = '';
            }
        }
        elsif($cmd eq 'begin') {
            if($self->{_have_begin}) {
                # already have a begin
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'ERROR', 
                     -msg => "Nested =begin's (first at line " .
                     $self->{_have_begin} . ")"});
            }
            else {
                # check for argument
                $arg = $self->interpolate_and_check($paragraph, $line,$file);
                unless($arg && $arg =~ /(\S+)/) {
                    $self->poderror({ -line => $line, -file => $file,
                         -severity => 'ERROR', 
                         -msg => "No argument for =begin"});
                }
                # remember the =begin
                $self->{_have_begin} = "$line:$1";
            }
        }
        elsif($cmd eq 'end') {
            if($self->{_have_begin}) {
                # close the existing =begin
                $self->{_have_begin} = '';
                # check for spurious characters
                $arg = $self->interpolate_and_check($paragraph, $line,$file);
                # the closing argument is optional
                #if($arg && $arg =~ /\S/) {
                #    $self->poderror({ -line => $line, -file => $file,
                #         -severity => 'WARNING', 
                #         -msg => "Spurious character(s) after =end" });
                #}
            }
            else {
                # don't have a matching =begin
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'ERROR', 
                     -msg => "=end without =begin" });
            }
        }
        elsif($cmd eq 'for') {
            unless($paragraph =~ /\s*(\S+)\s*/) {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'ERROR', 
                     -msg => "=for without formatter specification" });
            }
            $arg = ''; # do not expand paragraph below
        }
        elsif($cmd =~ /^(pod|cut)$/) {
            # check for argument
            $arg = $self->interpolate_and_check($paragraph, $line,$file);
            if($arg && $arg =~ /(\S+)/) {
                $self->poderror({ -line => $line, -file => $file,
                      -severity => 'ERROR', 
                      -msg => "Spurious text after =$cmd"});
            }
        }
    $self->{_commands_in_head}++;
    ## Check the interior sequences in the command-text
    $self->interpolate_and_check($paragraph, $line,$file)
        unless(defined $arg);
    }
}

sub _open_list
{
    my ($self,$indent,$line,$file) = @_;
    my $list = Pod::List->new(
           -indent => $indent,
           -start => $line,
           -file => $file);
    unshift(@{$self->{_list_stack}}, $list);
    undef $self->{_list_item_contents};
    $list;
}

sub _close_list
{
    my ($self,$line,$file) = @_;
    my $list = shift(@{$self->{_list_stack}});
    if(defined $self->{_list_item_contents} &&
      $self->{_list_item_contents} == 0) {
        $self->poderror({ -line => $line, -file => $file,
            -severity => 'WARNING', 
            -msg => "previous =item has no contents" });
    }
    undef $self->{_list_item_contents};
    $list;
}

# process a block of some text
sub interpolate_and_check {
    my ($self, $paragraph, $line, $file) = @_;
    ## Check the interior sequences in the command-text
    # and return the text
    $self->_check_ptree(
        $self->parse_text($paragraph,$line), $line, $file, '');
}

sub _check_ptree {
    my ($self,$ptree,$line,$file,$nestlist) = @_;
    local($_);
    my $text = '';
    # process each node in the parse tree
    foreach(@$ptree) {
        # regular text chunk
        unless(ref) {
            my $count;
            # count the unescaped angle brackets
            my $i = $_;
            if($count = $i =~ tr/<>/<>/) {
                $self->poderror({ -line => $line, -file => $file,
                     -severity => 'WARNING', 
                     -msg => "$count unescaped <> in paragraph" })
                if($self->{-warnings});
            }
            $text .= $i;
            next;
        }
        # have an interior sequence
        my $cmd = $_->cmd_name();
        my $contents = $_->parse_tree();
        ($file,$line) = $_->file_line();
        # check for valid tag
        if (! $VALID_SEQUENCES{$cmd}) {
            $self->poderror({ -line => $line, -file => $file,
                 -severity => 'ERROR', 
                 -msg => qq(Unknown interior-sequence '$cmd')});
            # expand it anyway
            $text .= $self->_check_ptree($contents, $line, $file, "$nestlist$cmd");
            next;
        }
        if($nestlist =~ /$cmd/) {
            $self->poderror({ -line => $line, -file => $file,
                 -severity => 'ERROR', 
                 -msg => "nested commands $cmd<...$cmd<...>...>"});
            # _TODO_ should we add the contents anyway?
            # expand it anyway, see below
        }
        if($cmd eq 'E') {
            # preserve entities
            if(@$contents > 1 || ref $$contents[0] || $$contents[0] !~ /^\w+$/) {
                $self->poderror({ -line => $line, -file => $file,
                    -severity => 'ERROR', 
                    -msg => "garbled entity " . $_->raw_text()});
                next;
            }
            my $ent = $$contents[0];
            my $val;
            if($ent =~ /^0x[0-9a-f]+$/i) {
                # hexadec entity
                $val = hex($ent);
            }
            elsif($ent =~ /^0\d+$/) {
                # octal
                $val = oct($ent);
            }
            elsif($ent =~ /^\d+$/) {
                # numeric entity
                $val = $ent;
            }
            if(defined $val) {
                if($val>0 && $val<256) {
                    $text .= chr($val);
                }
                else {
                    $self->poderror({ -line => $line, -file => $file,
                        -severity => 'ERROR', 
                        -msg => "Entity number out of range " . $_->raw_text()});
                }
            }
            elsif($ENTITIES{$ent}) {
                # known ISO entity
                $text .= $ENTITIES{$ent};
            }
            else {
                $self->poderror({ -line => $line, -file => $file,
                    -severity => 'WARNING', 
                    -msg => "Unknown entity " . $_->raw_text()});
                $text .= "E<$ent>";
            }
        }
        elsif($cmd eq 'L') {
            # try to parse the hyperlink
            my $link = Pod::Hyperlink->new($contents->raw_text());
            unless(defined $link) {
                $self->poderror({ -line => $line, -file => $file,
                    -severity => 'ERROR', 
                    -msg => "malformed link " . $_->raw_text() ." : $@"});
                next;
            }
            $link->line($line); # remember line
            if($self->{-warnings}) {
                foreach my $w ($link->warning()) {
                    $self->poderror({ -line => $line, -file => $file,
                        -severity => 'WARNING', 
                        -msg => $w });
                }
            }
            # check the link text
            $text .= $self->_check_ptree($self->parse_text($link->text(),
                $line), $line, $file, "$nestlist$cmd");
            my $node = '';
            # remember internal link
            # _TODO_ what if there is a link to the page itself by the name,
            # e.g. in Tk::Pod : L<Tk::Pod/"DESCRIPTION">
            if($link->node() && !$link->page() && $link->type() ne 'hyperlink') {
                $node = $self->_check_ptree($self->parse_text($link->node(),
                    $line), $line, $file, "$nestlist$cmd");
                $self->hyperlink("$line:$node") if($node);
            }
        }
        elsif($cmd =~ /[BCFIS]/) {
            # add the guts
            $text .= $self->_check_ptree($contents, $line, $file, "$nestlist$cmd");
        }
        elsif($cmd eq 'Z') {
            if(length($contents->raw_text())) {
                $self->poderror({ -line => $line, -file => $file,
                    -severity => 'ERROR', 
                    -msg => "Nonempty Z<>"});
            }
        }
        else { # X<>
            # check, but add nothing to $text
            $self->_check_ptree($contents, $line, $file, "$nestlist$cmd");
        }
    }
    $text;
}

# _TODO_ overloadable methods for BC..Z<...> expansion?

# process a block of verbatim text
sub verbatim { 
    ## Nothing particular to check
    my ($self, $paragraph, $line_num, $pod_para) = @_;

    $self->_preproc_par($paragraph);

    if($self->{_current_head1} eq 'NAME') {
        my ($file, $line) = $pod_para->file_line;
        $self->poderror({ -line => $line, -file => $file,
            -severity => 'WARNING',
            -msg => 'Verbatim paragraph in NAME section' });
    }
}

# process a block of regular text
sub textblock { 
    my ($self, $paragraph, $line_num, $pod_para) = @_;
    my ($file, $line) = $pod_para->file_line;

    $self->_preproc_par($paragraph);

    # skip this paragraph if in a =begin block
    unless($self->{_have_begin}) {
        my $block = $self->interpolate_and_check($paragraph, $line,$file);
        if($self->{_current_head1} eq 'NAME') {
            if($block =~ /^\s*(\S+?)\s*[,-]/) {
                # this is the canonical name
                $self->{-name} = $1 unless(defined $self->{-name});
            }
        }
    }
}

sub _preproc_par
{
    my $self = shift;
    $_[0] =~ s/[\s\n]+$//;
    if($_[0]) {
        $self->{_commands_in_head}++;
        $self->{_list_item_contents}++ if(defined $self->{_list_item_contents});
        if(@{$self->{_list_stack}} && !$self->{_list_stack}->[0]->item()) {
            $self->{_list_stack}->[0]->{_has_par} = 1;
        }
    }
}

1;

