#! /usr/bin/perl -w

use strict;
use warnings;


my $THE_COMMAND="/sbin/iw wlan0 station dump";
my $stationMac="";
my %stationAttributes=();


sub printStationData {
	my $printThis = "";
	my $thisValUnits = "";
	
	my $thisKey = "";
	my $thisVal = "";

	# (we now pass this in along within the hash) $printThis = $printThis . " MAC=" . $thisStationMac;
	foreach my $thisKey (keys %stationAttributes) {
		$thisVal = $stationAttributes{$thisKey};
		$thisValUnits = "";

		# Does the value have a numeric value and non-numeric units specified? 
		if ($thisVal =~ /([0-9\.-]+)([a-zA-Z]+)/  &&  $thisVal !~ /..:..:..:..:..:../)  {
			$thisVal = $1;
			$thisValUnits = $2;
		}

		$printThis = $printThis . " " . $thisKey . "=" . $thisVal;
	
		# append units, if applicable. 
		if ($thisValUnits =~ /.+/) {	
		 	$printThis = $printThis . " " . $thisKey . "Units=" . $thisValUnits;
		}
	}

	print $printThis . "\n";
}


my $stationNum = 0;

open(my $fh, '-|', $THE_COMMAND) or die $!;
my $line;

while (my $line = <$fh>) {
	# print "Parse This: $line\n";

	if ($line =~ m/^Station (..:..:..:..:..:..)/) {
		$stationNum++;
		$stationMac=$1;

		# print "Station mac = $stationMac\n";

		# Print the previous station data
		if ($stationNum > 1 ) {
			# printStationData (\%stationAttributes);
			printStationData ();
			%stationAttributes = ();
		}

		$stationAttributes{'stationMAC'} = $stationMac;
		next;
	}

	# Remove spaces and replace unwanted characters
	$line =~ s/[ \t\n\r]//g;
	$line =~ s/[\/\(\)]//g;

	# Parse and save the key/value parts. 
	my @kvparts=split(/:/,$line);
	my $thisKey = $kvparts[0];
	my $thisValue = $kvparts[1] . "";
	

	$stationAttributes{$thisKey} = $thisValue;

}


printStationData ();

