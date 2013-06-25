###################################################################
#
# Name: GC_Common.pm
#
# ChangeLog:
#   $Log: GC_Common.pm,v $
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
###################################################################
use Scalar::Util qw(looks_like_number);

=head1 NAME

GC_Common.pm

=head1 SYNOPSIS

 use GC_Common;

=head1 DESCRIPTION

Functions common to GotCloud

=cut
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
    if ( defined($type) && ($type ne '') ) {
        #   Check if a directory was defined for this type.
        my $val1 = getConf($type . '_PREFIX');
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

=head1 NAME

 #=============================================
 #  value = getIntConf( key, required )
 #=============================================

=head1 DESCRIPTION

    Get the value for a config value. If it is set,
    verify the value is a number.  If not, die.

=cut

sub getIntConf {
    my ($key, $required) = @_;
    my $val = getConf($key, $required);

    if (! $val) { return $val; }
    if (! looks_like_number($val)) {
        die "$key can only be set to a number, not $val\n";
    }
    return $val;
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
