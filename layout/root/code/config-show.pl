#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use JSON::PP;

# read in JSON config
my $filename = '/config.json';
my $json = JSON::PP->new->ascii->pretty->allow_nonref;
my $jsondata;
if(open(my $json_file, '<', $filename)) {
	local $/;
	$jsondata = <$json_file>;
	close($json_file);
}
chomp($jsondata);
my $mydata = $json->decode($jsondata);
print($jsondata."\n");

1;
