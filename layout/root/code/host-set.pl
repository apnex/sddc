#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../";
use JSON::PP;
use VMware::VIRuntime;
use AppUtil::HostUtil;
$Util::script_version = "1.0";
use v5.14;

### testing
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

my %opts = (
	target_host => {
		type => "=s",
		#help => "Target host",
		required => 1
	},
	target_username => {
		type => "=s",
		#help => "Target host username ",
		required => 0,
	},
	target_password => {
		type => "=s",
		#help => "Target host password ",
		required => 0,
	},
	operation => {
		type => "=s",
		help => "Operation to perform on target host:"
			."add_standalone, disconnect, enter_maintenance,"
			."exit_maintenance, reboot, shutdown, addhost, reconnect,"
			."removehost, moveintofolder, moveintocluster",
		required => 1,
	},
	port => {
		type => "=s",
		#help => " The port number for the connection",
		required => 0,
		default => 443,
	},
	cluster => {
		type => "=s",
		#help => " The cluster in which to add the host",
		required => 0,
	},
	force => {
		type => "=i",
		help => " Flag to specify whether or not to force the addition of host"
			. " even if this is being managed by other vCenter.",
		required => 0,
		default => 0,
	}
);
Opts::add_options(%opts);

my $action = {
	op	=> 'addhost',
	cluster	=> 'mgmt',
	host	=> 'sddc.lab',
	user	=> 'root',
	pass	=> 'VMware1!'	
};

# set cluster options
Opts::set_option('server', $mydata->{server});
Opts::set_option('username', $mydata->{username});
Opts::set_option('password', $mydata->{password});
Opts::set_option('operation', $action->{op});
Opts::set_option('cluster', $action->{cluster});

# set host options
Opts::set_option('target_host', $action->{host});
Opts::set_option('target_username', $action->{user});
Opts::set_option('target_password', $action->{pass});
Opts::parse();
Opts::validate();

print("Connecting to server [".$mydata->{server}."]\n");
Util::connect();

my $operation = Opts::get_option('operation');
my $target_host = Opts::get_option('target_host');
my $apiVersion;
my $thumbprint = undef;
my $entity_view;
my $folder_views;
my $folder;
my $cluster;
my $cluster_views;
my %filterHash = create_hash($target_host);

if (Opts::get_option('operation') eq 'addhost') {
	my $sc = Vim::get_service_content();
	$apiVersion = $sc->about->apiVersion;
	if($apiVersion =~ /^4./ || $apiVersion =~ /^5./ || $apiVersion =~ /^6./) {
		my $cluster = Opts::get_option('cluster');
		my $dc_view = Vim::find_entity_view(view_type => 'Datacenter');
		my $target_host = Opts::get_option('target_host');
		my $target_username = Opts::get_option('target_username');
		my $target_password = Opts::get_option('target_password');
		my $port = Opts::get_option('port');
		print("Cluster [$cluster]: adding host [$target_host]\n");
		eval {
			my $response = $dc_view->QueryConnectionInfo(
				hostname => $target_host,
				username => $target_username,
				password => $target_password,
				port => $port
			);
		};
		if($@) {
			if(ref($@) eq 'SoapFault') {
				if(ref($@->detail) eq 'SSLVerifyFault') {
					#Util::trace(0, "SSL Verify Fault : VC server could not verify the authenticity of the host's SSL certificate\\n\n");
					$thumbprint = $@->detail->thumbprint;
				}
			}
		}
	}
	add_host(); # set a json spec
} else {
	my $host_views = HostUtils::get_hosts ('HostSystem', undef, undef, %filterHash);
	if($host_views) {
		$entity_view = shift @$host_views;
		given($operation) {
			when ("disconnect") {
				#disconnect_host($entity_view);
			}
			when ("reconnect") {
				#reconnect_host($entity_view);
			}
			when ("enter_maintenance") {
				#enter_maintenance_mode($entity_view);
			}
			when ("exit_maintenance") {
				#exit_maintenance_mode($entity_view);
			}
			when ("reboot") {
				#reboot_host($entity_view);
			}
			when ("shutdown") {
				#shutdown_host($entity_view);
			}
			when ("remove") {
				remove_host($entity_view);
			}
			when ("moveintofolder") {
				#move_into_folder($entity_view);
			}
			when ("moveintocluster") {
				#move_into_cluster($entity_view);
			}
		}
	}
}
Util::disconnect();

sub create_hash {
	my ($target_host) = @_;
	my %filterHash;
	if ($target_host) {
		$filterHash{'name'} = $target_host;
	}
	return %filterHash;
}

