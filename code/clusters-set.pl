#!/usr/bin/perl -w
use strict;
use warnings;
use VMware::VIRuntime;
use VMware::VILib;
use Data::Dumper;
use JSON::PP;

# read in JSON config
my $filename = '/config.json';
print("Reading config [".$filename."]\n");
my $json = JSON::PP->new->ascii->pretty->allow_nonref;
my $jsondata;
if(open(my $json_file, '<', $filename)) {
	local $/;
	$jsondata = <$json_file>;
	close($json_file);
}
chomp($jsondata);
print($jsondata."\n");
my $mydata = $json->decode($jsondata);

# set SDK options and connect
print("Connect to server [".$mydata->{server}."]\n");
Opts::set_option('server', $mydata->{server});
Opts::set_option('username', $mydata->{username});
Opts::set_option('password', $mydata->{password});
Opts::parse();
Opts::validate();
Util::connect();

# get root host folder object
my $itemView  = Vim::find_entity_view(
	'view_type' => 'Folder',
	'filter'    => {
		'name' => 'host'
	} 
);

foreach my $item(@{$mydata->{clusters}}) {
	print("Checking if cluster: [".$item->{name}."] exists...\n");
	my $clusterView = Vim::find_entity_view(
		'view_type' => 'ClusterComputeResource',
		'filter'    => {
			'name' => $item->{name}
		} 
	);
	if($clusterView) {
		print("Cluster [".$item->{name}."] already exists!\n");
		next;
	}
	
	# create if cluster does not exist
	my $clusterSpec = new ClusterConfigSpec(
		'drsConfig' => createDrsConfig($item->{ClusterConfigSpec}->{drsConfig}),
		'dasConfig' => createDasConfig($item->{ClusterConfigSpec}->{dasConfig})
	);	
	$itemView->CreateCluster(
		'_this'	=> $itemView,
		'name'	=> $item->{name},
		'spec'	=> $clusterSpec
	);
	print("Cluster: ".$item->{name}." Created!\n");
}

# Disconnect from the server
print("Completed - disconnect from server [".$mydata->{server}."]\n");
Util::disconnect();

# instantiate DRS config spec
sub createDrsConfig {
	my $struct = shift;
	my $drsConfig = new ClusterDrsConfigInfo(
		'vmotionRate' => $struct->{vmotionRate},
		'enabled' => $struct->{enabled}
	);
	return $drsConfig;
}

# instantiate DAS config spec
sub createDasConfig {
	my $struct = shift;
	my $dasConfig = new ClusterDasConfigInfo(
		'enabled' => '1',
	        'admissionControlEnabled' => '1',
	        'failoverLevel' => '3',
		'option' => newOpt($struct->{option})
	);
	return $dasConfig;
}

# instantiate DAS option spec
sub newOpt {
	my $opts = shift;
	my @optionSet;
	foreach my $opt(@{$opts}) {
		push(@optionSet, OptionValue->new(
			'key' => $opt->{key},
			'value' => $opt->{value}
		));
	}
	return \@optionSet;
}
