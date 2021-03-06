package LSIESG_StoreLibCmd;
use WSMan::Stubs::Initializable;
use strict;


@LSIESG_StoreLibCmd::ISA = qw(_Initializable);


#===============================================================================
#			INITIALIZER
#===============================================================================

sub _init{
    my ($self, %args) = @_;
    unless(exists $self->{invokableMethods}){
        $self->{invokableMethods} = {};
    }
    unless(exists $self->{id_keys}){
        $self->{id_keys} = ();
    }
    $self->{InstanceID} = undef;
    $self->{ElementName} = undef;
    $self->{CmdType} = undef;
    $self->{Cmd} = undef;
    $self->{DeviceDescriminant} = undef;
    $self->{PdDeviceId} = undef;
    $self->{PdSeqNum} = undef;
    $self->{EnclDeviceId} = undef;
    $self->{EnclElementIndex} = undef;
    $self->{ArraySeqNum} = undef;
    $self->{ArrayRef} = undef;
    $self->{LdSeqNum} = undef;
    $self->{LdTargetId} = undef;
    $self->{EventSeqNum} = undef;
    $self->{ConfigGuidIndex} = undef;
    $self->{GenericRef} = undef;
    $self->{CmdParam} = undef;
    $self->{DataSize} = undef;
    $self->{PData} = undef;
    $self->{ReturnCode} = undef;
    $self->{epr_name} = undef;  
    push @{$self->{id_keys}}, 'InstanceID';
    @{$self->{id_keys}} = keys %{{ map { $_ => 1 } @{$self->{id_keys}} }};
    if(keys %args){
        $self->_subinit(%args);
    }
}


#===============================================================================


#===============================================================================
#            InstanceID accessor method.
#===============================================================================

sub InstanceID{
    my ($self, $newval) = @_;
    $self->{InstanceID} = $newval if @_ > 1;
    return $self->{InstanceID};
}
#===============================================================================


#===============================================================================
#            ElementName accessor method.
#===============================================================================

sub ElementName{
    my ($self, $newval) = @_;
    $self->{ElementName} = $newval if @_ > 1;
    return $self->{ElementName};
}
#===============================================================================


#===============================================================================
#            CmdType accessor method.
#===============================================================================

sub CmdType{
    my ($self, $newval) = @_;
    $self->{CmdType} = $newval if @_ > 1;
    return $self->{CmdType};
}
#===============================================================================


#===============================================================================
#            Cmd accessor method.
#===============================================================================

sub Cmd{
    my ($self, $newval) = @_;
    $self->{Cmd} = $newval if @_ > 1;
    return $self->{Cmd};
}
#===============================================================================


#===============================================================================
#            DeviceDescriminant accessor method.
#===============================================================================

sub DeviceDescriminant{
    my ($self, $newval) = @_;
    $self->{DeviceDescriminant} = $newval if @_ > 1;
    return $self->{DeviceDescriminant};
}
#===============================================================================


#===============================================================================
#            PdDeviceId accessor method.
#===============================================================================

sub PdDeviceId{
    my ($self, $newval) = @_;
    $self->{PdDeviceId} = $newval if @_ > 1;
    return $self->{PdDeviceId};
}
#===============================================================================


#===============================================================================
#            PdSeqNum accessor method.
#===============================================================================

sub PdSeqNum{
    my ($self, $newval) = @_;
    $self->{PdSeqNum} = $newval if @_ > 1;
    return $self->{PdSeqNum};
}
#===============================================================================


#===============================================================================
#            EnclDeviceId accessor method.
#===============================================================================

sub EnclDeviceId{
    my ($self, $newval) = @_;
    $self->{EnclDeviceId} = $newval if @_ > 1;
    return $self->{EnclDeviceId};
}
#===============================================================================


#===============================================================================
#            EnclElementIndex accessor method.
#===============================================================================

sub EnclElementIndex{
    my ($self, $newval) = @_;
    $self->{EnclElementIndex} = $newval if @_ > 1;
    return $self->{EnclElementIndex};
}
#===============================================================================


#===============================================================================
#            ArraySeqNum accessor method.
#===============================================================================

sub ArraySeqNum{
    my ($self, $newval) = @_;
    $self->{ArraySeqNum} = $newval if @_ > 1;
    return $self->{ArraySeqNum};
}
#===============================================================================


#===============================================================================
#            ArrayRef accessor method.
#===============================================================================

sub ArrayRef{
    my ($self, $newval) = @_;
    $self->{ArrayRef} = $newval if @_ > 1;
    return $self->{ArrayRef};
}
#===============================================================================


#===============================================================================
#            LdSeqNum accessor method.
#===============================================================================

sub LdSeqNum{
    my ($self, $newval) = @_;
    $self->{LdSeqNum} = $newval if @_ > 1;
    return $self->{LdSeqNum};
}
#===============================================================================


#===============================================================================
#            LdTargetId accessor method.
#===============================================================================

sub LdTargetId{
    my ($self, $newval) = @_;
    $self->{LdTargetId} = $newval if @_ > 1;
    return $self->{LdTargetId};
}
#===============================================================================


#===============================================================================
#            EventSeqNum accessor method.
#===============================================================================

sub EventSeqNum{
    my ($self, $newval) = @_;
    $self->{EventSeqNum} = $newval if @_ > 1;
    return $self->{EventSeqNum};
}
#===============================================================================


#===============================================================================
#            ConfigGuidIndex accessor method.
#===============================================================================

sub ConfigGuidIndex{
    my ($self, $newval) = @_;
    $self->{ConfigGuidIndex} = $newval if @_ > 1;
    return $self->{ConfigGuidIndex};
}
#===============================================================================


#===============================================================================
#            GenericRef accessor method.
#===============================================================================

sub GenericRef{
    my ($self, $newval) = @_;
    $self->{GenericRef} = $newval if @_ > 1;
    return $self->{GenericRef};
}
#===============================================================================


#===============================================================================
#            CmdParam accessor method.
#===============================================================================

sub CmdParam{
    my ($self, $newval) = @_;
    $self->{CmdParam} = $newval if @_ > 1;
    return $self->{CmdParam};
}
#===============================================================================


#===============================================================================
#            DataSize accessor method.
#===============================================================================

sub DataSize{
    my ($self, $newval) = @_;
    $self->{DataSize} = $newval if @_ > 1;
    return $self->{DataSize};
}
#===============================================================================


#===============================================================================
#            PData accessor method.
#===============================================================================

sub PData{
    my ($self, $newval) = @_;
    $self->{PData} = $newval if @_ > 1;
    return $self->{PData};
}
#===============================================================================


#===============================================================================
#            ReturnCode accessor method.
#===============================================================================

sub ReturnCode{
    my ($self, $newval) = @_;
    $self->{ReturnCode} = $newval if @_ > 1;
    return $self->{ReturnCode};
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
