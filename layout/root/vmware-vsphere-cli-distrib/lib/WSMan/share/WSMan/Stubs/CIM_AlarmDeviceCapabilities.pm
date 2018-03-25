package CIM_AlarmDeviceCapabilities;
use WSMan::Stubs::Initializable;
use WSMan::Stubs::CIM_EnabledLogicalElementCapabilities;
use strict;


@CIM_AlarmDeviceCapabilities::ISA = qw(_Initializable CIM_EnabledLogicalElementCapabilities);


#===============================================================================
#			INITIALIZER
#===============================================================================

sub _init{
    my ($self, %args) = @_;
    $self->CIM_EnabledLogicalElementCapabilities::_init();
    unless(exists $self->{invokableMethods}){
        $self->{invokableMethods} = {};
    }
    unless(exists $self->{id_keys}){
        $self->{id_keys} = ();
    }
    $self->{RequestedAlarmStatesSupported} = undef;
    $self->{AlarmIndicatorTypesConfigurable} = undef;
    $self->{epr_name} = undef;  
    @{$self->{id_keys}} = keys %{{ map { $_ => 1 } @{$self->{id_keys}} }};
    if(keys %args){
        $self->_subinit(%args);
    }
}


#===============================================================================


#===============================================================================
#            RequestedAlarmStatesSupported accessor method.
#===============================================================================

sub RequestedAlarmStatesSupported{
    my ($self, $newval) = @_;
    $self->{RequestedAlarmStatesSupported} = $newval if @_ > 1;
    return $self->{RequestedAlarmStatesSupported};
}
#===============================================================================


#===============================================================================
#            AlarmIndicatorTypesConfigurable accessor method.
#===============================================================================

sub AlarmIndicatorTypesConfigurable{
    my ($self, $newval) = @_;
    $self->{AlarmIndicatorTypesConfigurable} = $newval if @_ > 1;
    return $self->{AlarmIndicatorTypesConfigurable};
}
#===============================================================================


#===============================================================================
#           epr_name accessor method.
#===============================================================================

sub epr_name{
    my ($self, $newval) = @_;
    $self->{epr_name} = $newval if @_ > 1;
    return $self->{epr_name};
}
#===============================================================================


1;
