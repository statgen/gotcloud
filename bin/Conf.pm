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

The environment variable CONF_PATH (colon-delimited path of directories)
may be set to specify a list of directories containing *.conf files.
If this is not set, it is assumed to be $HOME/.config/gotcloud/.
This means if you set CONF_PATH you may want to also include 
the one in your $HOME.

Configuration files are read in this order:
    1) As provided by loadConf (i.e. gotcloud/bin/somename.conf)
    2) foreach dir in CONF_PATH, read $dir/*.conf

If a value is set in multiple places, the last one is used.

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

=cut

our %CONF_HASH = ();                # Configuration values (hash of hashes)
my $DEFAULT_CONF = $ENV{HOME} . '/.config/gotcloud/';  # User default conf files here
my $VERBOSE = 0;
 
#==================================================================

=head1 NAME

 #=============================================
 #  errs = loadConf ( defaultconfig, verbose )
 #=============================================

=head1 DESCRIPTION

    Reads all the possible configuration files, extracting
    key=value data.  Will not return on errors

    You must provide the path to the default config file
    (defaultconfig). This file is always read.
    
    Set verbose to true to see more informational messages.

    If the environment variable CONF_PATH is set, it must
    be a colon-delimited list of directories to be
    searched for conf files (*.conf)   

    Returns the number of errors detected

=cut

sub loadConf {
    my $conf = shift;
    my $v = shift;
    if (defined($v) && $v) { $VERBOSE = 1; }

    %CONF_HASH = ();                  # Always read defaults
    my $errs = ReadConfig ($conf);

    #   If CONF_PATH set, use this for all conf files
    #   If not, just read user config files
    my @dirlist = ();
    if (! exists($ENV{CONF_PATH})) { push @dirlist, $DEFAULT_CONF; }
    else { @dirlist = split(':', $ENV{CONF_PATH}); }
    foreach my $p (@dirlist) {
        if (! opendir(INDIR, $p)) {
            if ($p ne $DEFAULT_CONF) {  # Only warn when not user conf files
                warn "Failed to read configuration directory '$p'. Continuing. Error=$!\n";
                $errs++;
            }
            next;
        }
        while (readdir INDIR) {
            if (! /^(\w+)\.conf$/) { next; }
            $errs += ReadConfig ("$p/$_");
        }
        closedir INDIR;
    }

    #   Resolve all variables of the form $(varname)
    foreach my $section (keys %CONF_HASH) {
        foreach my $key (keys $CONF_HASH{$section}) {
            for (1 .. 10) {             # Avoid any chance of forever looops
                if ($CONF_HASH{$section}{$key} !~ /^(.*)\$\((\w+)\)(.*)$/) { next; }
                my ($pre, $var, $post) = ($1, $2, $3);
                if (exists($CONF_HASH{$section}{$var})) {
                     $CONF_HASH{$section}{$key} = $pre . $CONF_HASH{$section}{$var} . $post;
                    next;
                }
                if (exists($CONF_HASH{global}{$var})) {
                    $CONF_HASH{$section}{$key} = $pre . $CONF_HASH{global}{$var} . $post;
                    next;
                }
                my $s = "'$section'";
                if ($section ne 'global') { $s .= " or in 'global'"; }
                warn "Config variable '$var' is not defined in section $s." .
                    "   Line=$CONF_HASH{$section}{$key}\n";
                $errs++;
                $CONF_HASH{$section}{$key} = $pre . '_NOT_DEFINED_' . $post;
            }
        }
    }
    return $errs;
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
 #  value = getConf ( key, required )
 #=============================================

=head1 DESCRIPTION

    Gets a value for a key in some section of the global hash.
    If required is not TRUE and the key does not exist, return ''
    otherwise fail.

    Key may be a simple varname in which case the section will be 'global'.
    If the key is of the form name/keyname, then we return the value of the
    variable 'keyname' in the section 'name'.

=cut

sub getConf {
    my ($key, $required) = @_;
    if (! defined($required)) { $required = 0; }

    my $section = 'global';
    if ($key =~ /^(\w+)\/(.+)/) { ($key, $section) = ($1, $2); }

    if (! defined($CONF_HASH{$section}{$key})) {
        if (! $required) { return ''; }
        die "Failed: Required configuration key '$key' in section '$section' not found in the configuration files\n";
    }
    return $CONF_HASH{$section}{$key};
}

#==================================================================
#  Local functions
#==================================================================

#==================================================================
#  DieOrWarn ($flag, $msg)
#    Generates a warning and then stops if flag is true
#
#==================================================================
sub DieOrWarn {
    my $dieornot = shift;
    my $msg = shift;
    if ($dieornot) { die $msg; }
    warn $msg;
}

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
    if ($VERBOSE) { warn "Reading config file '$file'\n"; }
    while (<IN>) {
        next if (/^#/ );                # Ignore comments
        next if (/^\s*$/);              # Ignore blank lines
        s/#.*$//;                        # Remove in-line comments
        #   Sections look like [ name ]
        if (/^\[\s*(\w+)\s*\]\s*$/ ) {
            $section = $1;
            next;
        }
        #   Rest looks like  key=value
        if (! /^\s*(\w+)\s*=\s*(.*)\s*$/ ) {
            warn "Failed: Unable to parse config line \n" .
                "  File='$file', line number=" . ($.+1) . "\n" .
                "  Line=$_";
            $errs++;
            next;
        }
        my ($key,$val) = ($1,$2);
        if ( ! defined($val) ) { $val = ''; }    # Undefined is null string
        $CONF_HASH{$section}{$key} = $val;
    }
    close(IN);
    return $errs;
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
