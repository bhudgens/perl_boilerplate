#! /usr/bin/perl
#############################################################################################
## Author: 	Benjamin Hudgens
## Date:	September 27, 2014
##
## Description:
##		Boilerplate Perl Script to Quickstart new scripts
#############################################################################################

use Common::Standard;

# Cleanly handle kill signal and shutdowns
$SIG{'TERM'}	= \&shutdown;

# Default file to save all our settings (generate below)
my $configDir	= $ENV{'HOME'}; #Usually /etc/srr
my $configFile	= "$configDir/" . '.script.json'; # Change this to something relevant

# Command line options
my $opts		= {};  # Always your command line args
my $config		= {};

# Do not store other script settings in the script - save them to config

#############################################################################################
# DEBUG MESSAGES
#############################################################################################
# Turn on Debug Statements:
# &setDebugLevel($level);
#
# Enable Time Stamps in Debug Statements
# &setDebugEnableTimeStamp(1 or 0);
#
# Push Debug Statements to a Log File Instead
# &setDebugLogFile($file);
#
# Debug statements should follow this pattern
#
# 1-8           - Main Prog
# 9             - Raw Command Line / Raw SQL
# 11-18         - Subroutines
# 19            - Raw Command line / Raw SQL Nested in Subroutine
# 100-200       - External API's
#
# Should start at the lowest number and increase as you further nest into the code
#
# Example:
#
# &debug(1,"starting main");
# while (1)
#    &debug(2,"In loop");
#    if ($something)
#    {
#       &debug(3,"Even more nested with more detail")
#    }
#############################################################################################

sub main
{

    &initialize();

    # readConfig works funky due to how XML works.  Each element ALWAYS is read as an array
    # this means you can always count on $c->{'server'}[0] even if there is only one ELEMENT

    foreach my $server (@{$config->{'servers'}})
    {
        my $name	= $server->{'name'}[0];
        my $address	= $server->{'address'}[0];

        &say("Details about server:");
        &say("  Name: $name");
        &say("	Address: $address");
    }
}

sub usage
{
    &say ("						                        	");
    &say ("Sample Script 		                         	");
    &say ("Copyright (C) 2014 BDHC, Inc	               		");
    &say ("-------------------------------------------------");
    &say ("					                           		");
    &say ("Usage:					                      	");
    &say ("$0 -m mandatory [-o optional]	           		");
    &say ("						                            ");
    &say (" -m long description of optional	        		");
    &say (" -o brackets around optional options	        	");
    &say (" -o optional options have defaults       		");
    &say (" -o This is output file [/etc/ouput]	        	");
    &say ("						                           	");
}

sub generateConfig
{

    say("Generating Configuration Files...");

    if (-f $configFile)
    {
        &sError("Config File Exists - Not overwriting: $configFile");
        return(undef);
    }

    # Create a sample data structure here
    # which will make configuring various scripts really easy later
    my $config								= {};

    $config->{'sections'}[0]->{'section'}->{'name'}	= 'www1';
    $config->{'sections'}[1]->{'section'}->{'name'}	= 'www2';
    $config->{'arrays'}                             = ["This","Is","A","list"];
    $config->{'options'}->{'example'}	      		= 'value';

    if (!-d $configDir)
    {
        `mkdir -p $configDir`;
        if (!-d $configDir) { &hError("Failed to create dir: [$configDir]") };
    }

    &saveConfig($configFile,$config);

}

sub shutdown
{
    # We get called even if we are sent a kill()
    # Make sure to clean up 'anything' we are doing
    # We can get called at any time
    # Keep track of open files and various other things so they can get cleaned up

    exit(0);
}

sub initialize
{
    # Some standard opts
    # -d debug level
    # -g generate a config file
    # -h help summary
    # -c config file (default: /etc/srr/<myname>)

    $opts = &getCommandLineOptions('hd:gc:'); # colon means takes argument / just letter is Boolean

    if (!$opts)   # We had an error
    {
        &usage();
        exit(0);
    }

    if ($opts->{'h'})
    {
        &usage();
        &shutdown();
    }

    if ($opts->{'d'})
    {
        &setDebugLevel($opts->{'d'});
        &debug(1,"Debug Level Set: $opts->{'d'}");
    }

    if ($opts->{'c'})
    {
        $configFile	= $opts->{'c'};
    }

    if ($opts->{'g'})
    {
        &generateConfig();
        &shutdown();
    }

    if (-f $configFile)
    {
        $config	= &readConfig($configFile);
    }
    else
    {
        &hError("Couldn't find config file $configFile");
    }

}

&main();
exit(0);
