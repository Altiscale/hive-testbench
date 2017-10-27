#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

# PROTOTYPES
sub dieWithUsage(;$);

# GLOBALS
my $SCRIPT_NAME = basename( __FILE__ );
my $SCRIPT_PATH = dirname( __FILE__ );

# MAIN
dieWithUsage("one or more parameters not defined") unless @ARGV >= 4;
my $suite = shift;
my $scale = shift;
my $settings = shift;
my $streamorder_file = shift;
my $hiveserver_hostport = shift;
dieWithUsage("settings file not found") unless -f $settings;
dieWithUsage("query order file not found") unless -f $streamorder_file;
dieWithUsage("suite name required") unless $suite eq "tpcds" or $suite eq "tpch";

my $HIVE="hive";
my $client = "hive";
if(exists $ENV{HIVE_HOME}) {
 $HIVE="$ENV{HIVE_HOME}/bin/hive";
}
if(defined $hiveserver_hostport ) {
 $HIVE = "beeline";
 $client = "beeline";
}

chdir $SCRIPT_PATH;
mkdir "logs" unless (-d "logs");
my $LOGDIR="logs";
my $queryset_dir;
if( $suite eq 'tpcds' ) {
	$queryset_dir = "sample-queries-tpcds";
} else {
	$queryset_dir = 'sample-queries-tpch';
} # end if
my @queries = glob "$queryset_dir/*.sql";
my %queryset = ();

my $db = { 
	'tpcds' => "tpcds_bin_partitioned_orc_$scale",
	'tpch' => "tpch_flat_orc_$scale"
};

open FILE, ">runSuite-" . $db->{${suite}} . "-" . basename($settings) . ".csv" or die $!;

print "filename,status,time,rows\n";
print FILE "filename,status,time,rows\n";
for my $query ( @queries ) {
        my $number = $1 if($query =~ /(\d+)\.sql/);
	$queryset{$number} = $query;
}

my @streamorder = `cat $streamorder_file`;
for my $query_number ( @streamorder ) {
        chomp $query_number;
	next if($query_number =~ /^#/);
	my $query = $queryset{$query_number};
	next unless defined $query;
	my $logname = "$LOGDIR/$query_number.log";
	my $cmd;
        if($client eq 'beeline') {
           # beeline -u jdbc:hive2://hiveserver-jungledata.s3s.altiscale.com:10000/default -n arun -p arun
	   $cmd = "$HIVE -u jdbc:hive2://${hiveserver_hostport}/$db->{${suite}} -n $ENV{USER} -p $ENV{USER} -i $settings -f $query 2>&1 | tee $logname";
        #   print "$cmd\n";
        }
	elsif($client eq 'hive') {
           $cmd="echo 'use $db->{${suite}}; source $query;' | $HIVE -i $settings 2>&1  | tee $logname";
        }
        
#	my $cmd="cat $query.log";
	#print $cmd ; exit;
	
	my $hiveStart = time();

	my @hiveoutput=`$cmd`;
	my $retcode = $?;
	die "${SCRIPT_NAME}:: ERROR:  hive command unexpectedly exited \$? = '$?', \$! = '$!'" if $?;

	my $hiveEnd = time();
	my $hiveTime = $hiveEnd - $hiveStart;
        my $success = 0;
	foreach my $line ( @hiveoutput ) {
		if ( $client eq 'beeline' ) {
			if( $line =~ /(\d+) rows? selected \(([\d\.]+) seconds\)/ ) {
				print "$query_number,success,$2,$1\n";
				print FILE "$query_number,success,$2,$1\n";
				$success = 1;
			}
		}
		elsif ( $client eq 'hive' ) {
			if( $line =~ /Time taken:\s+([\d\.]+)\s+seconds,\s+Fetched:\s+(\d+)\s+row/ ) {
				print "$query_number,success,$1,$2\n"; 
				print FILE "$query_number,success,$1,$2\n"; 
				$success = 1;
			}
		}
	} # end foreach
	if( ! $success ) {
		print "$query_number,failed,$hiveTime\n"; 
		print FILE "$query_number,failed,$hiveTime\n"; 
        }
} # end for

close FILE;


sub dieWithUsage(;$) {
	my $err = shift || '';
	if( $err ne '' ) {
		chomp $err;
		$err = "ERROR: $err\n\n";
	} # end if

	print STDERR <<USAGE;
${err}Usage:
	perl ${SCRIPT_NAME} [tpcds|tpch] [scale] [settings-file] [stream-order] [hiveserver:port]

Description:
	This script runs the sample queries and outputs a CSV file of the time it took each query to run.  Also, all hive output is kept as a log file named 'queryXX.sql.log' for each query file of the form 'queryXX.sql'. Defaults to scale of 2.
USAGE
	exit 1;
}

