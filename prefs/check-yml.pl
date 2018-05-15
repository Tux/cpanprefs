#!/pro/bin/perl

use 5.14.1;
use warnings;

our $VERSION = "0.01 - 20180515";

use YAML;
use YAML::PP;
use YAML::XS;
use YAML::Syck;
use YAML::Tiny;
use Test::More;
use Test::YAML::Valid;

my %fail;
foreach my $yf (sort glob "*.yml") {

    yaml_file_ok ($yf, $yf);

    ok (my $yml = do { local (@ARGV, $/) = $yf; <> }, "Read $yf");
    unless ($yml) {
	note ("$yf is empty - Skipped");
	next;
	}

    for my $m (qw( YAML::Load YAML::XS::Load YAML::PP::Load YAML::Syck::Load )) {
	no strict "refs";
	eval { my $h = &$m ($yml) };
	is ($@ // "", "", $m);
	$@ and $fail{$yf}++;
	}

    eval { my $h = YAML::Tiny->read_string ($yml); };
    is ($@ // "", "", "YAML::Tiny");
    $@ and $fail{$yf}++;
    } # check_yaml

note ("Failed: @{[ sort keys %fail ]}") if keys %fail;
done_testing ();
