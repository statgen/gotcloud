###################################################################
#
# Name: Conf.pm
#
# ChangeLog:
#   $Log: Conf.pm,v $
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

Configuration settings have the following precedence:
    1) array of strings containing key=value settings
    2) array of config files
    2a) precedence of config files is the order they are
        specified with the first file having highest precedence
        and the last file having lowest precedence (the defaults)
If a value is set in multiple places, the highest precedence
value is used.

Note: To preserve precedence, the files/settings are actually
      processed in reverse order.  Therefore, if a value is set
      in multiple places, the last value is used.

Configuration files consists of sections of key=value lines.
A section is defined by a line of the form [section_name].
All key=value lines belong to the last section defined.
The key may only contain the letters matching Perl's regexp \w
The default (e.g. top) section is named 'global'.

An example configuration file might looks like:
      a=B
      b=$(a).top
      [green]
      b=N
      c=$(a).top
      d=$(b).more
      [red]
      a=D
      c=$(a).top
      e=$(d).less

Defines three sections, global, green and red.

After all conf files are read we substitute for anything of the
form $(varname). The variable (varname) may come from the
current section or from global, and not from another section.
In the configuration example above, the final values will be:

      a=B
      b=B.top
      [green]
      b=N
      c=B.top        # Value for $(a) from global
      d=N.more
      [red]
      a=D
      c=D.top        # Value for $(a) from red, not global
      e=.less        # Fails with warning that $(d) not defined in 'red'

TODO List:
    Provide methods for
        $sectionref = GetSections()     # List of keys in %CONF_HASH
        SetConfInSection(section, key, value)       # Set value for key in a section
        $value = GetConfInSection(section, key)     # Return value for key in a section

=cut

our %CONF_HASH = ();                # Configuration values (hash of hashes)
#
#   VERBOSE settings:
#       0       nothing shown
#       >=1     processing activity shown
#       >1      Die just does warn and returns ''  (for testing)
#       >=3     config entries before and after substitutions written to STDERR (not warn)
#       >3      parse of key=value shown
#       
my $VERBOSE = 0;

#==================================================================

=head1 NAME

 #=============================================
 #  errs = loadConf ( confSettings, configFiles, verbose )
 #=============================================

=head1 DESCRIPTION

    Reads all the possible configuration files, extracting
    key=value data.  Will not return on errors

    confSettings is an array of strings that contain
    configuration settings as would be read out of a config
    file.  These settings take precedence over anything
    set in the config files.  configFiles contains a space
    delimited list of configuration files with the first file
    having the highest precedence (with the last file being
    the default configuration).

    Set verbose to true to see more informational messages.

    Returns the number of errors detected

=head1 USAGE

    if (loadConf(/@configSettings, 'test.conf default.conf', $opts{verbose})) {
        die "Failed to read configuration files\n";
    }

=cut

sub loadConf {
    my ($settingsRef, $configsRef, $v) = @_;
    if (defined($v) && $v) { $VERBOSE = $v; }

    if ($VERBOSE) { warn "Processing configuration files:\n"; }
    my $errs = 0;
    # Process $configs in reverse order.
    for (my $i=$#$configsRef; $i>=0; $i--) {
        if ($VERBOSE) { warn "  Config: $configsRef->[$i]\n"; }
        $errs += ReadConfig($configsRef->[$i]);
    }

    # Process the string settings in reverse order.
    if ($VERBOSE) { warn "  Config: Strings from caller\n"; }
    for (my $i=$#$settingsRef; $i>=0; $i--) {
        if (parseKeyVal($settingsRef->[$i])) {
            warn "Failed: Unable to parse configuration setting:\n  $settingsRef->[$i]\n";
            $errs++;
        }
    }

    if ($VERBOSE > 3) {
        foreach my $sec (sort keys %CONF_HASH) {
            print STDERR "Before substitution:  Section=$sec\n";
            foreach my $k (sort keys %{$CONF_HASH{$sec}}) { print STDERR "  $k=$CONF_HASH{$sec}{$k}\n"; }
        }
    }

    return $errs;
}

#==================================================================

=head1 NAME

 #=============================================
 #  dumpConf ( outputFile )
 #=============================================

=head1 DESCRIPTION

    Write all of the configuration settings to the specified
    output file or stderr (if no file is specified).

    Returns the number of errors detected

=head1 USAGE

    dumpConf();
    dumpConf("/home/mktrost/output/align.conf");

=cut

sub dumpConf
{
    my ($outputFile) = @_;

    # first check that the file does not already exist.
    if(-e $outputFile)
    {
        warn "$outputFile already exists, so not dumping configuration\n";
        return;
    }
    open(OUT,"> ".($outputFile || '-')) || die "Cannot open $outputFile for writing.  $!\n";

    # first print out the global section.
    my $defaultSection = 'global';
    foreach my $key (keys %{$CONF_HASH{$defaultSection}})
    {
        print OUT "$key = $CONF_HASH{$defaultSection}{$key}\n";
    }
    # Print out the rest of the sections.
    foreach my $section (keys %CONF_HASH)
    {
        next if($section eq $defaultSection);
        foreach my $key (keys %{$CONF_HASH{$section}})
        {
            print OUT "$key = $CONF_HASH{$section}{$key}\n";
        }
    }
    if((defined($outputFile)) && $outputFile eq '')
    {
        close(OUT);
    }

}

