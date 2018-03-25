#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../";
use JSON::PP;
use VMware::VIRuntime;
use AppUtil::HostUtil;

$Util::script_version = "1.0";

my %operations = (
   "add_standalone", "",
   "disconnect", "" ,
   "reconnect", "" ,
   "enter_maintenance", "",
   "exit_maintenance", "",
   "reboot", "",
   "shutdown", "",
   "addhost", "",
   "removehost", "",
   "moveintofolder", "",
   "moveintocluster", "",
);

my %opts = (
   target_host => {
      type => "=s",
      help => "Target host",
      required => 1,
   },
   target_username => {
      type => "=s",
      help => "Target host username ",
      required => 0,
   },
   target_password => {
      type => "=s",
      help => "Target host password ",
      required => 0,
   },
   # bug 300034
   operation => {
      type => "=s",
      help => "Operation to perform on target host:"
               ."add_standalone, disconnect, enter_maintenance,"
               ."exit_maintenance, reboot, shutdown, addhost, reconnect,"
               ."removehost, moveintofolder, moveintocluster",
      required => 1,
   },
   suspend => {
      type => "=i",
      help => " Flag to specify whether or not to suspend the virtual machines",
      required => 0,
      default => 0,
   },
   quiet => {
      type => "=i",
      help => " Flag to specify whether or not to provide progress messages"
            . " as the virtual machines are suspended for some operations.",
      required => 0,
      default => 1,
   },
   port => {
      type => "=s",
      help => " The port number for the connection",
      required => 0,
      default => 443,
   },
   cluster => {
      type => "=s",
      help => " The cluster in which to add the host",
      required => 0,
   },
   folder => {
      type => "=s",
      help => " The folder in which to add the host",
      required => 0,
   },
   force => {
      type => "=i",
      help => " Flag to specify whether or not to force the addition of host"
            . " even if this is being managed by other vCenter.",
      required => 0,
      default => 0,
   },
);

Opts::add_options(%opts);

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

# set sdk options and connect
print("Connecting to server [".$mydata->{server}."]\n");
Opts::set_option('server', $mydata->{server});
Opts::set_option('username', $mydata->{username});
Opts::set_option('password', $mydata->{password});
Opts::set_option('operation', 'addhost');
Opts::set_option('cluster', 'Compute-01');
Opts::set_option('target_host', 'esx01.lab');
Opts::set_option('target_username', 'root');
Opts::set_option('target_password', 'VMware1!');
##### testing
Opts::parse();
Opts::validate(\&validate);

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
my %filterHash = create_hash($target_host );
my $suspendFlag = Opts::get_option('suspend');
my $quietflag = Opts::get_option('quiet');

