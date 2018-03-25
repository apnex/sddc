package ELXHBA_GlobalDriverParameter;
use WSMan::Stubs::Initializable;
use WSMan::Stubs::CIM_SettingData;
use strict;


@ELXHBA_GlobalDriverParameter::ISA = qw(_Initializable CIM_SettingData);


#===============================================================================
#			INITIALIZER
#===============================================================================

sub _init{
    my ($self, %args) = @_;
    $self->CIM_SettingData::_init();
    unless(exists $self->{invokableMethods}){
        $self->{invokableMethods} = {};
    }
    unless(exists $self->{id_keys}){
        $self->{id_keys} = ();
    }
    $self->{Paramno} = undef;
    $self->{Paramname} = undef;
    $self->{LowRange} = undef;
    $self->{HighRange} = undef;
    $self->{Def} = undef;
    $self->{Current} = undef;
    $self->{ExportFlag} = undef;
    $self->{Dynamic} = undef;
    $self->{Help} = undef;
    $self->{Permanent} = undef;
    $self->{epr_name} = undef;  
    @{$self->{id_keys}} = keys %{{ map { $_ => 1 } @{$self->{id_keys}} }};
    if(keys %args){
        $self->_subinit(%args);
    }
}


#===============================================================================


#===============================================================================
#            Paramno accessor method.
#===============================================================================

sub Paramno{
    my ($self, $newval) = @_;
    $self->{Paramno} = $newval if @_ > 1;
    return $self->{Paramno};
}
#===============================================================================


#===============================================================================
#            Paramname accessor method.
#===============================================================================

sub Paramname{
    my ($self, $newval) = @_;
    $self->{Paramname} = $newval if @_ > 1;
    return $self->{Paramname};
}
#===============================================================================


#===============================================================================
#            LowRange accessor method.
#===============================================================================

sub LowRange{
    my ($self, $newval) = @_;
    $self->{LowRange} = $newval if @_ > 1;
    return $self->{LowRange};
}
#===============================================================================


#===============================================================================
#            HighRange accessor method.
#===============================================================================

sub HighRange{
    my ($self, $newval) = @_;
    $self->{HighRange} = $newval if @_ > 1;
    return $self->{HighRange};
}
#===============================================================================


#===============================================================================
#            Def accessor method.
#===============================================================================

sub Def{
    my ($self, $newval) = @_;
    $self->{Def} = $newval if @_ > 1;
    return $self->{Def};
}
#===============================================================================


#===============================================================================
#            Current accessor method.
#===============================================================================

sub Current{
    my ($self, $newval) = @_;
    $self->{Current} = $newval if @_ > 1;
    return $self->{Current};
}
#===============================================================================


#===============================================================================
#            ExportFlag accessor method.
#===============================================================================

sub ExportFlag{
    my ($self, $newval) = @_;
    $self->{ExportFlag} = $newval if @_ > 1;
    return $self->{ExportFlag};
}
#===============================================================================


#===============================================================================
#            Dynamic accessor method.
#===============================================================================

sub Dynamic{
    my ($self, $newval) = @_;
    $self->{Dynamic} = $newval if @_ > 1;
    return $self->{Dynamic};
}
#===============================================================================


#===============================================================================
#            Help accessor method.
#===============================================================================

sub Help{
    my ($self, $newval) = @_;
    $self->{Help} = $newval if @_ > 1;
    return $self->{Help};
}
#===============================================================================


#===============================================================================
#            Permanent accessor method.
#===============================================================================

sub Permanent{
    my ($self, $newval) = @_;
    $self->{Permanent} = $newval if @_ > 1;
    return $self->{Permanent};
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
