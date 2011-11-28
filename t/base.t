#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Modern::Perl;

{
	package t;
	use Moo;
    use strict;
    use warnings;
	
	has 'bool' => (
		is => 'rw',
	);
	
	has 'str' => (
		is => 'rw',
	);
	
	has 'array' => (
		is => 'rw',
		coerce => sub {
			my ($p) = @_;
			if(defined $p && ref $p ne 'ARRAY') {
				my @a = split(/,/,$p);
				$p = \@a;
			}
			$p;
		}
	);
	
	has 'z' => (
		is => 'rw',
	);

	sub getopt {
		(
			'USAGE: %c %o',
			[ 'bool', 'bool test', {required => 1}],
			[ 'str=s', 'str test'],
			[ 'array=s', 'array test'],
			[ 'z=s', 'array params test'],
		)
	}

	with 'Moo::Getopt';

}

@ARGV=('--bool','--str=test','--array=1,2,3');
my $test = t->new_with_options(z=>[qw/k g b/], str => 'tt');
is($test->bool, 1, 'Bool');
is($test->str, 'tt', 'Str');
isa_ok($test->array, 'ARRAY', 'array');
is_deeply($test->array, [1,2,3], 'array contain 1,2,3');
isa_ok($test->z, 'ARRAY','z');
is_deeply($test->z, [qw/k g b/], 'z contain k,g,b');

done_testing;