if (Opts::get_option('operation') eq 'addhost') {
my $sc = Vim::get_service_content();
   $apiVersion = $sc->about->apiVersion;
   
   if($apiVersion =~ /^4./ || $apiVersion =~ /^5./ || $apiVersion =~ /^6./) {
   
      my $dc_view = Vim::find_entity_view(view_type => 'Datacenter');
      my $target_host = Opts::get_option('target_host');
      my $target_username = Opts::get_option('target_username');
      my $target_password = Opts::get_option('target_password');
      my $port = Opts::get_option('port');
      eval {
         my $response = $dc_view->QueryConnectionInfo(hostname => $target_host,
                                                      username => $target_username,
                                                      password => $target_password,
                                                      port => $port);
      };
   }
    add_host();
}
else {
   my $host_views = HostUtils::get_hosts ('HostSystem',undef,undef, %filterHash);
   if ($host_views) {
      $entity_view = shift @$host_views;
      if( $operation eq "disconnect" ) {
         disconnect_host($entity_view);
      }
      elsif( $operation eq "reconnect" ) {
         reconnect_host($entity_view);
      }
      elsif( $operation eq "enter_maintenance" ) {
         enter_maintenance_mode($entity_view);
      }
      elsif( $operation eq "exit_maintenance" ) {
         exit_maintenance_mode($entity_view);
      }
      elsif( $operation eq "reboot" ) {
         reboot_host($entity_view);
      }
      elsif( $operation eq "shutdown" ) {
         shutdown_host($entity_view);
      }
      elsif( $operation eq "removehost" ) {
        remove_host($entity_view);
      }
      elsif( $operation eq "moveintofolder" ) {
         move_into_folder($entity_view);
      }
      elsif( $operation eq "moveintocluster" ) {
         move_into_cluster($entity_view);
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
      $cluster_views =
         Vim::find_entity_views(view_type => 'ClusterComputeResource',
                                   filter => {name => $cluster_name});
      if (@$cluster_views) {
         $cluster = shift @$cluster_views;
         return $cluster;
      }
      else {
         Util::trace(0,"No cluster found\n ");
         return $cluster;
      }
   }
}

sub get_folder_views {
my $folder_name = Opts::get_option('folder');

   if (defined Opts::get_option('folder')) {
      $folder_views =
         Vim::find_entity_views(view_type => 'Folder',
                                   filter => {name => $folder_name});
      if (@$folder_views) {
         $folder = shift @$folder_views;
         return $folder;
      }
      else {
         Util::trace(0,"No folder found\n ");
         return $folder;
      }
   }
   else {
     $folder_views =
         Vim::find_entity_views(view_type => 'Folder');
      foreach(@$folder_views) {
         my $folder = $_;
         my $childType = $folder->childType;
         foreach(@$childType){
            if($_ eq "ComputeResource") {
               return $folder;
            }
         }
      }
      Util::trace(0,"No folder found\n");
      return;
   }
}



#Add host to a cluster
#
sub add_host {
   my $target_host = Opts::get_option('target_host');
   my $target_username = Opts::get_option('target_username');
   my $target_password = Opts::get_option('target_password');
   my $port = Opts::get_option('port');
   my $force = Opts::get_option('force');
   my $clusterfound = get_cluster_views();
   if(defined $clusterfound) {
      eval {
         my $host_connect_spec = (HostConnectSpec->new(force => ($force || 0),
                                                       hostName => $target_host,
                                                       userName => $target_username,
                                                       password => $target_password,
                                                       port => $port,
													   sslThumbprint => $thumbprint, 
                                                      ));
       $cluster->AddHost(spec => $host_connect_spec, asConnected => 1);
       my $host_views = HostUtils::get_hosts ('HostSystem',undef,undef, %filterHash);
       if ($host_views) {
          $entity_view = shift @$host_views;
       }
       # defect 224265
       my $check_mode = $entity_view->runtime->inMaintenanceMode;
       if($check_mode == 1) {
          exit_maintenance_mode($entity_view);
       }
       Util::trace(0, "\nHost '$target_host' added successfully\n");
     };
     if ($@) {
        if (ref($@) eq 'SoapFault') {
           if (ref($@->detail) eq 'DuplicateName') {
              Util::trace(0,"\nHost $target_host already exist\n");
           }
           elsif (ref($@->detail) eq 'AlreadyConnected') {
              Util::trace(0, "\nSpecified host is already ".
                             "connected to the vCenter\n");
           }
           elsif (ref($@->detail) eq 'NoHost') {
              Util::trace(0, " \nSpecified host does not exist\n");
           }
           elsif (ref($@->detail) eq 'AlreadyBeingManaged') {
              Util::trace(0, " \nHost is already being managed by other host\n");
           }
           elsif (ref($@->detail) eq 'InvalidLogin') {
              Util::trace(0, "\nHost authentication failed."
                           ." Invalid Username and\/or Password\n ");
           }
           else {
              Util::trace(0, "Error: "  . $@ . " ");
           }
        }
        else {
           Util::trace(0, "Error: "  . $@ . " ");
        }
     }
   }
   else {
       Util::trace(0," ");
   }
}


#Remove host
#
sub remove_host {
   my $target_host = shift;
   my $host_name = Opts::get_option('target_host');
# Bug 289362  fix start 
   if ($entity_view->parent->type eq 'ComputeResource') {
      $target_host = ($entity_view->parent);
      my $target_host_view = Vim::get_view(mo_ref => $target_host);
      $target_host =  $target_host_view;
   }
   elsif ($entity_view->parent->type eq 'ClusterComputeResource') {
      $target_host = ($entity_view);
      if (!$entity_view->runtime->inMaintenanceMode) {
           enter_maintenance_mode($entity_view);
      }
   }
# Bug 289362  fix end
   eval {
     $target_host->Destroy();
     Util::trace(0, "\nHost '$host_name' removed successfully\n");
   };
   if ($@) {
      if (ref($@) eq 'SoapFault') {
         if (ref($@->detail) eq 'InvalidState') {
            Util::trace(0,"\n The operation is not allowed in the current state\n");
         }
         elsif (ref($@->detail) eq 'RuntimeFault') {
            Util::trace(0,"\nRuntime Fault\n");
         }
         else {
            Util::trace(0, "Error: "  . $@ . " ");
         }
      }
      else {
         Util::trace(0, "Error: "  . $@ . " ");
      }
   }
}

#Move the existing host into cluster
sub move_into_cluster {
my $clusterfound = get_cluster_views();
my $flag = 0;
   # Bug 289362  / 223627 fix start 
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
         $cluster->MoveInto(host=>@listArray);
          Util::trace(0,"\nHost $target_host moved into cluster $cluster_name \n");
            if($flag == 1){
                  exit_maintenance_mode($entity_view);
            }
   # Bug 289362  223627 fix end 
        
      };
      if ($@) {
         if (ref($@) eq 'SoapFault') {
            if (ref($@->detail) eq 'DuplicateName') {
               Util::trace(0,"\nHost $target_host already exist\n");
            }
            elsif (ref($@->detail) eq 'InvalidFolder') {
               Util::trace(0, "\nInvalid folder");
            }
            elsif (ref($@->detail) eq 'InvalidState') {
               Util::trace(0, " \nmoveintocluster operation is not allowed in "
                              ."the current state\n");
            }
            elsif (ref($@->detail) eq 'InvalidArgument') {
               Util::trace(0, " \nA specified parameter was not correct\n");
            }
            elsif (ref($@->detail) eq 'NotSupported') {
               Util::trace(0, "\nmovehost operation is not supported on the object\n");
            }
            else {
               Util::trace(0, "Error: "  . $@ . " ");
            }
        }
        else {
           Util::trace(0, "Error: "  . $@ . " ");
        }
      }
   }
   else {
       Util::trace(0," ");
   }
}

