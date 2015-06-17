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

=head1 NAME

 #=============================================
 #  value = genMD5Files( )
 #=============================================

=head1 DESCRIPTION

    If necessary, generate the MD5 files for REF in MD5_PATH.
    If MD5_PATH is not in the configuration, set it to 'OUT_DIR/md5'.
    MD5 files will be generated if any of the following are true:
       1) 'md5Info.txt' does not exist in MD5_PATH
       2) REF is not found 'md5Info.txt'
       3) the timestamp for REF in 'md5Info.txt is older than
          the timestamp of REF

=cut

sub genMD5Files {
    my $ref = getConf("REF", 1);
    my $md5Dir = getConf("MD5_DIR");

    if(defined $ENV{REF_PATH})
    {
        if($md5Dir)
        {
            warn "WARNING: REF_PATH defined in environment ($ENV{REF_PATH}), ".
            "but overriding it to use 'MD5_DIR' set in configuration ($md5Dir).\n";
        }
        else
        {
            $md5Dir = $ENV{REF_PATH};
            setConf("MD5_DIR", $md5Dir);
        }
    }

    if(!$md5Dir)
    {
        # MD5 path is not specified, so set it in the output directory.
        $md5Dir = getConf("OUT_DIR", 1)."/md5/%2s/%2s/%s";
        setConf("MD5_DIR", $md5Dir);
    }


    # Check if the md5Dir has % values in it.  If so, split it.
    my $md5NoPercent = $md5Dir;
    my $md5Percent = "";
    if($md5Dir =~ m/^([^%]*)(.*)/)
    {
        $md5NoPercent = $1;
        $md5Percent = $2;
    }
    $md5NoPercent =~ s/\/$//;

    my $md5Info = "$md5NoPercent/md5Info.txt";
    my $md5InfoFh;
    my $writeMD5 = 1;
    my $md5KeepContents = "";

    if(-r $md5Info)
    {
        open($md5InfoFh, '<', $md5Info) || die "Can't open $md5Info: $!\n";
        my $md5InfoContents;
        while ($md5InfoContents = <$md5InfoFh>)
        {
            chomp $md5InfoContents;
            if($md5InfoContents =~ m/$ref = ([0-9]+)/)
            {
                if($1 == (stat ($ref))[9])
                {
                    $writeMD5 = 0;
                    last;
                }
            }
            else
            {
                $md5KeepContents .= "$md5InfoContents\n";
            }
        }
        close($md5InfoFh);
    }

    if($writeMD5 == 1)
    {
        # Write MD5 info.
        my $md5Script = getConf("MD5_SCRIPT", 1);
        my $ref = getConf("REF",1);
        my $cmd = "";
        my $file = $ref;
        if($ref =~ /.gz$/)
        {
            $cmd = "zcat $ref | ";
            $file = "";
        }
        $cmd .= "$md5Script -root $md5NoPercent $file";
        system("$cmd") && die "ERROR: Failed to generate MD5s in $md5Dir for $ref:\n\t$!\n$cmd\n";

        # We generated MD5, so set the percent path.
        # if -subdirs is specified in MD5_SCRIPT, set the %2s appropriately.
        my $numSubDirs = 2;
        if($md5Script =~ m/-subdirs ([0-9]*)/)
        {
            $numSubDirs = $1;
        }
        $md5Percent = "";
        while($numSubDirs-- > 0)
        {
            $md5Percent .= "/%2s";
        }
        $md5Percent .= "/%s";

        setConf("MD5_DIR", "$md5NoPercent$md5Percent");

        # Write the ref name & timestamp to the info file.
        open($md5InfoFh, '>', $md5Info) || die "Couldn't open $md5Info: $!\n";
        print $md5InfoFh "$md5KeepContents";
        print $md5InfoFh "$ref = ".(stat ($ref))[9]."\n";
        close($md5InfoFh);
    }
    elsif(!$md5Percent)
    {
        # Look in the directory to determine the %.
        my $checkDir = $md5NoPercent;
        while($checkDir)
        {
            opendir(my $dh, $checkDir) || die "ERROR: can't open MD5_DIR: $checkDir: $!\n";
            my @subdirs = grep { (/^[^.]/) && -d "$checkDir/$_" } readdir($dh);
            if(scalar @subdirs > 0)
            {
                # There are subdirs.  Look at the first subdir and determine number of characters.
                $md5Percent .= "/%".length($subdirs[0])."s";
                $checkDir .= "/$subdirs[0]";
            }
            else
            {
                $checkDir = "";
            }
        }
        setConf("MD5_DIR", "$md5NoPercent$md5Percent/%s");
    }
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