#==================================================================

=head1 NAME

 #=============================================
 #  setConf ( key, value )
 #=============================================

=head1 DESCRIPTION

    Sets a value in a global hash.
    Key may be a simple varname in which case the section will be 'global'.
    If the key is of the form name/keyname, then we set the variable
    'keyname' in the section 'name'.

    No substitution is done for variables in value.

=head1 USAGE

    setConf('FASTQ_PREFIX', '');
    setConf('MAP_TYPE', 'BWA');
    setConf('BWA/THREADS', 3);

=cut

sub setConf {
    my ($key, $value) = @_;
    if ($key =~ /^(\w+)\/(.+)/) {
        $CONF_HASH{$1}{$2} = $value;
        return;
    }
    $CONF_HASH{global}{$key} = $value;
}

#==================================================================

=head1 NAME

 #=============================================
 #  value = getConf ( key[, required] )
 #=============================================

=head1 DESCRIPTION

    Gets a value for a key in some section of the global hash.
    If required is not TRUE and the key does not exist, return ''
    otherwise fail.

    Key may be a simple varname in which case the section will be 'global'.
    If the key is of the form name/keyname, then we return the value of the
    variable 'keyname' in the section 'name'.

=head1 USAGE

    $fpfx = getConf('FASTQ_PREFIX');
    $type = getConf('MAP_TYPE', 1);
    $threads = getConf('BWA/THREADS';

=cut

sub getConf {
    my ($key, $required) = @_;
    if (! defined($required)) { $required = 0; }

    my $section = 'global';
    if ($key =~ /^(\w+)\/(.+)/) { ($key, $section) = ($1, $2); }

    if (! defined($CONF_HASH{$section}{$key})) {
        if (! $required) { return ''; }
        warn "Failed: Required configuration key '$key' in section '$section' not found in the configuration files\n";
        if ($VERBOSE > 1) { return ''; }        # Sometimes do not die (for testing)
        exit(7);
    }

    #   Resolve sub-variables of the form $(varname)
    my $val = $CONF_HASH{$section}{$key};
    for (1 .. 50) {             # Avoid any chance of forever looops
        if ($val !~ /^(.*)\$\((\w+)\)(.*)$/) { last; }
        my ($pre, $var, $post) = ($1, $2, $3);
        if (exists($CONF_HASH{$section}{$var})) {
            $val = $pre . $CONF_HASH{$section}{$var} . $post;
            next;
        }
        if (exists($CONF_HASH{global}{$var})) {
            $val = $pre . $CONF_HASH{global}{$var} . $post;
            next;
        }
        my $s = "'$section'";
        if ($section ne 'global') { $s .= " or in 'global'"; }
        warn "Config variable '$var' is not defined in section $s." .
        "   Line=$CONF_HASH{$section}{$key}\n";
        $errs++;
        $val = $pre . '_NOT_DEFINED_' . $post;
    }

    return $val;
}

#==================================================================
#  Local functions
#==================================================================

#==================================================================
#  errs = ReadConfig ($file)
#    Uses global config area %CONF_HASH
#
#  Returns:  number of errors detected
#==================================================================
sub ReadConfig {
    my $file = shift;
    my $section = 'global';             # Default section
    my $errs = 0;

    if (! open(IN, $file)) {
        warn "Failed: Unable to open config file '$file': $!\n";
        return 1;
    }
    while (<IN>) {
        next if (/^#/ );                # Ignore comments
        next if (/^\s*$/);              # Ignore blank lines
        s/\s+#.*$//;                    # Remove in-line comments
        #   Sections look like [ name ]
        if (/^\[\s*(\w+)\s*\]\s*$/ ) {
            $section = $1;
            next;
        }
        #   Rest looks like  key=value
        if(parseKeyVal($_, $section) != 0)
        {
            warn "Failed: Unable to parse config line \n" .
                "  File='$file', line number=" . ($.+1) . "\n" .
                "  Line=$_";
            $errs++;
            next;
        }
    }
    close(IN);
    return $errs;
}

#==================================================================
#   errs = parseKeyVal ($line, $section)
#       Uses global config area %CONF_HASH
#       $section defaults to 'global' 
#
#   Returns:  number of errors detected
#==================================================================
sub parseKeyVal {
    my ($line, $section) = @_;
    if(!defined($section)) {$section = 'global';}

    if ($line !~ /^\s*(\w+)\s*=\s*(.*?)\s*$/ )
    {
        # failed to parse.
        return 1;
    }
    my ($key,$val) = ($1,$2);
    if ( ! defined($val) ) { $val = ''; }  # Undefined is null string
    $CONF_HASH{$section}{$key} = $val;
    if($VERBOSE > 3) { warn "    $section:$key = $val\n";
    }
    return 0;  # Success
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
