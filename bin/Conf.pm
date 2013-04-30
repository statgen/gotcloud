###################################################################
#
# Name: Conf.pm
#
# ChangeLog:
#   $Log: InCommon.pm,v $
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
###################################################################

=head1 NAME

Conf.pm

=head1 SYNOPSIS

 use Conf;

=head1 DESCRIPTION

Functions to manage configuration files.

=cut

our %hConf = ();                # Configuration values

#==================================================================
# Subroutine:
#   setConf
#==================================================================

=head1 NAME

 #=============================================
 #  setConf ( key, value, force )
 #=============================================

=head1 DESCRIPTION

    Sets a value in a global hash to save the value
    for various key=value pairs. First key wins, so if a
    second key is provided, only the value for the first is kept.
    If $force is specified, we change the conf value even if
    it is set.

=cut

sub setConf {
    my ($key, $value, $force) = @_;
    if (! defined($force)) { $force = 0; }

    if ((! $force) && (defined($hConf{$key}))) { return; }
    $hConf{$key} = $value;
}

#==================================================================
# Subroutine:
#   loadConf
#==================================================================

=head1 NAME

 #=============================================
 #  loadConf ( config )
 #=============================================

=head1 DESCRIPTION

    Read a configuration file, extracting key=value data
    Will not return on errors

=cut

sub loadConf {
    my $conf = shift;

    my $curPath = getcwd();
    open(IN,$conf) ||
        die "Unable to read config file '$conf'  CWD=$curPath: $!\n";
    while(<IN>) {
        next if (/^#/ );    # Ignore comments
        next if (/^\s*$/);  # Ignore blank lines
        s/#.*$//;           # Remove in-line comments
        if (! /^\s*(\w+)\s*=\s*(.*)\s*$/ ) {
            die "Unable to parse config line \n" .
                "  File='$conf', line number=" . ($.+1) . "\n" .
                "  Line=$_";
        }
        my ($key,$val) = ($1,$2);
        # Ignore if the key has already been defined
        if (defined($hConf{$key})) {
            if ($opts{verbose}) {
                warn "Key '$key' already defined, ignoring line\n" .
                "  File='$conf', line number=" . ($.+1) . "\n" .
                "  Line=$_";
            }
            next;
        }

        if ( !defined($val) ) { $val = ''; }    # Undefined is null string
        setConf($key, $val);
    }
    close IN;
}

#==================================================================
# Subroutine:
#   getConf
#==================================================================

=head1 NAME

 #=============================================
 #  value = getConf ( key, required )
 #=============================================

=head1 DESCRIPTION

    Gets a value in a global hash
    If required is not TRUE and the key does not exist, return ''

=cut

sub getConf {
    my ($key, $required) = @_;
    if (! defined($required)) { $required = 0; }

    if (! defined($hConf{$key}) ) {
        if (! $required) { return '' }
        die "Required key '$key' not found in configuration files\n";
    }

    my $val = $hConf{$key};
    #   Substitute for variables of the form $(varname)
    foreach (0 .. 50) {             # Avoid infinite loop
        if ($val !~ /\$\((\S+)\)/) { last; }
        my $subkey = $1;
        my $subval = getConf($subkey);
        if ($subval eq '' && $required) {
            die "Unable to substitue for variable '$subkey' in configuration variable.\n" .
                "  key=$key\n  value=$val\n";
        }
        $val =~ s/\$\($subkey\)/$subval/;
    }
    return $val;
}

#==================================================================
# Subroutine:
#   getAbsPath
#==================================================================

=head1 NAME

 #=============================================
 #  value = getAbsPath ( file, type )
 #=============================================

=head1 DESCRIPTION

    Get the absolute path for the specified file.
    Heirachy for determining absolute path from a relative path:
       1) Based on Type:
           a) FASTQ: FASTQ_PREFIX
       2) Based on BASE_PREFIX (if <TYPE>_PREFIX is not set)
       3) Relative to the current working directory,

=cut

sub getAbsPath {
    my ($file, $type) = @_;

    #   Check if the path is already absolute
    if ( ($file =~ /^\//) ) { return($file); }

    #   Must be a relative path
    my $newPath = '';

    # Check if type was set.
    if ( defined($type) && ($type ne "") ) {
        #   Check if a directory was defined for this type.
        my $val1 = &getConf($type . '_PREFIX');
        if( defined($val1) && ($val1 ne '') ) { $newPath = "$val1/$file"; }
    }

    #   Type specific directory is not set, so check if BASE_PREFIX is set.
    if (! $newPath) {
        my $val = getConf('BASE_PREFIX');
        if ($val) { $newPath = "$val/$file"; }
    }
    if (! $newPath) { $newPath = $file; }

    #   Convert to absolute path
    my $fullPath = abs_path($newPath);
    if ( ! defined($fullPath) || ($fullPath eq '') ) {
        if( ($newPath =~ /^\//) ) { die "ERROR: Could not find $newPath\n"; }
        die "ERROR: Could not find $newPath in " . getcwd() . "\n";
    }
    return($fullPath);
}


#==================================================================
#   Perldoc Documentation
#==================================================================
1;                                  # So Perl require is happy
__END__

=head1 AUTHOR

This was written by Mary Kate Wing I<E<lt>mktrost@umich.eduE<gt>>
and Terry Gliedt I<E<lt>tpg@umich.eduE<gt>> in 2013.
This code is made available under terms of the GNU General Public License.

=cut