sub get_cluster_views {
	my $cluster_name = Opts::get_option('cluster');
	if (defined Opts::get_option('cluster')) {
		$cluster_views = Vim::find_entity_views(view_type => 'ClusterComputeResource', filter => {
			name => $cluster_name
		});
		if (@$cluster_views) {
			$cluster = shift @$cluster_views;
			return $cluster;
		} else {
			Util::trace(0,"No cluster found\n ");
			return $cluster;
		}
	}
}

sub get_folder_views {
	my $folder_name = Opts::get_option('folder');
	if (defined Opts::get_option('folder')) {
		$folder_views = Vim::find_entity_views(view_type => 'Folder',
			filter => {name => $folder_name}
		);
		if (@$folder_views) {
			$folder = shift @$folder_views;
			return $folder;
		} else {
			Util::trace(0,"No folder found\n ");
			return $folder;
		}
	} else {
		$folder_views = Vim::find_entity_views(view_type => 'Folder');
		foreach(@$folder_views) {
			my $folder = $_;
			my $childType = $folder->childType;
			foreach(@$childType) {
				if($_ eq "ComputeResource") {
					return $folder;
				}
			}
		}
		Util::trace(0,"No folder found\n");
		return;
	}
}

# Add host to a cluster
sub add_host {
	my $target_host = Opts::get_option('target_host');
	my $target_username = Opts::get_option('target_username');
	my $target_password = Opts::get_option('target_password');
	my $port = Opts::get_option('port');
	my $force = Opts::get_option('force');
	my $clusterfound = get_cluster_views();
	if(defined $clusterfound) {
		eval {
			my $hostConnectSpec = (HostConnectSpec->new(force => ($force || 0),
				hostName => $target_host,
				userName => $target_username,
				password => $target_password,
				port => $port,
				sslThumbprint => $thumbprint
			));
			$cluster->AddHost(spec => $hostConnectSpec, asConnected => 1);
			my $host_views = HostUtils::get_hosts ('HostSystem', undef, undef, %filterHash);
			if($host_views) {
				$entity_view = shift(@{$host_views});
			}
			my $check_mode = $entity_view->runtime->inMaintenanceMode;
			if($check_mode == 1) {
				exit_maintenance_mode($entity_view);
			}
			print("Host [$target_host] added successfully\n");
		};
		if($@) {
			if(ref($@) eq 'SoapFault') {
				given(ref($@->detail)) {
					when("DuplicateName") {
						print("Host [$target_host] already exists\n");
					}
					when("AlreadyConnected") {
						print("Host [$target_host] already connected to the vCenter\n");
					}
					when("NoHost") {
						print("Host [$target_host] does not exist\n");
					}
					when("AlreadyBeingManaged") {
						print("Host [$target_host] already being managed by another host\n");
					}
					when("InvalidLogin") {
						print("Host [$target_host] authentication failed, invalid username or password\n");
					}
					default {
						print("Error: ".$@."\n");
					}
				}
			} else {
				Util::trace(0, "Error: "  . $@ . " ");
			}
		}
	} else {
		Util::trace(0," ");
	}
}

sub enter_maintenance_mode {
	my $target_host = shift;
	#my $suspend_call = 0 ;
	#$suspend_call = suspend_vm($entity_view);
	#if((defined $suspend_call) && ($suspend_call == 1)) {
	#	return;
	#}
	eval {
		$target_host->EnterMaintenanceMode(timeout => 0);
		#Util::trace(0, "Host [".$target_host->name."] entered maintenance mode successfully\n");
		print("Host [".$target_host->name."] entered maintenance mode successfully\n");
	};
	if($@) {
		if (ref($@) eq 'SoapFault') {
			if (ref($@->detail) eq 'InvalidState') {
				Util::trace(0,"\nThe enter_maintenancemode operation"
					." is not allowed in the current state");
			} elsif (ref($@->detail) eq 'Timedout') {
				Util::trace(0,"\nOperation is timed out\n");
			} elsif (ref($@->detail) eq 'HostNotConnected') {
				Util::trace(0,"Unable to communicate with the"
					." remote host, since it is disconnected.\n");
			} else {
				Util::trace(0,"Host cannot be entered into maintenance mode \n" . $@. "");
			}
		} else {
			Util::trace(0,"Host cannot be entered into maintenance mode \n" . $@. "");
		}
	}
}

# Exit maintenance mode
sub exit_maintenance_mode {
	my $target_host = shift;
	eval {
		$target_host->ExitMaintenanceMode(timeout => 0);
		#Util::trace(0, "Host [".$target_host->name."] exited maintenance mode successfully\n ");
		print("Host [".$target_host->name."] exited maintenance mode successfully\n");
	};
	if($@) {
		if (ref($@) eq 'SoapFault') {
			if (ref($@->detail) eq 'InvalidState') {
				Util::trace(0,"\nThe operation is not allowed in the current state");
			} else {
				Util::trace(0,"\nHost cannot exit maintenance mode \n" . $@. "");
			}
		} else {
			Util::trace(0,"\nHost cannot exit maintenance mode \n" . $@. "");
		}
	}
}