# Disconnect a host
# -----------------
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
         }
         elsif (ref($@->detail) eq 'InvalidState') {
            Util::trace(0,"\nThe operation is not allowed in the current state.\n");
         }
         else {
            Util::trace (0, "\nHost  can't be disconnected \n" . $@. "" );
         }
      }
      else {
         Util::trace (0, "\nHost  can't be disconnected \n" . $@. "" );
      }
   }
}

# Reconnect a host
# ----------------
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
         }
         elsif (ref($@->detail) eq 'AlreadyBeingManaged') {
            Util::trace(0,"\nHost is already being managed by"
                         . " another VirtualCenter server\n");
         }
         else {
            Util::trace(0,"\nHost  can't be reconnected \n" . $@. "");
         }
      }
      else {
         Util::trace(0,"\nHost  can't be reconnected \n" . $@. "");
      }
   }
}

sub validate {
   my $operation = Opts::get_option('operation');
  my $valid = 1;
   if (($operation eq 'add_standalone') &&
         ((!Opts::option_is_set('target_username'))||
         !Opts::option_is_set('target_password'))) {
       Util::trace(0, "Must specify target_username and target_password "
                    . "options for add_standalone operation \n");
       $valid = 0;
   }
   if (($operation eq 'addhost') &&
         ((!Opts::option_is_set('target_username'))||
         (!Opts::option_is_set('target_password'))||(!Opts::option_is_set('cluster')))) {
       Util::trace(0, "Must specify target_username and target_password and cluster "
                    . "options for addhost operation \n");
       $valid = 0;
   }
 # Bug 289362/300062/300066  fix start 
   if (($operation eq 'moveintofolder') &&
        (!Opts::option_is_set('folder'))) {
       Util::trace(0, "Must specify folder name "
                    . "options for moveinto folder operation \n");
       $valid = 0;
   }
   if (($operation eq 'moveintocluster') &&
        (!Opts::option_is_set('cluster'))){
      Util::trace(0, "Must specify cluster "
                    . "name options for moveinto cluster operation \n");
      $valid = 0;
   }
 # Bug 289362/300062/300066  fix end
   if (!exists($operations{$operation})) {
      Util::trace(0,"\nInvalid operation: $operation\n");
      Util::trace(0,"List of valid operations \n");
      map { print "  $_\n"; } sort keys %operations;
      $valid = 0;
   }
   return $valid;
}
