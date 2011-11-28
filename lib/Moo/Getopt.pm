package Moo::Getopt;

# ABSTRACT: add easily getopt to Moo module.

=head1 Moo::Getopt

	Add easily getopt to Moo module. 
	I use L<Getopt::Long::Descriptive> and the sub getopt is the params for the module.
	Look at L<Getopt::Long::Descriptive> help for options.

=cut

=head1 SYNOPSIS

	{
		package TestModule;
		use strict;
		use warnings;
		use Moo;
		with 'Moo::Getopt';
		
		has 'verbose' => (is => 'ro');
		has 'test' => (is => 'ro');
		
		sub getopt {
			(
			'USAGE: %c %o',
			['verbose', 'add more verbose'],
			['test=s','test string',{required => 1}],
			)
		}
		
		1;
	}
	
	my $t = TestModule->new_with_options();
	print "Test: ",$t->test,"\n";
	
	my $t1 = TestModule->new_with_options(test=>'override');
	print "Test: ",$t->test,"\n";
	
=cut

use strict;
use warnings;
use Moo::Role;
use Getopt::Long::Descriptive;
use Modern::Perl;

# VERSION

requires 'getopt';

=head2 new_with_options

	Parse command line with getopt and return a new object.
	You can override command line by passing params :
	
	%params:
	
		ex: $t->new_with_options(test => 'replaced');
=cut

sub new_with_options {
	my ($class, %params) = @_;

	#run getopt
	my @getopt = $class->getopt;

    #extract required
    my @required;
    foreach my $r(@getopt[1..$#getopt]) {
        my ($pf,$d,$o) = @$r;
		my ($p) = split(/=/,$pf);

        defined $o
            and push @required, $p
            and delete $o->{required};
    }

	my ($opt, $usage) = describe_options(@getopt,['help',"print usage message and exit"]);

	print($usage->text), exit if $opt->help;

	#replace params if not exist by command line one
	foreach my $r (@getopt[1..$#getopt]) {
		my ($pf) = @$r;
		my ($p) = split(/=/,$pf);
		$params{$p} //= $opt->$p;
	}

    my $p_ok=0;
    foreach my $p (@required) {
        unless (defined $params{$p}) {
            print "$p is required\n"
                and $p_ok++;
        }
    }

    print($usage->text), exit if $p_ok;
	
	return $class->new(%params);
}

1;

__END__

=head1 BUGS

Any bugs or evolution can be submit here :

L<Github|https://github.com/geistteufel/Moo-Getopt>