# Remove host
sub remove_host {
	my $target_host = shift;
	my $host_name = Opts::get_option('target_host');
	if($entity_view->parent->type eq 'ComputeResource') {
		$target_host = ($entity_view->parent);
		my $target_host_view = Vim::get_view(mo_ref => $target_host);
		$target_host =  $target_host_view;
	} elsif ($entity_view->parent->type eq 'ClusterComputeResource') {
		$target_host = ($entity_view);
		if (!$entity_view->runtime->inMaintenanceMode) {
			enter_maintenance_mode($entity_view);
		}
	}
	eval {
		$target_host->Destroy();
		Util::trace(0, "Host [$host_name] removed successfully\n");
	};
	if ($@) {
		if (ref($@) eq 'SoapFault') {
			if (ref($@->detail) eq 'InvalidState') {
				Util::trace(0,"\n The operation is not allowed in the current state\n");
			} elsif (ref($@->detail) eq 'RuntimeFault') {
				Util::trace(0,"\nRuntime Fault\n");
			} else {
				Util::trace(0, "Error: "  . $@ . " ");
			}
		} else {
			Util::trace(0, "Error: "  . $@ . " ");
		}
	}
}

# Move the existing host into cluster
sub move_into_cluster {
	my $clusterfound = get_cluster_views();
	my $flag = 0;
	if(defined $clusterfound) {
		my $cluster_name = Opts::get_option('cluster');
		my  @listArray = ($entity_view);
		eval {
			if ($entity_view->parent->type eq 'ClusterComputeResource') {
				if (!$entity_view->runtime->inMaintenanceMode) {
					enter_maintenance_mode($entity_view);
					$flag = 1;
				}
			}
			$cluster->MoveInto(host => @listArray);
			Util::trace(0,"\nHost $target_host moved into cluster $cluster_name \n");
			if($flag == 1) {
				exit_maintenance_mode($entity_view);
			}
		};
		if ($@) {
			if (ref($@) eq 'SoapFault') {
				if (ref($@->detail) eq 'DuplicateName') {
					Util::trace(0,"\nHost $target_host already exist\n");
				} elsif (ref($@->detail) eq 'InvalidFolder') {
					Util::trace(0, "\nInvalid folder");
				} elsif (ref($@->detail) eq 'InvalidState') {
					Util::trace(0, " \nmoveintocluster operation is not allowed in "
						."the current state\n");
				} elsif (ref($@->detail) eq 'InvalidArgument') {
					Util::trace(0, " \nA specified parameter was not correct\n");
				} elsif (ref($@->detail) eq 'NotSupported') {
					Util::trace(0, "\nmovehost operation is not supported on the object\n");
				} else {
					Util::trace(0, "Error: "  . $@ . " ");
				}
			} else {
				Util::trace(0, "Error: "  . $@ . " ");
			}
		}
	} else {
		Util::trace(0," ");
	}
}

# Disconnect a host
sub disconnect_host {
	my $target_host = shift;
	eval {
		$target_host->DisconnectHost();
		Util::trace(0, "\nHost '" . $target_host->name . "' disconnected successfully\n");
	};
	if ($@) {
		if (ref($@) eq 'SoapFault') {
			if (ref($@->detail) eq 'NotSupported') {
				Util::trace(0,"\nRunning directly on an ESX Server host.");
			} elsif (ref($@->detail) eq 'InvalidState') {
				Util::trace(0,"\nThe operation is not allowed in the current state.\n");
			} else {
				Util::trace (0, "\nHost  can't be disconnected \n" . $@. "" );
			}
		} else {
			Util::trace (0, "\nHost  can't be disconnected \n" . $@. "" );
		}
	}
}

# Reconnect a host
sub reconnect_host {
	my $target_host = shift;
	eval {
		$target_host->ReconnectHost();
		Util::trace(0, "\nHost '" . $target_host->name . "' reconnected successfully\n");
	};
	if ($@) {
		if (ref($@) eq 'SoapFault') {
			if (ref($@->detail) eq 'InvalidState') {
				Util::trace(0,"\nThe operation is not allowed in the current state\n");
			} elsif (ref($@->detail) eq 'AlreadyBeingManaged') {
				Util::trace(0,"\nHost is already being managed by"
					." another VirtualCenter server\n");
			} else {
				Util::trace(0,"\nHost  can't be reconnected \n" . $@. "");
			}
		} else {
			Util::trace(0,"\nHost  can't be reconnected \n" . $@. "");
		}
	}
}
