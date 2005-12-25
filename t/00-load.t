#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'String::Truncate' );
}

diag( "Testing String::Truncate $String::Truncate::VERSION, Perl $], $^X" );
