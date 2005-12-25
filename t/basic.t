use strict;
use warnings;

use Test::More 'no_plan';

BEGIN { use_ok('String::Truncate', qw(elide trunc)); }

my $brain = "this is your brain";

is(
  elide($brain, 50),
  "this is your brain",
  "don't truncate short strings",
);

is(
  elide($brain, 16),
  "this is your ...",
  "right-side example",
);

is(
  elide($brain, 16, { truncate => 'left' }),
  "...is your brain",
  "left-side example",
);

is(
  elide($brain, 16, { truncate => 'middle' }),
  "this is... brain",
  "middle-side example",
);

eval { elide($brain, 2) };
like($@, qr/longer/, "can't truncate to less than marker");

eval { elide($brain, 20, { truncate => 'backside' }) };
like($@, qr/invalid/, "only left|right|middle are valid");

is(
  elide($brain, 10, { marker => ' &c.' }),
  "this i &c.",
  "custom marker",
);
