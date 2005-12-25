use strict;
use warnings;

use Test::More 'no_plan';

BEGIN { use_ok('String::Truncate', qw(elide trunc)); }

my $brain = "this is your brain";

is(
  elide($brain, 16, { truncate => 'ends' }),
  "... is your b...",
  "elide both ends",
);

eval { elide($brain, 5, { truncate => 'ends' }) };
like($@, qr/longer/, "marker can't exceed 1/2 length for end elision");
