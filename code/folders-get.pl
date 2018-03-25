#!/usr/bin/perl
use strict;
use warnings;
use VMware::VIRuntime;
use VMware::VILib;
use Data::Dumper;
use JSON::PP;
use lib '/root/code/';
use xview;

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

# set sdk options and connect
print("Connecting to server [".$mydata->{server}."]\n");
Opts::set_option('server', $mydata->{server});
Opts::set_option('username', $mydata->{username});
Opts::set_option('password', $mydata->{password});
Opts::parse();
Opts::validate();
Util::connect();

# get folder objects
print("Retrieving folder list...\n\n");
my $itemView  = Vim::find_entity_views(
	'view_type' => 'Folder'
);

# build table view
my $cols = [
	'name',
	'mo_ref'
];
my @data;
foreach my $item(@{$itemView}) {
	push(@data, {
		'name' => $item->{name},
		'mo_ref' => $item->{mo_ref}->{value}
	});
}
my $view = xview->new($cols,  \@data);
$view->out();

# Disconnect from the server
print("\n");
print("Completed - disconnect from server [".$mydata->{server}."]\n");
Util::disconnect();

1;
