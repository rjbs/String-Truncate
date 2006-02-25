package String::Truncate;

use warnings;
use strict;

use base qw(Exporter);
our @EXPORT_OK = qw(elide trunc);

use Carp qw(croak);

=head1 NAME

String::Truncate - a module for when strings are too long to be displayed in...

=head1 VERSION

version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

This module handles the simple but common problem of long strings and finite
terminal width.  It can convert:

 "this is your brain" -> "this is your ..."
                      or "...is your brain"
                      or "this is... brain"
                      or "... is your b..."

It's simple:

 use String::Truncate qw(elide);

 my $brain = "this is your brain";

 elide($brain, 16); # first option
 elide($brain, 16, { truncate => 'left' });   # second option
 elide($brain, 16, { truncate => 'middle' }); # third option
 elide($brain, 16, { truncate => 'ends' });   # fourth option

 String::Trunc::trunc($brain, 16); # => "this is your bra"

=head1 FUNCTIONS

=head2 C< elide($string, $length, \%arg) >

This function returns the string, if it is less than or equal to C<$length>
characters long.  If it is longer, it truncates the string and marks the
elision.

Valid arguments are:

 elide  - elide at left, right, middle, or ends? (default: right)
 marker - how to mark the elision (default: ...)

=cut

my %elider_for = (
  right  => \&_elide_right,
  left   => \&_elide_left,
  middle => \&_elide_middle,
  ends   => \&_elide_ends,
);

sub _elide_right {
  &_assert_1ML;
  my ($string, $length, $marker) = @_;
  my $keep = $length - length($marker);
  return substr($string, 0, $keep) . $marker;
}

sub _elide_left {
  &_assert_1ML;
  my ($string, $length, $marker) = @_;
  my $keep = $length - length($marker);
  return $marker . substr($string, -$keep, $keep);
}

sub _elide_middle {
  &_assert_1ML;
  my ($string, $length, $marker) = @_;
  my $keep = $length - length($marker);
  my ($keep_left, $keep_right) = (int($keep / 2)) x 2;
  $keep_left +=1 if ($keep_left + $keep_right) < $keep;
  return substr($string, 0, $keep_left)
       . $marker
       . substr($string, -$keep_right, $keep_right);
}

sub _elide_ends {
  &_assert_2ML;
  my ($string, $length, $marker) = @_;
  my $keep = $length  -  2 * length($marker);
  my $midpoint = int(length($string) / 2);
  my $keep_left = $midpoint - int($keep / 2);
  return $marker
       . substr($string, $keep_left, $keep)
       . $marker;
}

sub _assert_1ML {
  my ($string, $length, $marker) = @_;
  croak "elision marker <$marker> is longer than allowed length $length!"
    if length($marker) > $length;
}

sub _assert_2ML {
  my ($string, $length, $marker) = @_;
  # this should only complain if needed: elide('foobar', 3, {marker=>'...'})
  # should be ok -- rjbs, 2006-02-24
  croak "two elision markers <$marker> are longer than allowed length $length!"
    if (length($marker) * 2) > $length;
}

sub elide {
  my ($string, $length, $arg) = @_;

  $arg ||= {};
  my $truncate = $arg->{truncate} || 'right';

  croak "invalid value for truncate argument: $truncate"
    unless my $elider = $elider_for{ $truncate };

  # hey, this might be really easy:
  return $string if length($string) <= $length;

  my $marker = defined $arg->{marker} ? $arg->{marker} : '...';
  
  return $elider->($string, $length, $marker);
}
  
=head2 C<< trunc($string, $length, \%arg) >>

This acts just like C<elide>, but assumes an empty marker, so it actually
truncates the string normally.

=cut

sub trunc {
  my ($string, $length, $arg) = @_;
  $arg ||= {};

  croak "marker may not be passed to trunc()" if exists $arg->{marker};
  $arg->{marker} = '';

  return elide($string, $length, $arg);
}

=head1 SEE ALSO

L<Text::Truncate> does a very similar thing, and lets you set the default
marker, rather than specify one every time if you don't want "..."

=head1 AUTHOR

Ricardo Signes, C<< <rjbs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-string-truncate@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=String-Truncate>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Ian Langworth gave me some good advice about naming things.  (Also some bad
jokes.  Nobody wants String::ETOOLONG, Ian.)

=head1 COPYRIGHT & LICENSE

Copyright 2005 Ricardo Signes, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of String::Truncate
