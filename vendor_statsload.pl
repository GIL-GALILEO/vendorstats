#!/usr/local/bin/perl
#################################################################
#  program: vendor_statsload.pl
#   author: Mike Thomas
#     date: 05/29/03
# modified: 06/06/03
# function: loads the monthly data that is provided by the various
#           vendors into our monthly stats record format.
#   change: 09/24/03
#           started adding proquest_stats_build subroutine
#           11/13/03
#           changed data procedure for Ebsco section
#           new data directory changed
#           11/14/03
#           added "orphan" file write routine to find new ProQuest
#           codes and databases
#           11/20/03
#           change DB code file seperator to ## to allow commas
#           in the titles of the databases
#           09/29/04
#           changed the usage message
#           01/06/05
#           changed EBSCO section to ensure the institution codes
#           contain strings that have a-z or A-Z in them. This was 
#           due to sometime the ^M is in Field 5 or 6.
#           01/07/05
#           modified Britannica section to accommodate new data
#           format.
#           02/09/05
#           modified EBSCO to write to an orphan file and entry
#           that does not have a institution code.
#			04/20/06
#			modifying proquest to accommodate changes to the data
#			file as of 01/06 see line 425 
#			04/21/06
#			modified britannica to accommodate changes to the data
#           file 
#			10/10/06
#			modified the EBSCO routine to accommodate changes to
#			the data file
#			04/20/07
#			modified the Britannica routine to accommodate new 
#			databases
#			05/08/07
#			modified the ProQuest routine to accommodate the new
#			ZUHQ file and data
#			07/13/07
#			added subroutine for SIRS data
#			02/06/08
#			fixed EBSCO to add all titles.
#           02/20/08
#           fix Lexis to eliminiate embeded commas in totals. 
#			03/25/08
#			adding firstsearch section	
#           07/23/09
#           making SIRS index more robust adding various
#           title that they use
#           05/06/11
#           Adding new section for new format of ProQuest data reports.
#           01/15/13
#           add new logic and key for Lexis Nexis stats
#           starting 12/2012
#           09/09/13
#           combining inst IDs for campus consolidations in EBSCO
#           ProQuest and FirstSearch and new or changed institutions
#           10/11/13
#           Changes for Britannica "new" data format
#           07/18/14
#           Changes in EBSCO in adapt to the new EDS and eHost 
#           data
#           10/15/15
#           Added section for ebrary
#           02/10/16
#           Added section for LearningExpress
#           10/04/16
#           Added TumbleBooks
#           08/30/2017
#           Added Mango
#           09/07/2017
#           Added Gale LegalForms
#           09/13/2017
#           Added TumbleCloud
#           09/19/2017
#           Modified Ebsco for new file format
#################################################################
use strict;
use warnings;

use Getopt::Std;
my $textfile_build = "no";
my $ebsco_debug = "no";
my $data_dir = "/ss/dbs/stats/";
my $today = `date '+%Y%m%d'`;
my $makebak_dir = "/usr/local/lag/bin/";
my $makebak = $makebak_dir."makebak";
chomp($today);
my $backup_file="";
use vars qw($opt_e $opt_p $opt_l $opt_b $opt_s $opt_f $opt_n $opt_y $opt_x $opt_c $opt_t $opt_o $opt_g $opt_u $opt_z);

use lib 'perlib';
use Text::CSV_PP;

#################################################################
# subroutine:
#
#################################################################

#---------------------------------------------------------------------
{ my $csv;
sub csv_split {
    my( $in ) = @_;

    $csv = Text::CSV_PP->new( { binary => 1 } ) unless $csv;
    $csv->parse( $in ) or die( "Can't parse line: ($in)".$csv->error_diag() );
    $csv->fields();  # returned
}}

#################################################################
# subroutine: get_options
#             displays a usage message if vendor_statload.pl is
#             ran with the correct options.
#################################################################
sub get_options {
	getopts('bcefglnopstuxyz'); 
	unless($opt_e || $opt_p || $opt_l || $opt_b || $opt_s || $opt_f || $opt_y || $opt_x || $opt_c || $opt_t || $opt_o || $opt_g || $opt_u || $opt_z) {
		print
		"Usage: vendor_statsload.pl -bcefglnopstxyz [-n]               \n",
		"Where:     -b  collect stats from Britannica.           \n",
		"           -c  collect stats from Films On Demand.      \n",
		"           -e  collect stats from EBSCO.                \n",
		"           -f  collect stats from FirstSearch.          \n",
		"           -g  collect stats from Gale LegalForms.      \n",
		"           -l  collect stats from Lexis-Nexis.          \n",
		"           -o  collect stats from Mango.                \n",
		"           -p  collect stats from ProQuest.             \n",
		"           -s  collect stats from SIRS.                 \n",
		"           -t  collect stats from TumbleBooks.          \n",
		"           -u  collect stats from TumbleCloud.          \n",
		"           -y  collect stats from Ebrary/Ebook Central  \n",
		"           -x  collect stats from Learning Express.     \n",
		"           -z  Used in testing new subroutines.         \n",
		"           -n  No backups used with above options       \n";

	} #end unless
} #end get_options

##################################################################
# Subroutine numeric checks
##################################################################

sub is_integer {
   defined $_[0] && $_[0] =~ /^[+-]?\d+$/;
}

sub is_float {
   defined $_[0] && $_[0] =~ /^[+-]?\d+(\.\d+)?$/;
}

#################################################################
# subroutine: ebsco_stats_build
#             new EBSCO stats report routine.
#################################################################
sub ebsco_stats_build {
	$backup_file="";
	my $temp_searches_file = $data_dir."stats/temp_stats_monthly_ebsco_search_data";
	my $temp_citation_file = $data_dir."stats/temp_stats_monthly_ebsco_citation_data";
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_ebsco_fulltext_data";
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_ebsco_sessions_data";
	my $searches_file = $data_dir."stats/stats_monthly_ebsco_search_data_new_format_temp";
	my $citation_file = $data_dir."stats/stats_monthly_ebsco_citation_data_new_format_temp";
	my $fulltext_file = $data_dir."stats/stats_monthly_ebsco_fulltext_data_new_format_temp";
	my $sessions_file = $data_dir."stats/stats_monthly_ebsco_sessions_data_new_format_temp";
	my $debug_file = $data_dir."stats/EBSCO_debug.txt";
	
	my ($date,$line,$out_line,$out_line_head,$out_line_tail,
		$inst_code,$zip_file,$file_name,$db_code,$profile,$last_inst)="";
	my ($searches_total,$citation_total,$fulltext_total,$size,$inst_defined,$searches_count,$fulltext_count,$citation_count,$temp_sessions_total,$sessions_total,$temp_searches_total,$sessions_count)=0;
	my $db_file = $data_dir."/stats/EBSCO_dbs.txt";
	my $eds_academic = $data_dir."stats/EBSCO_EDS_Academic.txt";
	my $eds_gpls_k12_priv12 = $data_dir."stats/EBSCO_EDS_GPLS_K12_Privk12.txt";
	my $ebsco_profiles = $data_dir."stats/EBSCO_EDS_Profiles.txt";
	my $ehost_inst_data = $data_dir."stats/EBSCO_inst_combined.txt";

	my @vars=();
	my @fields=();
	my @values=();
	my %ebsco_titles=();
	my $past_top=0;

	open(INFILE,"$db_file");
	### barcket check
	while(<INFILE>){
	  $line=$_;
	  @fields = csv_split( $line );
      #@fields = split /,/,$line;   
	  $fields[0] =~ tr/[a-z]/[A-Z]/;
      #$fields[1] =~ s/"//g;
	  $fields[1] =~ s/ //g;
	  $fields[1] =~ tr/[a-z]/[A-Z]/;
	  chomp($fields[0]);
	  chomp($fields[1]);
	  $ebsco_titles{$fields[1]}=$fields[0];
	} #end while to read in db code and name
	### bracket check OK

	@fields=();	

	my %db_names = ();
	my %eds_keys = ();
	my %ebsco_profiles = ();
	my %ehost_keys = ();

	open(EHOSTINST,"$ehost_inst_data");	

	### bracket Check
	while(<EHOSTINST>){
		$line=$_;
	    @fields = csv_split( $line );
        #@fields = split /,/,$line;   
		$fields[0] =~ tr/[a-z]/[A-Z]/;
		$fields[1] =~ s/ //g;
		$fields[1] =~ tr/[a-z]/[A-Z]/;
		chomp($fields[0]);
		chomp($fields[1]);
		$ehost_keys{$fields[1]}=$fields[0];
	}#end while reading lines from files
	### bracket check OK
	close(EHOSTINST);

  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/ebsco_stats";	
	my @data_files = <$raw_data_dir/*>;

	#??#foreach my $var(@data_files){
	#??#	print"datafile=$var\n";
	#??#} #end foreach 
	#??#exit;	

	#####  Make back-ups  #####
	if ((-e $searches_file) && (!($opt_n))) {
		system("$makebak","$searches_file");
	}
	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	}
	if ((-e $citation_file) && (!($opt_n))) {
		system("$makebak","$citation_file");
	}
	if ((-e $sessions_file) && (!($opt_n))) {
		system("$makebak","$sessions_file");
	}
	#??# exit;
	open(EBSCOPROFILES,"$ebsco_profiles");
	while(<EBSCOPROFILES>){ 
		$line=$_;
	    @fields = csv_split( $line );
        #@fields = split /,/,$line;   
		$fields[0] =~ tr/[a-z]/[A-Z]/;
        #$fields[0] =~ s/"//g;
		$fields[0] =~ s/ //g;
        #$fields[1] =~ s/"//g;
		$fields[1] =~ s/ //g;
		$fields[1] =~ tr/[a-z]/[A-Z]/;
		chomp($fields[0]);
		chomp($fields[1]);
		#??#print"fields[0]=$fields[0]\nfields[1]=$fields[1]\n";
		$ebsco_profiles{$fields[0]}=$fields[1];
	}#end while reading lines from files
	close(EBSCOPROFILES);
	#??#exit;
	open(SEARCHES,">$temp_searches_file");
	open(SESSIONS,">$temp_sessions_file");
	open(CITATION,">$temp_citation_file");
	open(FULLTEXT,">$temp_fulltext_file");
	open(DEBUG,">$debug_file");

	foreach my $file(@data_files) {
		$past_top=0;
		$file_name = $file;
		$file_name =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/ebsco_stats\///;
		print "loading $file_name\n";
		if ($file_name =~ /EDS_/){
			$date = $file_name;
			$date =~ s/EDS_Academic_//;
			$date =~ s/EDS_GPLS_K12_Privk12_//;
			$date =~ s/.csv//;
			$date =~ s/.CSV//;
			#??#print "date=$date\n";
			open(INFILE,"$file");

			if ($file_name =~ /Academic/){
				open(EDSDBFILE,"$eds_academic");
				print"opening $eds_academic\n";
			} elsif ($file_name =~ /GPLS/){
				open(EDSDBFILE,"$eds_gpls_k12_priv12");
				print"opening $eds_gpls_k12_priv12\n";
			}#end if

			%eds_keys=();

			while(<EDSDBFILE>){
				$line=$_;
	            @fields = csv_split( $line );
                #@fields = split /,/,$line;   
				$fields[0] =~ tr/[a-z]/[A-Z]/;
				$fields[1] =~ s/ //g;
				$fields[1] =~ tr/[a-z]/[A-Z]/;
				chomp($fields[0]);
				chomp($fields[1]);
				$eds_keys{$fields[1]}=$fields[0];
			}#end while reading lines from files

			@fields=();	
			close(EDSDBFILE);
			### bracket check
			while(<INFILE>){
				$line=$_;
				#??#print"past_top=$past_top\n";
			if($past_top){
				#??#print"past_top=$past_top\n";
                #if($line =~ /",/){
					$line =~ s/ //g;
					$line =~ tr/[a-z]/[A-Z]/;
	                @fields = csv_split( $line );
					@values = @fields[ 9 ..$#fields ];  # historical reasons
                #} #end if

				### bracket check
				if($eds_keys{$fields[0]}){
					$inst_code = $eds_keys{$fields[0]};
					#if($last_inst eq ""){
					#	$last_inst=$inst_code;
					#} #end if 
					$out_line_head = "m".$date." ".$inst_code." E ";
					#??#print"out_line_head=$out_line_head\n";
					if(($ebsco_profiles{$fields[3]}) && 
					   ($values[0]>0)){
						$profile = $ebsco_profiles{$fields[3]};

						$sessions_count = $values[0];
						$out_line_tail = "A " . $profile . " " .$sessions_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
						#??#print "out_line=$out_line\n";
						if (($inst_code ne "PUBL") && ($profile ne "ZBDS")){
							print SESSIONS $out_line;
						} #end if
					} #end if
					if(($ebsco_profiles{$fields[3]}) && 
					   ($values[1]>0)){
						$profile = $ebsco_profiles{$fields[3]};
						$searches_count = $values[1];
						$out_line_tail = "S " . $profile . " ".$searches_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
						#??#print"out_line=$out_line\n";
						if (($inst_code ne "PUBL") && ($profile ne "ZBDS")){
							print SEARCHES $out_line;
						} #end if
					} #end if
					if(!($ebsco_profiles{$fields[3]}) && 
					   ($values[0]>0) && ($fields[3] !~ /(EHOST)/)){
						$sessions_count = $values[0];
						$out_line_tail = "A ZBDS " .$sessions_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
						#??#print "out_line=$out_line\n";
						print SESSIONS $out_line;
					} #end if
					if(!($ebsco_profiles{$fields[3]}) && 
					   ($values[1]>0) && ($fields[3] !~ /(EHOST)/)){
						$searches_count = $values[1];
						$out_line_tail = "S ZBDS ".$searches_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
						#??#print"out_line=$out_line\n";
						print SEARCHES $out_line;
					} #end if
				$last_inst=$inst_code;	
				$sessions_count=0;
				$searches_count=0;
				}#end if	
				### bracket check OK
			} elsif ($line =~ /Customer ID/){
				$past_top=1;
			} #end if past top
			} #end while lines of data in file to process
			### bracket check OK	

		} elsif ($file_name =~ /eHost/){
			$date = $file_name;
			$date =~ s/eHost_Full-Text_Citations_//;
			$date =~ s/eHost_Searches_Sessions_//;
			$date =~ s/.csv//;
			$date =~ s/.CSV//;
			$past_top=0;
			print"opening $file_name\n";
			open(INFILE,"$file");

			while(<INFILE>) {
				$line = $_;
				$inst_defined=0;
				$inst_code="";
				$db_code="";
			if ($past_top) {

				$line =~ s/ //g;
				$line =~ tr/[a-z]/[A-Z]/;
				@fields = csv_split( $line );

				if ( $file_name =~ /eHost_Searches/ ) {
					$db_code = $ebsco_titles{ $fields[4] };
					@values = @fields[ 9 .. $#fields ];  # historical reasons
				}
				else {
					$db_code = $ebsco_titles{ $fields[2] };
					@values = @fields[ 7 .. $#fields ];  # historical reasons
				}

				$inst_code = $ehost_keys{ $fields[0] };
				if( $inst_code && $file_name =~ /eHost_Searches/ ) {

					$out_line_head = "m$date $inst_code E ";

					if( $fields[3] =~ /\((ehost|novplus|novpk8|plus)\)/i  # profiles to match (ehost) (novplus) (novpk8) (plus)
					&& $db_code ) {                            # recognized dbs

						if( $values[0] > 0 ) {
							$sessions_count = $values[0];
							$out_line_tail = "A $db_code $sessions_count\n";
							$out_line = $out_line_head . $out_line_tail;
							print SESSIONS $out_line;
						}

						if( $values[1] > 0 ) {
							$searches_count = $values[1];
							$out_line_tail = "S $db_code $searches_count\n";
							$out_line = $out_line_head . $out_line_tail;
							print SEARCHES $out_line;
						}

					}

					# note: we're inside a block where $ehost_keys{$fields[0]} is true
					# therefore the following two blocks are (should be) noops
					# when I have good tests, I'll remove them bmb 20181128
					# that means I may never remove them, but I'm hopeful

					if(!($ehost_keys{$fields[0]}) 
					 &&  ($values[0]>0) && (!($ebsco_titles{$fields[4]}))
					 && ($fields[3] =~ /(EHOST)/)){
						$sessions_count = $values[0];
						$out_line_tail = "A ZBDS " .$sessions_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
						#??#print "out_line=$out_line\n";
						print SESSIONS $out_line;
					} #end if

					if(!($ehost_keys{$fields[0]})
					 && ($values[1]>0) && (!($ebsco_titles{$fields[4]}))
					 && ($fields[3] =~ /(EHOST)/)){
						$searches_count = $values[1];
						$out_line_tail = "S ZBDS ".$searches_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
						#??#print"out_line=$out_line\n";
						print SEARCHES $out_line;
					} #end if

				$sessions_count=0;
				$searches_count=0;
				}
				elsif($file_name =~ /eHost_Full/){
					if ($ehost_keys{$fields[0]}){
						$inst_code = $ehost_keys{$fields[0]};
						$out_line_head = "m".$date." ".$inst_code." E ";
						#??#print"inst_code=$inst_code\n";
					} #end if
					if (($ehost_keys{$fields[0]}) && ($ebsco_titles{$fields[2]}) 
						&& ($values[3]>0)){
						$fulltext_count = $values[3];
						$out_line_tail = "F " . $db_code . " " .$fulltext_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
				 		#??#print "out_line=$out_line\n";
						print FULLTEXT $out_line;
					} #end if
					if(($ehost_keys{$fields[0]}) && ($ebsco_titles{$fields[2]})
						&& ($values[5]>0)){
						$citation_count = $values[5];
						$out_line_tail = "D " . $db_code . " ".$citation_count ."\n";
						$out_line = $out_line_head . $out_line_tail;
						#??#print"out_line=$out_line\n";
						print CITATION $out_line;
					} #end if
				}#end if 
				$fulltext_count=0;
				$citation_count=0;
				### bracket check OK
			} elsif ($line =~ /Customer ID/){
				$past_top=1;
			} #end if
		} #end while
		$sessions_total=0;
		$searches_total=0;
		$fulltext_total=0;
		$citation_total=0;
		`sort -o $temp_sessions_file $temp_sessions_file`;		
		`sort -o $temp_searches_file $temp_searches_file`;		
		`sort -o $temp_citation_file $temp_citation_file`;
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		} #end if to process new format data - files with EDS
		$file_name="";
		@fields=();
	} #end foreach file
	`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
	`sort -m -o $searches_file $searches_file $temp_searches_file`;
	`sort -m -o $citation_file $citation_file $temp_citation_file`;
	`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
	close(SEARCHES);
	close(CITATION);
	close(FULLTEXT);
	close(SESSIONS);
	close(INFILE);
	close(DEBUG);
	#if ($ebsco_textfile_build eq "yes") {
	#	open(OUT,">ebsco_db_names.txt");
	#	my @keys = keys %db_names;
	#	@keys = sort @keys;
	#	foreach my $obsrv (@keys) {
	#		print OUT $db_names{$obsrv};
	#	} #end foreach
	#	close(OUT);
	#} #end if
	#??# debug section
	#if ($ebsco_debug eq "yes") {
	#	my @keys = keys %ebsco_titles;
	#	@keys = sort @keys;
	#	my $dbname = $keys[3];
	#	print"dbname=$dbname\n";
	#	my $dbcode=$ebsco_titles{$keys[3]};
	#	print"dbcode=$dbcode\n";
	#	print"date=$date\n";
	#} #end if 
	#??# end debug section
} #end ebsco_stats_build

#################################################################
# subroutine: proquest_stats_build
#             builds the stats files for Proquest
#################################################################
sub proquest_stats_build {
	my $proquest_textfile_build = @_;
	my $temp_searches_file = $data_dir."stats/temp_stats_monthly_proquest_search_data";
	my $temp_citation_file = $data_dir."stats/temp_stats_monthly_proquest_citation_data";
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_proquest_fulltext_data";
	#my $searches_file = $data_dir."stats/stats_monthly_proquest_search_data";
	my $searches_file = $data_dir."stats/stats_monthly_proquest_search_data_new";
	#my $citation_file = $data_dir."stats/stats_monthly_proquest_citation_data";
	my $citation_file = $data_dir."stats/stats_monthly_proquest_citation_data_new";
	#my $fulltext_file = $data_dir."stats/stats_monthly_proquest_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_proquest_fulltext_data_new";
	my $log_file = $data_dir."/stats/proquest_log.txt";
	my $proquest_orphans = $data_dir."/stats/proquest_orphans.txt";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/proquest_stats";	
  	#my $raw_data_dir = $data_dir . "ftp/galileo_stats/proquest_stats/test";	
	my @data_files = <$raw_data_dir/*>;
	my $inst_data = $data_dir."/stats/proquest_inst_data.csv";
	my $dbs_data = $data_dir."/stats/proquest_db_name.csv";
	my %inst_table = ();
	my %dbs_table = ();
	my %duplicate_DBs = ('ZUNU-SEARCHES' => 0,
                             'ZUNU-SEARCHES-LINE' => 'EMPTY',
                             'ZUNU-CITATION' => 0,
                             'ZUNU-CITATION-LINE' => 'EMPTY',
                             'ZUNU-FULLTEXT' => 0,
                             'ZUNU-FULLTEXT-LINE' => 'EMPTY',
                             'ZUPN-SEARCHES' => 0,
                             'ZUPN-SEARCHES-LINE' => 'EMPTY',
                             'ZUPN-CITATION' => 0,
                             'ZUPN-CITATION-LINE' => 'EMPTY',
                             'ZUPN-FULLTEXT' => 0,
                             'ZUPN-FULLTEXT-LINE' => 'EMPTY',
                             'ZUCJ-SEARCHES' => 0,
                             'ZUCJ-SEARCHES-LINE' => 'EMPTY',
                             'ZUCJ-CITATION' => 0,
                             'ZUCJ-CITATION-LINE' => 'EMPTY',
                             'ZUCJ-FULLTEXT' => 0,
                             'ZUCJ-FULLTEXT-LINE' => 'EMPTY',
                             'ZUHM-SEARCHES' => 0,
                             'ZUHM-SEARCHES-LINE' => 'EMPTY',
                             'ZUHM-CITATION' => 0,
                             'ZUHM-CITATION-LINE' => 'EMPTY',
                             'ZUHM-FULLTEXT' => 0,
                             'ZUHM-FULLTEXT-LINE' => 'EMPTY',
                             'ZUPJ-SEARCHES' => 0,
                             'ZUPJ-SEARCHES-LINE' => 'EMPTY',
                             'ZUPJ-CITATION' => 0,
                             'ZUPJ-CITATION-LINE' => 'EMPTY',
                             'ZUPJ-FULLTEXT' => 0,
                             'ZUPJ-FULLTEXT-LINE' => 'EMPTY');
	my %searches_dbs_values = (); 
	my %citation_dbs_values = (); 
	my %fulltext_dbs_values = ();
	my ($line,$title_line,$file,$temp,$date,$file_name,$zip_file,$value,$searches_key,$citation_key,$fulltext_key,$inst,$raw_inst,$duplicate_DBs_key)="";
	my @vars=();
	my @keys=();
	my ($date_set,$count,$var_count,$i,$tier_one_found)=0;
	$backup_file="";

	#### build inst_table
	#### $var[0] is the ProQuest code for the institution
	#### $var[2] is the inst code
	open(INST,"$inst_data");
	while(<INST>) {
		$line = $_;
        # @vars = split /,/, $line;
		@vars = csv_split( $line );
		$vars[2] =~ tr/[a-z]/[A-Z]/;
		## added 05/07/11 ##
		$vars[0] =~ s/ //g;
		chomp $vars[2];
		$inst_table{$vars[0]} = $vars[2];
	} #end while - create PQ code to GALILEO inst code and names
	close(INST);
	@vars=();
	$line="";

	#### build dbs_table
	#### in the file the third vaiable is not used.
	open(DBS,"$dbs_data");
	while(<DBS>) {
		$line = $_;
		@vars = split /##/, $line;
		$vars[1] =~ tr/[a-z]/[A-Z]/;
		## added 3/7/2007
		$vars[0] =~ tr/[a-z]/[A-Z]/;
		$vars[0] =~ s/ //g;
		chomp $vars[1];
		$dbs_table{$vars[0]} = $vars[1];
	} #end while - create PQ DB data to GALILEO DB code and names
	@vars=();
	$line="";
	if (-e $searches_file) {
		system("$makebak","$searches_file");
	}
	if (-e $fulltext_file) {
		system("$makebak","$fulltext_file");
	}
	if (-e $citation_file) {
		system("$makebak","$citation_file");
	}

	foreach my $file(@data_files) {
		#### find date of data
		@vars = split /_/, $file;
		if (($file =~ /ProQuest_Usage_Tech/) && !($date_set)) {
			$date = "m" . $vars[5];
			$date =~ s/.csv//;
			$date_set=1;
		} elsif (($file =~ /ProQuest_Usage_ZUHQ/) && !($date_set)) { 
			$date = "m" . $vars[5];
			$date =~ s/.csv//;
			$date_set=1;
		} elsif (($file =~ /ProQuest_Usage_NewFormat/) && !($date_set)) { 
			$date = "m" . $vars[5];
			$date =~ s/.csv//;
			$date_set=1;
			#??#
			print"date=$date\n";
		} elsif (($file =~ /ProQuest_Usage/) && !($date_set)) { 
			$date = "m" . $vars[4];
			$date =~ s/.csv//;
			$date_set=1;
		} else {
			print"ProQuest data file name problem.\n";
			print"Check the file name it should start with ProQuest_Usage or ProQuest_Usage_Tech.\n";
			exit;
		} #end if
                #??# print "date=$date\n";exit;
		@vars=();

		open(SEARCHES, ">$temp_searches_file");
		open(CITATION,">$temp_citation_file");
		open(FULLTEXT,">$temp_fulltext_file");
		open(ORPHAN,">$proquest_orphans");
		$file_name = $file;
		#$file_name =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/proquest_stats\///;
		$file_name =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/proquest_stats\/test\///;
		print "loading $file_name\n";
		#??# exit;
		print ORPHAN $file_name."\n";
		open(INFILE,"$file");
		if(($file_name !~ /ZUHQ/) && ($file_name !~ /NewFormat/)){
		while(<INFILE>) {
			if($count > 1){ ## this assumes that the first two lines areignored
			$line = $_;
			#@vars = split /",/, $line; # removed 4/21 due to change in data file
            # @vars = split /,/, $line;
		    @vars = csv_split( $line );
			$var_count = @vars;
			for($i=0;$i<$var_count;$i++) {
			  $value = $vars[$i];
			  $value =~ s/"//g;
				if ($value eq '') {
					$value="blank";
				}	
			  $vars[$i] = $value;
			} #end foreach
			$vars[4] =~ tr/[a-z]/[A-Z]/;
			$vars[4] =~ s/ //g;
			#if (($vars[2] =~ /Client Subtotals/) && ( $vars[4] ne "Subtotal") && ($vars[2] ne "Summary Totals")) {
			if (($vars[2] =~ /Client Subtotals/) && ( $vars[4] ne "Subtotal") && ($vars[3] ne "blank")) {
				if (($vars[3] > 0) && ((defined $inst_table{$vars[0]})
					&& (defined $dbs_table{$vars[4]}))) {
					$temp = $date . " " . $inst_table{$vars[0]} . " P Q " . $dbs_table{$vars[4]} . " " . $vars[3] . "\n";

					$searches_key=$inst_table{$vars[0]}."-".$dbs_table{$vars[4]};
					if ((!(defined $searches_dbs_values{$searches_key}))&& (($dbs_table{$vars[4]} eq "ZURL")||($dbs_table{$vars[4]} eq "ZUPN"))){
						$searches_dbs_values{$searches_key} = $temp;
					} elsif (defined $searches_dbs_values{$searches_key}) {
						my @temp_vars=();
						@temp_vars = split / /, $searches_dbs_values{$searches_key};
						if ($temp_vars[5] < $vars[3]) {
							$searches_dbs_values{$searches_key} = $temp;
						} #end if
					} else { 
						print SEARCHES $temp;
					} #end if
				} elsif (($vars[3] > 0) && !(defined $inst_table{$vars[0]})) {
					print ORPHAN $vars[0]."\n";
				} elsif (($vars[3] > 0) &&  !(defined $dbs_table{$vars[4]})) {
						print ORPHAN $vars[4]."\n";
				} #end if value greater than 0
				if (($vars[5] > 0) && ((defined $inst_table{$vars[0]})
				&& (defined $dbs_table{$vars[4]} ))) {
				$temp = $date . " " . $inst_table{$vars[0]} . " P D " . $dbs_table{$vars[4]} . " " . $vars[5] . "\n";
					$citation_key=$inst_table{$vars[0]}."-".$dbs_table{$vars[4]};
					if ((!(defined $citation_dbs_values{$citation_key}))&& (($dbs_table{$vars[4]} eq "ZURL")||($dbs_table{$vars[4]} eq "ZUPN"))){
						$citation_dbs_values{$citation_key} = $temp;
					} elsif (defined $citation_dbs_values{$citation_key}) {
						my @temp_vars=();
						@temp_vars = split / /, $citation_dbs_values{$citation_key};
						if ($temp_vars[5] < $vars[5]) {
							$citation_dbs_values{$citation_key} = $temp;
						} #end if
					} else {
						print CITATION $temp;
					} #end if 
				} elsif (($vars[5] > 0) && !(defined $inst_table{$vars[0]})) {
					print ORPHAN $vars[0]."\n";
				} elsif (($vars[5] > 0) &&  !(defined $dbs_table{$vars[4]})) {
					print ORPHAN $vars[4]."\n";
				} #end if value greater than 0
				if (($vars[6] > 0) && ((defined $inst_table{$vars[0]})
				&& (defined $dbs_table{$vars[4]}))) {
				$temp = $date . " " . $inst_table{$vars[0]} . " P F " . $dbs_table{$vars[4]} . " " . $vars[6] . "\n";
					$fulltext_key=$inst_table{$vars[0]}."-".$dbs_table{$vars[4]};
					if ((!(defined $fulltext_dbs_values{$fulltext_key})) && (($dbs_table{$vars[4]} eq "ZURL")||($dbs_table{$vars[4]} eq "ZUPN"))){
						$fulltext_dbs_values{$fulltext_key} = $temp;
					} elsif (defined $fulltext_dbs_values{$fulltext_key}) {
						my @temp_vars=();
						@temp_vars = split / /, $fulltext_dbs_values{$fulltext_key};
						if ($temp_vars[5] < $vars[6]) {
							$fulltext_dbs_values{$fulltext_key} = $temp;
						} #end if
					} else {
						print FULLTEXT $temp;
					} #end if
				} elsif (($vars[6] > 0) && !(defined $inst_table{$vars[0]})) {
					print ORPHAN $vars[0]."\n";
				} elsif (($vars[6] > 0) &&  !(defined $dbs_table{$vars[4]})) {
					print ORPHAN $vars[4]."\n";
				} #end if value greater than 0
			} #end if
			} #end if not first line
			$count++;
			} #end while
		} elsif ($file_name =~ /ZUHQ/){
			while(<INFILE>){
				$line = $_;
				if ($line =~ /Subtotal/){
		            @vars = csv_split( $line );
                    # @vars = split /,"/, $line;
                    # $vars[0] =~	s/"//g;
                    # $vars[2] =~	s/"//g;
                    # $vars[4] =~	s/"//g;
                    # $vars[5] =~	s/"//g;
                    # chomp($vars[5]);
					## searches $vars[2]
					if (($vars[2] > 0) && (defined $inst_table{$vars[0]})){
						$temp = $date . " " . $inst_table{$vars[0]} . " P Q ZUHQ " . $vars[2] . "\n";
						print SEARCHES $temp;
					} #end if
					## citation $vars[4]
					if (($vars[4] > 0) && (defined $inst_table{$vars[0]})){
						$temp = $date . " " . $inst_table{$vars[0]} . " P D ZUHQ " . $vars[4] . "\n";
						print CITATION $temp;
					} #end if
					## fulltext $vars[5]
					if (($vars[5] > 0) && (defined $inst_table{$vars[0]})){ 
						$temp = $date . " " . $inst_table{$vars[0]} . " P F ZUHQ " . $vars[5] . "\n";
						print FULLTEXT $temp;
					} #end if
				} #end if		
			} #end while
		} elsif ($file_name =~ /NewFormat/){
			print "Reading NewFormat\n";#??#exit;
			while(<INFILE>){
				$line=$_;
				if($line=~/Tier \(1\)/) {
					$title_line = $line;	
					@vars = split / /, $line;
					if(exists $inst_table{$vars[1]}) {
						$inst=$inst_table{$vars[1]};
						$raw_inst=$vars[1];
						$tier_one_found=1
					} else {
						print ORPHAN "$title_line - unknown institution\n\n";
					} #end if
				} #end if
				if(($line=~/Account Subtotals/) && 
                                   ($tier_one_found)){
					if($line=~/,"/){
		                @vars = csv_split( $line );
                        # @vars=split /,"/,$line;
                        # $vars[1] =~ s/"//g;
                        # $vars[2] =~ s/"//g;
                        # $vars[3] =~ s/"//g;
                        # $vars[4] =~ s/"//g;
					} else {
		                @vars = csv_split( $line );
                        # @vars=split /,/,$line;
					} #end if
					$vars[2] =~ tr/[a-z]/[A-Z]/;
					$vars[2] =~ s/ //g;
					if (($vars[1] > 0) && ($vars[2]!~/SUBTOTAL/) && (exists $dbs_table{$vars[2]})
					&& ($vars[2] ne "") && ($inst ne "")){
						$temp = $date . " " . $inst . " P Q " . $dbs_table{$vars[2]} . " " . $vars[1] . "\n";
						#??#print"vars[2]=$vars[2]\n";
						if($vars[2] =~ /PROQUESTNURSING&ALLIEDHEALTHSOURCE/){
							#??#print "Found Nursing & Allied Health SEARCHES\n";
							if($vars[1] > $duplicate_DBs{'ZUNU-SEARCHES'}){
								$duplicate_DBs{'ZUNU-SEARCHES'}=$vars[1];
								$duplicate_DBs{'ZUNU-SEARCHES-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTNEWSSTAND/){
							#??#print "Found Newsstand SEARCHES\n";
							if($vars[1] > $duplicate_DBs{'ZUPN-SEARCHES'}){
								$duplicate_DBs{'ZUPN-SEARCHES'}=$vars[1];
								$duplicate_DBs{'ZUPN-SEARCHES-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTCRIMINALJUSTICE/){
							#??#print "Found Criminal Justice SEARCHES\n";
							if($vars[1] > $duplicate_DBs{'ZUCJ-SEARCHES'}){
								$duplicate_DBs{'ZUCJ-SEARCHES'}=$vars[1];
								$duplicate_DBs{'ZUCJ-SEARCHES-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTHEALTH&MEDICALCOMPLETE/){
							#??#print "Found ProQuest Health & Medical Complete SEARCHES\n";
							if($vars[1] > $duplicate_DBs{'ZUHM-SEARCHES'}){
								$duplicate_DBs{'ZUHM-SEARCHES'}=$vars[1];
								$duplicate_DBs{'ZUHM-SEARCHES-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTPSYCHOLOGYJOURNALS/){
							#??#print "Found ProQuest Psychology Journals SEARCHES\n";
							if($vars[1] > $duplicate_DBs{'ZUPJ-SEARCHES'}){
								$duplicate_DBs{'ZUPJ-SEARCHES'}=$vars[1];
								$duplicate_DBs{'ZUPJ-SEARCHES-LINE'}=$temp;
							} #end if
						} else {
							print SEARCHES $temp;
						} #end if
					} elsif ((!(exists $dbs_table{$vars[2]})) && ($vars[2] ne "") && ($vars[2] !~/SUBTOTAL/)) {
						$temp = $date . " " . $vars[2] . " - unknown DB name\n$title_line\n$line\n";
						print ORPHAN $temp; 
					} #end if
					if (($vars[3] > 0) && ($vars[2]!~/SUBTOTAL/) && (exists $dbs_table{$vars[2]})
					&& ($vars[2] ne "") && ($inst ne "")) {
						$temp = $date . " " . $inst . " P D " . $dbs_table{$vars[2]} . " " . $vars[3] . "\n";

						if($vars[2] =~ /PROQUESTNURSING&ALLIEDHEALTHSOURCE/){
							#??#print "Found Nursing & Allied Health CITATION\n";
							if($vars[3] > $duplicate_DBs{'ZUNU-CITATION'}){
								$duplicate_DBs{'ZUNU-CITATION'}=$vars[3];
								$duplicate_DBs{'ZUNU-CITATION-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTNEWSSTAND/){
							#??#print "Found Newsstand CITATION\n";
							if($vars[3] > $duplicate_DBs{'ZUPN-CITATION'}){
								$duplicate_DBs{'ZUPN-CITATION'}=$vars[3];
								$duplicate_DBs{'ZUPN-CITATION-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTCRIMINALJUSTICE/){
							#??#print "Found Criminal Justice CITATION\n";
							if($vars[3] > $duplicate_DBs{'ZUCJ-CITATION'}){
								$duplicate_DBs{'ZUCJ-CITATION'}=$vars[1];
								$duplicate_DBs{'ZUCJ-CITATION-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTHEALTH&MEDICALCOMPLETE/){
							#??#print "Found ProQuest Health & Medical Complete CITATION\n";
							if($vars[3] > $duplicate_DBs{'ZUHM-CITATION'}){
								$duplicate_DBs{'ZUHM-CITATION'}=$vars[1];
								$duplicate_DBs{'ZUHM-CITATION-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTPSYCHOLOGYJOURNALS/){
							#??#print "Found ProQuest Psychology Journals CITATION\n";
							if($vars[3] > $duplicate_DBs{'ZUPJ-CITATION'}){
								$duplicate_DBs{'ZUPJ-CITATION'}=$vars[1];
								$duplicate_DBs{'ZUPJ-CITATION-LINE'}=$temp;
							} #end if
						} else {
							print CITATION $temp;
						} #end if
					} elsif ((!(exists $dbs_table{$vars[2]})) && ($vars[2] ne "") && ($vars[2] !~/SUBTOTAL/)) {
						$temp = $date . " " . $vars[2] . " - unknown DB name\n$title_line\n$line\n";
						print ORPHAN $temp; 
					} #end if
					if (($vars[4] > 0) && ($vars[2]!~/SUBTOTAL/) && (exists $dbs_table{$vars[2]})
					&& ($vars[2] ne "") && ($inst ne "")){ 
						$temp = $date . " " . $inst . " P F " . $dbs_table{$vars[2]} . " " . $vars[4] . "\n";
						if($vars[2] =~ /PROQUESTNURSING&ALLIEDHEALTHSOURCE/){
							#??#print "Found Nursing & Allied Health FULLTEXT\n";
							if($vars[4] > $duplicate_DBs{'ZUNU-FULLTEXT'}){
								$duplicate_DBs{'ZUNU-FULLTEXT'}=$vars[4];
								$duplicate_DBs{'ZUNU-FULLTEXT-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTNEWSSTAND/){
							#??#print "Found Newsstand FULLTEXT\n";
							if($vars[4] > $duplicate_DBs{'ZUPN-FULLTEXT'}){
								$duplicate_DBs{'ZUPN-FULLTEXT'}=$vars[4];
								$duplicate_DBs{'ZUPN-FULLTEXT-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTCRIMINALJUSTICE/){
							#??#print "Found Criminal Justice FULLTEXT\n";
							if($vars[4] > $duplicate_DBs{'ZUCJ-FULLTEXT'}){
								$duplicate_DBs{'ZUCJ-FULLTEXT'}=$vars[1];
								$duplicate_DBs{'ZUCJ-FULLTEXT-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTHEALTH&MEDICALCOMPLETE/){
							#??#print "Found ProQuest Health & Medical Complete FULLTEXT\n";
							if($vars[4] > $duplicate_DBs{'ZUHM-FULLTEXT'}){
								$duplicate_DBs{'ZUHM-FULLTEXT'}=$vars[1];
								$duplicate_DBs{'ZUHM-FULLTEXT-LINE'}=$temp;
							} #end if
						} elsif ($vars[2] =~ /PROQUESTPSYCHOLOGYJOURNALS/){
							#??#print "Found ProQuest Psychology Journals FULLTEXT\n";
							if($vars[4] > $duplicate_DBs{'ZUPJ-FULLTEXT'}){
								$duplicate_DBs{'ZUPJ-FULLTEXT'}=$vars[1];
								$duplicate_DBs{'ZUPJ-FULLTEXT-LINE'}=$temp;
							} #end if
						} else {
							print FULLTEXT $temp;
						} #end if
					} elsif ((!(exists $dbs_table{$vars[2]})) && ($vars[2] ne "") && ($vars[2] !~/SUBTOTAL/)) {
						$temp = $date . " " . $vars[2] . " - unknown DB name\n$title_line\n$line\n";
						print ORPHAN $temp; 
					} #end if
				} #end if
				if((exists $vars[2]) && ($vars[2]=~/SUBTOTAL/)){
					$tier_one_found=0;	
				} #end if
				if(!($tier_one_found)){
					print SEARCHES $duplicate_DBs{'ZUNU-SEARCHES-LINE'} if ($duplicate_DBs{'ZUNU-SEARCHES-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUNU-SEARCHES-LINE'}='EMPTY';
					$duplicate_DBs{'ZUNU-SEARCHES'}=0;
					print SEARCHES $duplicate_DBs{'ZUPN-SEARCHES-LINE'} if ($duplicate_DBs{'ZUPN-SEARCHES-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUPN-SEARCHES-LINE'}='EMPTY';
					$duplicate_DBs{'ZUPN-SEARCHES'}=0;
					print SEARCHES $duplicate_DBs{'ZUCJ-SEARCHES-LINE'} if ($duplicate_DBs{'ZUCJ-SEARCHES-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUCJ-SEARCHES-LINE'}='EMPTY';
					$duplicate_DBs{'ZUCJ-SEARCHES'}=0;
					print SEARCHES $duplicate_DBs{'ZUHM-SEARCHES-LINE'} if ($duplicate_DBs{'ZUHM-SEARCHES-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUHM-SEARCHES-LINE'}='EMPTY';
					$duplicate_DBs{'ZUHM-SEARCHES'}=0;
					print SEARCHES $duplicate_DBs{'ZUPJ-SEARCHES-LINE'} if ($duplicate_DBs{'ZUPJ-SEARCHES-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUPJ-SEARCHES-LINE'}='EMPTY';
					$duplicate_DBs{'ZUPJ-SEARCHES'}=0;
					print FULLTEXT $duplicate_DBs{'ZUNU-FULLTEXT-LINE'} if ($duplicate_DBs{'ZUNU-FULLTEXT-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUNU-FULLTEXT-LINE'}='EMPTY';
					$duplicate_DBs{'ZUNU-FULLTEXT'}=0;
					print FULLTEXT $duplicate_DBs{'ZUPN-FULLTEXT-LINE'} if ($duplicate_DBs{'ZUPN-FULLTEXT-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUPN-FULLTEXT-LINE'}='EMPTY';
					$duplicate_DBs{'ZUPN-FULLTEXT'}=0;
					print FULLTEXT $duplicate_DBs{'ZUCJ-FULLTEXT-LINE'} if ($duplicate_DBs{'ZUCJ-FULLTEXT-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUCJ-FULLTEXT-LINE'}='EMPTY';
					$duplicate_DBs{'ZUCJ-FULLTEXT'}=0;
					print FULLTEXT $duplicate_DBs{'ZUHM-FULLTEXT-LINE'} if ($duplicate_DBs{'ZUHM-FULLTEXT-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUHM-FULLTEXT-LINE'}='EMPTY';
					$duplicate_DBs{'ZUHM-FULLTEXT'}=0;
					print FULLTEXT $duplicate_DBs{'ZUPJ-FULLTEXT-LINE'} if ($duplicate_DBs{'ZUPJ-FULLTEXT-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUPJ-FULLTEXT-LINE'}='EMPTY';
					$duplicate_DBs{'ZUPJ-FULLTEXT'}=0;
					print CITATION $duplicate_DBs{'ZUNU-CITATION-LINE'} if ($duplicate_DBs{'ZUNU-CITATION-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUNU-CITATION-LINE'}='EMPTY';
					$duplicate_DBs{'ZUNU-CITATION'}=0;
					print CITATION $duplicate_DBs{'ZUPN-CITATION-LINE'} if ($duplicate_DBs{'ZUPN-CITATION-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUPN-CITATION-LINE'}='EMPTY';
					$duplicate_DBs{'ZUPN-CITATION'}=0;
					print CITATION $duplicate_DBs{'ZUCJ-CITATION-LINE'} if ($duplicate_DBs{'ZUCJ-CITATION-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUCJ-CITATION-LINE'}='EMPTY';
					$duplicate_DBs{'ZUCJ-CITATION'}=0;
					print CITATION $duplicate_DBs{'ZUHM-CITATION-LINE'} if ($duplicate_DBs{'ZUHM-CITATION-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUHM-CITATION-LINE'}='EMPTY';
					$duplicate_DBs{'ZUHM-CITATION'}=0;
					print CITATION $duplicate_DBs{'ZUPJ-CITATION-LINE'} if ($duplicate_DBs{'ZUPJ-CITATION-LINE'} ne 'EMPTY');
					$duplicate_DBs{'ZUPJ-CITATION-LINE'}='EMPTY';
					$duplicate_DBs{'ZUPJ-CITATION'}=0;
				} #end if
			} #end while
				
		} #end if
		@keys = keys %searches_dbs_values;
		foreach my $obsrv(@keys){
			print SEARCHES $searches_dbs_values{$obsrv};
		} #end foreach
		@keys = keys %citation_dbs_values;
		foreach my $obsrv(@keys){
			print CITATION $citation_dbs_values{$obsrv};
		} #end foreach
		@keys = keys %fulltext_dbs_values;
		foreach my $obsrv(@keys){
			print FULLTEXT $fulltext_dbs_values{$obsrv};
		} #end foreach
		close(INFILE);
		$count=0;
	close(SEARCHES);
	close(CITATION);
	close(FULLTEXT);
	close(ORPHAN);
	%searches_dbs_values=();
	%citation_dbs_values=();
	%fulltext_dbs_values=();
	`sort -o $temp_searches_file $temp_searches_file`;		
	`sort -o $temp_citation_file $temp_citation_file`;
	`sort -o $temp_fulltext_file $temp_fulltext_file`;
	`sort -m -o $searches_file $searches_file $temp_searches_file`;
	`sort -m -o $citation_file $citation_file $temp_citation_file`;
	`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
	$date_set=0;
	} #end foreach
} #end proquest_stats_build

#################################################################
# subroutine: lexis_nexis_stats_build
#             builds the stat files from Lexis-Nexis data
#################################################################
sub lexis_nexis_stats_build {
	my $temp_searches_file = $data_dir."stats/temp_stats_monthly_lexis_nexis_search_data";
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_lexis_nexis_fulltext_data";
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_lexis_nexis_sessions_data";
	#my $searches_file = $data_dir."stats/stats_monthly_lexis_nexis_search_data";
	my $searches_file = $data_dir."stats/stats_monthly_lexis_nexis_search_data_new";
	#my $fulltext_file = $data_dir."stats/stats_monthly_lexis_nexis_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_lexis_nexis_fulltext_data_new";
	#my $sessions_file = $data_dir."stats/stats_monthly_lexis_nexis_sessions_data";
	my $sessions_file = $data_dir."stats/stats_monthly_lexis_nexis_sessions_data_new";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/lexis_nexis_stats";	
	my @data_files = <$raw_data_dir/*>;
	my $inst_data = $data_dir."/stats/lexis_nexis_key.csv";
	my $inst_data_new = $data_dir."/stats/lexis_nexis_key_new.csv";
	my $inst_data_post201303 = $data_dir."/stats/lexis_nexis_post201303_key.csv";
	my $lexis_nexis_orphans = $data_dir."/stats/lexis_nexis_orphans.txt";
	my %inst_table = ();
	my ($line,$file,$temp,$date,$test_date,$file_name,$zip_file,$value,$type,$inst_code,$inst,$db,$outline,$var_count,$inst_name,$vend_code)="";
	my @vars=();
	my @temp_vars=();
	my $date_set=0;
	my $count=0;
	$var_count=0;
	my $new_format=0;
	my $post201303_format=0;
	my $first_line=1;
	my $i=0;
	#open (INSTKEY,"$inst_data");
	#while(<INSTKEY>) {
	#	$line = $_;
	#	@vars = split /,/,$line;
	#	$inst = $vars[2];
	#	$inst =~ tr/[a-z]/[A-Z]/;
	#	$inst_table{$vars[0]} = $inst;
	#} #end while
	#@vars=();
	#close(INSTKEY);
	if (-e $searches_file) {
		system("$makebak","$searches_file");
	}
	if (-e $fulltext_file) {
		system("$makebak","$fulltext_file");
	}
	if (-e $sessions_file) {
		system("$makebak","$sessions_file");
	}
	$db = "ZXAU";
	foreach $file (@data_files) {
		open(SEARCHES, ">$temp_searches_file");
		open(FULLTEXT,">$temp_fulltext_file");
		open(SESSIONS,">$temp_sessions_file");
		open(ORPHAN,">>$lexis_nexis_orphans");
		$file_name = $file;
		$file_name =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/lexis_nexis_stats\///;
		$date = $file_name;
		$date =~ s/LexisNexis_Usage_//;
		$date =~ s/.csv//;
		$test_date = $date;
		$date = "m".$date;
		print "loading $file_name\n";
		print ORPHAN $file_name."\n";
		print"test_date=$test_date\n";
		$first_line=1;
		if( $test_date < 201212 ){
	  	  open (INSTKEY,"$inst_data");
	  	  while(<INSTKEY>) {
		    $line = $_;
		    @vars = split /,/,$line;
		    $inst = $vars[2];
		    $inst =~ tr/[a-z]/[A-Z]/;
		    $inst_table{$vars[0]} = $inst;
	          } #end while
	          @vars=();
	          close(INSTKEY);
		} else {
		  print"test_date > 201211\n";
	          print "new format data file\n";	
		  $new_format=1;
		  if ($test_date <= 201303){
	  	     open (INSTKEY,"$inst_data_new");
		  } elsif ($test_date > 201303){
		     open (INSTKEY,"$inst_data_post201303");
		     $post201303_format=1;
		     print "using post 201303 key\n";
		  } #end if 
	  	  while(<INSTKEY>) {
		    $line = $_;
		    @vars = split /,/,$line;
		    $inst = $vars[0];
		    $inst =~ tr/[a-z]/[A-Z]/;
		    $vend_code=$vars[1];
		    chomp($vend_code);
	            #print"vars[0]=$inst-vars[1]=$vend_code\n";
		    $inst_table{$vend_code} = $inst;
	          } #end while
	          @vars=();
	          close(INSTKEY);
		} #end if to determine which key	
		#exit;
		open(INFILE,"$file");
		if(!($new_format)){
		## following for old format data files
		while(<INFILE>) {
			$line = $_;
			if ($line =~ /Search/) {
				$type="L Q";
			} elsif ($line =~ /Document/) {
				$type="L F";
			} #end if to determine type
			if (($line =~ /Academic Universe/) && ($line !~ /Total/)){
				if ($line =~ /,"/) {
					@temp_vars = split /,"/ ,$line;
					#@temp_vars = split /,/ ,$line;
					$var_count = @temp_vars;
					if ($var_count == 2) {
						$temp_vars[1] =~ s/,//g;
						$temp_vars[1] =~ s/"//g;
						@vars = split /,/ ,$temp_vars[0];
						$vars[++$#vars] = $temp_vars[1];
					} elsif ($var_count == 6) {
						foreach my $var(@temp_vars) {
							$var =~ s/"//g;
							$vars[++$#vars] = $var;
						} #end foreach
						$var_count=@vars;
					} #end if
				} else {
					@vars = split /,/ ,$line;
				} #end if
				$inst_code = $vars[2];
				$inst_code =~ tr /a-z/A-Z/;
			#	print "inst_code=$inst_code\n";
			#	print "inst_table=$inst_table{$inst_code}\n";
				if ($inst_code eq "UU0009") {
					$inst_name = $vars[1];
					if ($inst_name =~ /ATLANTA AREA TECHNICAL INSTITUTE/) {
						$inst = "ATLT";
					} elsif ( $inst_name =~ /COOSA VALLEY TECHNICAL COLLEGE/) {
						$inst = "COVT";
					} elsif ( $inst_name =~ /GWINNETT TECHNICAL INSTITUTE/) {
						$inst = "GWT1";
					} elsif ( $inst_name =~ /MIDDLE GEORGIA TECHNICAL COLLEGE/) {
						$inst = "MGAT";
					} elsif ( $inst_name =~ /THOMAS COLLEGE-THOMASVILLE/) {
						$inst = "THCO";
					} #end if
				} elsif ($inst_code eq "UU0039") {
					$inst_name = $vars[1];
					if ($inst_name =~ /ALTAMAHA TECHNICAL INSTITUTE/) {
						$inst = "ALTA";
					} elsif ($inst_name =~ /NORTH METRO TECHNICAL INSTITUTE/) {
						$inst = "NMT1";
					} #end if
				} else {
					$inst = $inst_table{$inst_code};
				} #end if
				$count = $vars[5];
				$count =~ s/,//g;
				if($count=~/\./){
					$count =~ s/\.00//g;
				}
				$outline = $date . " " . $inst . " " . $type . " " . $db . " " . $count;
			#	print"outline=$outline\n";
				if (($type eq "L Q") && ($inst =~ /[A-Z]/)) {
					#print "searches outline=$outline\n";
					print SEARCHES $outline;
					$inst="";
					$outline="";
				} elsif (($type eq "L F") && ($inst =~ /[A-Z]/)) {
					#print "fulltext outline=$outline\n";
					print FULLTEXT $outline;
					$inst="";
					$outline="";
				} else {
					$temp = $vars[1];
				#	$temp =~ s/"//g;
					$inst_code = $inst_code . ",$temp\n";
					print ORPHAN $inst_code;
					$inst="";	
					$outline="";
				} #end if to print out data
			$inst="";
			$outline="";
			@vars=();
			} #end if line contains data
		} #end while line in the file and old format data
		} elsif ($new_format) {
		  print"file in new format\n";
		  while(<INFILE>){
		    $line = $_;
		    $line =~ s/\r\n/\n/;
	            if(!($first_line)){	
		      if(!($post201303_format)){
		        @vars = split /\(/,$line;
		        @vars = split /,/,$vars[1];  
		        $vars[0] =~ s/\)//;
		        $vars[0] =~ s/"//;  
		        $vars[0] =~ s/ //;
		      }	#end if not post201303
		      if($post201303_format){
		        @vars = split /,/, $line;
			$var_count=@vars;
		        @temp_vars = split /\(/, $vars[0];
		        $vars[0] = $temp_vars[1];
			$vars[0] = "(".$vars[0];
		      } #end if post201303
	            print"vars[0]=$vars[0]:vars[1]=$vars[1]:vars[2]=$vars[2]:\n";	
		    if(exists($inst_table{$vars[0]})){
	              $inst = $inst_table{$vars[0]};
	              #if (is_integer($vars[1])){	
	                $count = $vars[1];
			if($count =~ /[0-9]/){
		          $outline = $date . " " . $inst . " L Q " . $db . " " . $count . "\n";
                          print"$outline\n";
	                  print SEARCHES $outline;
			} #end if count has intergers
			$outline="";
		      #} #end if var[1] defined	
		      #if (is_integer($vars[2])){
	                $count = $vars[3];	
			if($count =~ /[0-9]/){
		        $outline = $date . " " . $inst . " L F " . $db . " " . $count . "\n";
                        print"$outline\n"; 
	                print FULLTEXT $outline;
			} #end if count has integers
			$outline="";
			if ($test_date >= 201407){
				if ($var_count == 4){
					$count = $vars[2];
					if($count =~/[0-9]/){
		        		$outline = $date . " " . $inst . " L A " . $db . " " . $count . "\n";
	                		print SESSIONS $outline;
					} #end if count has integers
				} #end session data exists
			}#end if to collect session data
		      #} #end if var[2] defined	
	            } else {
		        $inst = $inst ."\n";
			print ORPHAN $inst;
	            } #end if key exists
	            $inst="";	
		  } # end if past first line
		  $first_line=0;
		  print"past first line\n";
		  } #end while new_format true
		} #end if to test for old or new format
		close(SEARCHES);
		close(FULLTEXT);
		close(SESSIONS);
		close(ORPHAN);
		$first_line=1;
		`sort -o $temp_searches_file $temp_searches_file`;		
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -o $temp_sessions_file $temp_sessions_file`;
		`sort -m -o $searches_file $searches_file $temp_searches_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
	} #end foreach data file
} #end lexis_nexis_stats_build

#################################################################
# subroutine: britannica_stats_build - creates the stats file
#             for the Enclyopedia Britannica.
#################################################################
sub britannica_stats_build {
	my $temp_searches_file = $data_dir."stats/temp_stats_monthly_britannica_search_data";
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_britannica_fulltext_data";
	#my $searches_file = $data_dir."stats/stats_monthly_britannica_search_data";
	my $searches_file = $data_dir."stats/stats_monthly_britannica_search_data_new";
	#my $fulltext_file = $data_dir."stats/stats_monthly_britannica_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_britannica_fulltext_data_new";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/britannica_stats";	
	my @data_files = <$raw_data_dir/*>;
	#my @data_files = "$raw_data_dir/Britannica_Usage_200607.csv";
	my @vars=();
	my @temp=();
	my ($line,$file,$past_top,$date,$file_name,$file_name_report,$zip_file,$value,$type,$inst_code,$inst,$outline,$count1,$count2,$tmp,$next)="";
	my %db_index=(
	"ZEBO" => "3",
	"ZEBA" => "8",
	"ZEWD" => "13",
	"ZEBD" => "18",
	"ZEBP" => "23",
	"ZEHS" => "33",
	"ZEBM" => "38",
	"ZEBK" => "43",
	"ZEPL" => "53",
	"ZEPK" => "58",
	"ZEBJ" => "62",
	"ZELZ" => "67",
	"ZEPS" => "70");
	my @keys=();
	my @inst_code=();
	@keys =  keys %db_index;
	#$past_top=0;
	my $fulltext_total=0;
	my $searches_total=0;
	my $inst_found=0;

	#####  Make back-ups of old datafiles  #####
	if ((-e $searches_file) && (!($opt_n))) {
		system("$makebak","$searches_file");
	}
	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	} #end if for make back-ups

	foreach $file(@data_files) {
		$file_name_report=$file;
		$file_name_report =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/britannica_stats//;
		print"Working on $file_name_report\n";
		$date = $file;
		chomp($date);
		$date =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/britannica_stats\/Britannica_Usage_//;
		$date =~ s/.csv//;
		if (($date >= 201304) && ( $date < 201309)){
			%db_index=();
			%db_index=(
			"ZEBA" => "10",
			"ZEEO" => "14",
			"ZEIQ" => "18",
			"ZEBO" => "26",
			"ZEBP" => "22",
			"ZEHS" => "34",
			"ZEBK" => "38",
			"ZEBM" => "42",
			"ZELZ" => "46",
			"ZEMD" => "54",	
			"ZEBD" => "70",
			"ZEWD" => "74");
			@keys = keys %db_index;
			#print"using new keys\n";
			#exit;
		} elsif (($date >= 201309) && ($date < 201610)) {
			print"Using >= 201309 key\n";
			%db_index=();
			%db_index=(
			"ZEBA" => "10",
			"ZEEO" => "14",
			"ZEIQ" => "18",
			"ZEBO" => "38",
			"ZEHS" => "50",
			"ZEBK" => "58",
			"ZEBM" => "62",
			"ZELZ" => "66",
			"ZEMD" => "74",	
			"ZEBD" => "90",
			"ZEWD" => "98");
			@keys = keys %db_index;
		} elsif (($date >= 201610) && ($date <= 201706)){
			print"Using >= 201610 key\n";
			%db_index=();
			%db_index=(
			"ZEBA" => "10",
			"ZEEO" => "18",
			"ZEIQ" => "26",
			"ZEBO" => "46",
			"ZEHS" => "66",
			"ZEBK" => "62",
			"ZEBM" => "58",
			"ZELZ" => "74",
			"ZEMD" => "86",	
			"ZEBD" => "102",
			"ZEWD" => "110");
			@keys = keys %db_index;
		} elsif (($date >= 201707) && ($date <= 201806)){
			print"Using >= 201707 key\n";
			%db_index=();
			%db_index=(
			"ZEBA" => "10",
			"ZEEO" => "18",
			"ZEIQ" => "26",
			"ZELZ" => "30",
			"ZEBO" => "50",
			"ZEJA" => "54",
			"ZEBM" => "66",
			"ZEBK" => "70",
			"ZEHS" => "74",
			"ZEMD" => "90",	
			"ZEBD" => "114",
			"ZEJU" => "122",
			"ZEUN" => "126",
			"ZEWD" => "130");
			@keys = keys %db_index;
		} elsif ($date >= 201807) {
			print"Using >= 201807 key\n";
			%db_index=();
			%db_index=(
			"ZEBA" => "10",
			"ZEEO" => "22",
			"ZEIQ" => "26",
			"ZELZ" => "30",
			"ZEBO" => "50",
			"ZEJA" => "54",
			"ZEBM" => "66",
			"ZEHS" => "70",
			"ZEBK" => "78",
			"ZEMD" => "90",
			"ZEBD" => "114",
			"ZEOS" => "118",
			"ZEJU" => "122",
			"ZEUN" => "126",
			"ZEWD" => "130");
			@keys = keys %db_index;
		} #end if for new format values

		$date = "m".$date;
		open(SEARCHES, ">$temp_searches_file");
		open(FULLTEXT,">$temp_fulltext_file");
		open(INFILE,"$file");
		while(<INFILE>) {
			$line = $_;
			if ((($line =~ /\[/) || ($line =~ /\(/))
		 && (($line =~ /SubTotals:/) || ($line =~ /Subtotals:/))){
	            @vars = csv_split( $line );
                #@vars = split /,/,$line;
				if($vars[0] =~ /\[/){
					@inst_code = split /\[/,$vars[0];
					$inst_code[1] =~ s/]//g;
					$inst = $inst_code[1];
				} elsif ($vars[0] =~ /\(/){
					@inst_code = split /\(/,$vars[0];
					$inst_code[1] =~ s/\)//g;
					$inst = $inst_code[1];
				} #end if
				chomp($inst);
				if ($inst eq "mgc1"){
					$inst="mga1"
				} elsif ($inst eq "sgsc1"){
					$inst="sga1";
				} elsif ($inst eq "cptc") {
					$inst="alta";
				} #end if
				$inst =~ tr/[a-z]/[A-Z]/;
				#print"inst=$inst\n";
			} elsif (($line !~ /\[/) && (($line =~ /SubTotals:/) || ($line =~ /Subtotals:/))){
				if ($line =~ /, /){
					$line =~ s/, /-/g;
					print"$line\n";
				} #end if
          			if ($line =~ /Atlanta International/){
              			$inst="psai";$inst_found=1;
				} elsif ($line =~ /Augusta Preparatory/){
		      		$inst="psap";$inst_found=1;
				} elsif ($line =~ /Blessed Trinity/){
		      		$inst="psbt";$inst_found=1;
				} elsif ($line =~ /Brandon Hall/){
		      		$inst="psbh";$inst_found=1;
				} elsif ($line =~ /George Walton Academy/){
		      		$inst="psgw";$inst_found=1;
				} elsif ($line =~ /Gracepoint School/){
		      		$inst="psgs";$inst_found=1;
				} elsif ($line =~ /Yeshiva Ohr Yisrael/){
		      		$inst="psyy";$inst_found=1;
				} elsif ($line =~ /Brentwood School/){
		      		$inst="psbs";$inst_found=1;
				} elsif ($line =~ /Calvary Christian/){
		      		$inst="pscc";$inst_found=1;
				} elsif ($line =~ /Deerfield-Windsor/){
		      		$inst="psdw";$inst_found=1;
				} elsif ($line =~ /Episcopal Day/){
		      		$inst="psed";$inst_found=1;
				} elsif ($line =~ /Flint River/){
		      		$inst="psfr";$inst_found=1;
				} elsif ($line =~ /Frederica/){
		      		$inst="psfa";$inst_found=1;
				} elsif ($line =~ /Holy Spirit Preparatory/){
		      		$inst="pshs";$inst_found=1;
				} elsif ($line =~ /Mt Pisgah/){
		      		$inst="psmp";$inst_found=1;
				} elsif ($line =~ /Mount Vernon/){
		      		$inst="psmv";$inst_found=1;
				} elsif ($line =~ /North Cobb Christian/){
		      		$inst="psnc";$inst_found=1;
				} elsif ($line =~ /Oak Mountain/){
		      		$inst="psom";$inst_found=1;
				} elsif ($line =~ /Our Lady of Mercy/){
		      		$inst="psol";$inst_found=1;
				} elsif ($line =~ /Rabun Gap Nacoochee/){
		      		$inst="psrg";$inst_found=1;
				} elsif ($line =~ /St. John the Evangelist/){
		      		$inst="pssj";$inst_found=1;
				} elsif ($line =~ /Sherwood Christian/){
		      		$inst="pssh";$inst_found=1;
				} elsif ($line =~ /Southwest Georgia Academy/){
		      		$inst="pssg";$inst_found=1;
				} elsif ($line =~ /St. Andrew's/){
		      		$inst="pssa";$inst_found=1;
				} elsif ($line =~ /St. Vincent's/){
		      		$inst="pssv";$inst_found=1;
				} elsif ($line =~ /Valwood School/){
		      		$inst="psvs";$inst_found=1;
				} elsif ($line =~ /Westfield Schools/){
		      		$inst="psws";$inst_found=1;
				} elsif ($line =~ /Westminster of Augusta/){
		      		$inst="pswa";$inst_found=1;
				} elsif ($line =~ /Georgia Highlands College/){
				$inst="flo1";$inst_found=1;
				} elsif ($line =~ /Catoosa County Public Library/){
				$inst="bcat";$inst_found=1;
				} elsif ($line =~ /Coweta County Library/){
				$inst="cwl1";$inst_found=1;
				} elsif ($line =~ /Troup-Harris Regional Library System/){
				$inst="thc1";$inst_found=1;
				} elsif ($line =~ /Worth County Library/){
				$inst="wor1";$inst_found=1;
				} elsif ($line =~ /Weber School/){
				$inst="pswb";$inst_found=1;
				} elsif ($line =~ /Tallulah Falls School/){
				$inst="pstf";$inst_found=1;
				} elsif ($line =~ /St. Martin's Episcopal School/){
				$inst="pssm";$inst_found=1;
				} elsif ($line =~ /Providence Christian Academy/){
				$inst="pspc";$inst_found=1;
				} elsif ($line =~ /Monsignor Donovan Catholic High School/){
				$inst="psmd";$inst_found=1;
				} elsif ($line =~ /Christian Heritage School/){
				$inst="pscr";$inst_found=1;
				} elsif ($line =~ /First Presbyterian Day School/){
				$inst="psfp";$inst_found=1;
				} elsif ($line =~ /Darlington School/){
				$inst="psda";$inst_found=1;
				} elsif ($line =~ /Brookstone School/){
				$inst="psbr";$inst_found=1;
				} elsif ($line =~ /Hope Schools of Excellence/){
				$inst="psho";$inst_found=1;
				} elsif ($line =~ /Lumpkin County Schools/){
				$inst="slum";$inst_found=1;
				} elsif ($line =~ /Mill Springs Academy/){
				$inst="psms";$inst_found=1;
				} elsif ($line =~ /Strong Rock Christian School/){
				$inst="psrc";$inst_found=1;
				} elsif ($line =~ /Trinity Christian School/){
				$inst="pstc";$inst_found=1;
				} elsif ($line =~ /Southern Catholic College/){
				$inst="scc1";$inst_found=1;
				} elsif ($line =~ /DeVry University - Alpharetta/){
				$inst="devi";$inst_found=1;
				} elsif ($line =~ /Beulah Heights University/){
				$inst="bhu1";$inst_found=1;
				} elsif ($line =~ /Rabun Gap-Nacoochee School/){
                                $inst="psrg";$inst_found=1;
				} elsif ($line =~ /Georgia Northwestern/){
				$inst="gnt1";$inst_found=1;	
				} elsif ($line =~ /Atlanta Girls' School/){
				$inst="psat";$inst_found=1;	
				} elsif ($line =~ /Academe of the Oaks/){
				$inst="psao";$inst_found=1;	
				} elsif ($line =~ /The Howard School/){
				$inst="pshw";$inst_found=1;	
				} elsif ($line =~ /Memorial Day School/){
				$inst="psme";$inst_found=1;	
				} elsif ($line =~ /Stratford Academy/){
				$inst="pstr";$inst_found=1;	
				} elsif ($line =~ /Wiregrass Georgia Technical College/){
				$inst="wrgt";$inst_found=1;	
				} elsif ($line =~ /Southern Crescent Technical College/){
				$inst="scre";$inst_found=1;	
				} elsif ($line =~ /Richmont Graduate University/){
				$inst="psin";$inst_found=1;
				} elsif ($line =~ /Oconee Fall Line Technical College/){
				$inst="oftc";$inst_found=1;
				} elsif ($line =~ /Georgia Health Sciences University/){
				$inst="med1";$inst_found=1;
				} elsif ($line =~ /Georgia Piedmont Technical College/){
		      		$inst="dekt";$inst_found=1;
				} elsif ($line =~ /Bethesda Academy/){
		      		$inst="psbe";$inst_found=1;
				} elsif ($line =~ /Cornerstone Christian/){
		      		$inst="psco";$inst_found=1;
				} elsif ($line =~ /Furtah Preparatory/){
		      		$inst="psfu";$inst_found=1;
				} elsif ($line =~ /Georgia Perimeter College/){
		      		$inst="dek1";$inst_found=1;
				} elsif ($line =~ /Harvester Christian/){
		      		$inst="pshc";$inst_found=1;
				} elsif ($line =~ /Heritage School/){
		      		$inst="pshe";$inst_found=1;
				} elsif ($line =~ /Pelham City Schools/){
		      		$inst="spel";$inst_found=1;
				} elsif ($line =~ /Reinhardt University/){
		      		$inst="rei1";$inst_found=1;
				} elsif ($line =~ /Tattnall Square Academy/){
		      		$inst="psts";$inst_found=1;
				} elsif ($line =~ /Terrell County Schools/){
		      		$inst="ster";$inst_found=1;
				} elsif ($line =~ /The Atlanta Academy/){
		      		$inst="psac";$inst_found=1;
				} elsif ($line =~ /The Walker School/){
		      		$inst="pswl";$inst_found=1;
				} elsif ($line =~ /University of North Georgia/){
		      		$inst="nga1";$inst_found=1;
				} elsif ($line =~ /Valdosta State University/){
		      		$inst="val1";$inst_found=1;
				} elsif ($line =~ /Westminster Christian Academy/){
		      		$inst="pswe";$inst_found=1;
				} elsif ($line =~ /Whitefield Academy/){
		      		$inst="pswf";$inst_found=1;
				} elsif ($line =~ /Swift School/){
		      		$inst="pssw";$inst_found=1;
				} elsif ($line =~ /Eagle's Landing/){
		      		$inst="psea";$inst_found=1;
				} elsif ($line =~ /St. Francis Schools/){
		      		$inst="psfc";$inst_found=1;
				} elsif ($line =~ /Ben Franklin Academy/){
		      		$inst="psbf";$inst_found=1;
				} elsif ($line =~ /SCHENCK SCHOOL/){
		      		$inst="pssc";$inst_found=1;
				} elsif ($line =~ /Emory University - emu1/){
		      		$inst="emu1";$inst_found=1;
		    	  	} #end if
				
				if ($inst_found){
	                @vars = csv_split( $line );
                    #@vars = split /,/,$line;
					$inst =~ tr/[a-z]/[A-Z]/;
				} #end if inst_found true
                else {
                    print "Inst not found\n";
		    # print $line;
                }
			} #end if
			$tmp="";
			$inst_found=0;
	  		$inst =~ tr/[a-z]/[A-Z]/;
			foreach my $obsrv(@keys) {
				#print"obsrv=$obsrv\n";
				#print"db_index{obsrv}=$db_index{$obsrv}\n";
				$fulltext_total=0;
				if (defined $vars[$db_index{$obsrv}]){
					$fulltext_total=$vars[$db_index{$obsrv}];
				}
				#print"fulltext_total=$fulltext_total\n";
				$next=$db_index{$obsrv};
				$next++;
				$searches_total=0;
				if (defined $vars[$next]) {
					$searches_total=$vars[$next];
				}
				#print"searches_total=$searches_total\n";
					if ($fulltext_total > 0){
						$type="B F";
						$outline = $date . " " . $inst . " " . $type . " " . $obsrv . " " . $fulltext_total . "\n";
						print FULLTEXT $outline;
						$outline ="";
						$fulltext_total=0;
					} #end if
					if ($searches_total > 0 ){
						$type="B Q";
						$outline = $date . " " . $inst . " " . $type . " " . $obsrv . " " . $searches_total . "\n";
						print SEARCHES $outline;
						$outline="";
						$searches_total=0;
					} #end if
				$next="";
			} #end foreach
			@vars=();
		} #end while
		close(FULLTEXT);
		close(SEARCHES);
		close(INFILE);
		`sort -o $temp_searches_file $temp_searches_file`;		
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -m -o $searches_file $searches_file $temp_searches_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
	} #end foreach
} #end britannica_stats_build

#################################################################
# subroutine: sirs_stats_build
#################################################################
sub sirs_stats_build {
	my $temp_citation_file = $data_dir."stats/temp_stats_monthly_sirs_citation_data";
	my $temp_keyword_search_file = $data_dir."stats/temp_stats_monthly_sirs_keyword_search_data";
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_sirs_fulltext_data";
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_sirs_sessions_data";
	#my $citation_file = $data_dir."stats/stats_monthly_sirs_citation_data";
	my $citation_file = $data_dir."stats/stats_monthly_sirs_citation_data_new";
	#my $keyword_search_file = $data_dir."stats/stats_monthly_sirs_keyword_search_data";
	my $keyword_search_file = $data_dir."stats/stats_monthly_sirs_keyword_search_data_new";
	#my $fulltext_file = $data_dir."stats/stats_monthly_sirs_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_sirs_fulltext_data_new";
	#my $sessions_file = $data_dir."stats/stats_monthly_sirs_sessions_data";
	my $sessions_file = $data_dir."stats/stats_monthly_sirs_sessions_data_new";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/sirs_stats";	
	my @data_files = <$raw_data_dir/*>;
	my @vars=();
	my %inst_code_lookup=();
	my $ZSKS_citation_index=14;
	my $ZSSD_citation_index=27;
	my $ZSKS_fulltext_1_index=5;
	my $ZSKS_fulltext_2_index=12;
	my $ZSSD_fulltext_1_index=20;
	my $ZSSD_fulltext_2_index=25;
	my $ZSKS_searches_index=6;
	my $ZSSD_searches_index=21;
	my $ZSKS_sessions_index=4;
	my $ZSSD_sessions_index=19;
	my ($ZSKS_fulltext,$ZSKS_keyword_search,$ZSKS_browse_search,$ZSKS_citation,$ZSSD_fulltext,$ZSSD_keyword_search,$ZSSD_browse_search,$ZSSD_citation,$ZSKS_sessions,$ZSSD_sessions,$length,$header_found)=0; 
	my ($line,$file,$date,$file_name,$zip_file,$inst_code,$inst,$temp,$temp1)="";
	### Make back ups of old datafiles ###
	if (-e $keyword_search_file) {
		system("$makebak","$keyword_search_file");
	} #end if
    	if (-e $citation_file) {
		system("$makebak","$citation_file");
	} #end if
    	if (-e $fulltext_file) {
		system("$makebak","$fulltext_file");
	} #end if
    	if (-e $sessions_file) {
		system("$makebak","$sessions_file");
	} #end if
	open(ACADEM,"SIRS_Lib_Academ_Table.txt");
	open(K12,"SIRS_K12_Table.txt");
	open(MISSING,"SIRS_Missing_Users_Cust_Nos.txt");
	#MISSING has no meaning other than missing from the 
	#first two files.
	### load inst code lookup
	while(<ACADEM>){
		$line=$_;
                $line =~ s/"//g;
	    @vars = csv_split( $line );
        #@vars = split /,/,$line;
		$vars[1] =~ tr/[a-z]/[A-Z]/;
		chomp($vars[1]);
		chomp($vars[2]);
		#print"inst_code_lookup{$vars[2]}=$vars[1]\n";
		$inst_code_lookup{$vars[2]}=$vars[1];
	} #end while to load instcode data from academ
	while(<K12>){
		$line=$_;
                $line =~ s/"//g;
	    @vars = csv_split( $line );
        #@vars = split /,/,$line;
		$vars[1] =~ tr/[a-z]/[A-Z]/;
		chomp($vars[1]);
		chomp($vars[2]);
		$inst_code_lookup{$vars[2]}=$vars[1];
	} #end while to load instcode data from k12
	while(<MISSING>){
		$line=$_;
                $line =~ s/"//g;
	    @vars = csv_split( $line );
        #@vars = split /,/,$line;
		$vars[2] =~ tr/[a-z]/[A-Z]/;
		chomp($vars[0]);
		chomp($vars[2]);
		$inst_code_lookup{$vars[0]}=$vars[2];
	} #end while to load instcode data from missing
	close(K12);
	close(ACADEM);
	close(MISSING);
	### main routine ###
	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/sirs_stats\///;
		print"loading data from $temp\n";
		$temp="";
		$date=$file;
		chomp($date);
		if ($date =~ /K12/){
			$date =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/sirs_stats\/SIRS_Usage_K12_//;
		} elsif ($date =~ /Libs_Academ/){
			$date =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/sirs_stats\/SIRS_Usage_Libs_Academ_//;
		} elsif ($date =~ /Admin/){
			$date =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/sirs_stats\/SIRS_Usage_Admin_//;
		} elsif ($date =~ /GPLS/){
			$date =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/sirs_stats\/SIRS_Usage_GPLS_//;
		} #end if
		$date = "m".$date;
		$date =~ s/.csv//;
		open(FULLTEXT,">$temp_fulltext_file");
		open(KEYWORD,">$temp_keyword_search_file");
		open(CITATION,">$temp_citation_file");
		open(SESSIONS,">$temp_sessions_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line=$_;
                        $line =~ s/"//g;
			if ($header_found){
	            @vars = csv_split( $line );
                #@vars = split /,/,$line;
				$length = @vars;
				$inst_code = $vars[1];
				if((exists ($inst_code_lookup{$inst_code})) && $length>=26){
					$inst=$inst_code_lookup{$inst_code};
					#print"inst=$inst\n";
					$ZSKS_fulltext=$vars[$ZSKS_fulltext_1_index] ;#if defined $vars[$ZSKS_fulltext_1_index];
					$ZSKS_fulltext=$ZSKS_fulltext+$vars[$ZSKS_fulltext_2_index] ;#if defined $vars[$ZSKS_fulltext_2_index];
					$ZSKS_keyword_search=$vars[$ZSKS_searches_index] ;#if defined $vars[$ZSKS_searches_index];
					$ZSKS_citation=$vars[$ZSKS_citation_index] ;#if defined $vars[$ZSKS_citation_index];
					$ZSKS_sessions=$vars[$ZSKS_sessions_index] ;#if defined $vars[$ZSKS_sessions_index];
					$ZSSD_fulltext=$vars[$ZSSD_fulltext_1_index] ;#if defined $vars[$ZSSD_fulltext_1_index];
					$ZSSD_fulltext=$ZSSD_fulltext+$vars[$ZSSD_fulltext_2_index] ;#if defined $vars[$ZSSD_fulltext_2_index];
					$ZSSD_keyword_search=$vars[$ZSSD_searches_index] ;#if defined $vars[$ZSSD_searches_index];
					$ZSSD_citation=$vars[$ZSSD_citation_index] ;#if defined $vars[$ZSSD_citation_index];
					$ZSSD_sessions=$vars[$ZSSD_sessions_index] ;#if defined $vars[$ZSSD_sessions_index];
					if ($ZSKS_fulltext>0){
						$temp = $date." ".$inst." S F ZSKS ".$ZSKS_fulltext."\n";
						print FULLTEXT $temp;
						$temp="";
					}
					if ($ZSSD_fulltext>0){
						$temp = $date." ".$inst." S F ZSSD ".$ZSSD_fulltext."\n";
						print FULLTEXT $temp;
						$temp="";
					}

					if ($ZSKS_keyword_search>0){
						$temp=$date." ".$inst." S S ZSKS ".$ZSKS_keyword_search."\n";
						print KEYWORD $temp;
						$temp="";
					}
					if ($ZSSD_keyword_search>0){
						$temp=$date." ".$inst." S S ZSSD ".$ZSSD_keyword_search."\n";
						print KEYWORD $temp;
						$temp="";
					}


					if ($ZSKS_citation>0){
						$temp=$date." ".$inst." S D ZSKS ".$ZSKS_citation."\n";
						print CITATION $temp;
						$temp="";
					}
					if ($ZSSD_citation>0){
						$temp=$date." ".$inst." S D ZSSD ".$ZSSD_citation."\n";
						print CITATION $temp;
						$temp="";
					}
					if ($ZSKS_sessions>0){
						$temp=$date." ".$inst." S A ZSKS ".$ZSKS_sessions."\n";
						print SESSIONS $temp;
						$temp="";
					}
					if ($ZSSD_sessions>0){
						$temp=$date." ".$inst." S A ZSSD ".$ZSSD_sessions."\n";
						print SESSIONS $temp;
						$temp="";
					}
					$temp="";
					($ZSKS_fulltext,$ZSKS_keyword_search,$ZSKS_browse_search,$ZSKS_citation,$ZSKS_sessions,$ZSSD_fulltext,$ZSSD_keyword_search,$ZSSD_browse_search,$ZSSD_citation,$ZSSD_sessions)=0; 
				} #end if
			} #end if
			if (!($header_found)){
				$line =~ tr /A-Z/a-z/;	
				$line =~ s/ //g;
				$line =~ s/\///g;
				if ($line =~ /institution/){
					$header_found=1;
					print"header found\n";
				} #end if line contains institution
			} #end if header not found
		}#end while to work on lines in file 
		$header_found=0;
		close(FULLTEXT);
		close(CITATION);
		close(KEYWORD);
		close(SESSIONS);
		close(INFILE);
		`sort -o $temp_keyword_search_file $temp_keyword_search_file`;
		`sort -o $temp_citation_file $temp_citation_file`;
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -o $temp_sessions_file $temp_sessions_file`;
		`sort -m -o $keyword_search_file $keyword_search_file $temp_keyword_search_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		`sort -m -o $citation_file $citation_file $temp_citation_file`;
		`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
	} #end foreach @data_files
} #end sirs_stats_build

#################################################################
# subroutine: firstsearch_stats_build
#################################################################
sub firstsearch_stats_build {
	my $temp_keyword_search_file = $data_dir."stats/temp_stats_monthly_firstsearch_keyword_search_data";
	#my $keyword_search_file = $data_dir."stats/stats_monthly_firstsearch_keyword_search_data";
	my $keyword_search_file = $data_dir."stats/stats_monthly_firstsearch_keyword_search_data_new";

  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/firstsearch_stats";	
	my @data_files = <$raw_data_dir/*>;
	my @vars=();
	my %inst_code_lookup=();
	my %db_code_lookup=();
	my ($line,$file,$date,$file_name,$zip_file,$inst_code,$inst,$temp,$value)="";
	my $past_top=0;
	open(INST,"firstsearch_institutions.txt");
	while(<INST>){
		$line=$_;
		@vars = split /,/,$line;
		$vars[1] =~ tr/[a-z]/[A-Z]/;
		$inst_code_lookup{$vars[0]}=$vars[1];
	}

#	my %db_index=(
#	"ZOSR" => "4",
#	"ZOCP" => "6",
#	"ZOER" => "7",
#	"ZOBO" => "8",
#	"ZOEC" => "9",
#	"ZOG1" => "10",
#	"ZOGC" => "11",
#	"ZOMD" => "12",
#	"ZOPI" => "13",
#	"ZOP1" => "14",
#	"ZORL" => "15",
#	"ZOWA" => "16",
#	"ZOWC" => "17",
#   "ZODT" => "18");

	my %db_index=(
	"ZOSR" => "4",
	"ZOBD" => "5",
	"ZOCP" => "6",
	"ZOER" => "7",
	"ZOEC" => "9",
	"ZOG1" => "10",
	"ZOMD" => "12",
	"ZOAI" => "13",
	"ZOPI" => "14",
	"ZOP1" => "15",
	"ZORL" => "16",
	"ZOWA" => "17",
	"ZOWC" => "18",
	"ZODT" => "19");

	my @db_keys=keys %db_index;

	### Make back ups of old datafiles ###
	if (-e $keyword_search_file) {
		system("$makebak","$keyword_search_file");
	} #end if
	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/firstsearch_stats\///;
		print"loading data from $temp\n";
		$date=$temp;
		$temp="";
		chomp($date);
		$date =~ s/fs_consortiumInstDatabaseSummary--GUA1--//;
		$date =~ s/.csv//;
		$date = "m".$date;
		open(KEYWORD,">$temp_keyword_search_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line=$_;
			if ($past_top){
				if ($line =~ /",/){
					$line =~ s/"//g;	
					$line =~ s/,/-/;
				} #end if
				@vars = split /,/,$line;
				$inst_code = $vars[1];
				chomp($inst_code);
				if(exists ($inst_code_lookup{$inst_code})){
					$inst=$inst_code_lookup{$inst_code};
					chomp($inst);
					foreach my $obsrv(@db_keys){
						if($vars[$db_index{$obsrv}]>0){
							$value = $vars[$db_index{$obsrv}];
							chomp($value);
							$temp=$date." ".$inst." F Z ".$obsrv." ".$value."\n";
							print KEYWORD $temp;
							$temp="";
						} #end if
					} #end foreach 
				} #end if
			} #end if
			if ($line=~/Total:/){
				$past_top=1;
			}
		}#end while to work on lines in file 
		close(KEYWORD);
		close(INFILE);
		`sort -o $temp_keyword_search_file $temp_keyword_search_file`;
		`sort -m -o $keyword_search_file $keyword_search_file $temp_keyword_search_file`;
	} #end foreach @data_files

} #end firstsearch_stats_build


#################################################################
# subroutine: ebrary_stats_build
#################################################################
sub ebrary_stats_build {
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_ebrary_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_ebrary_fulltext_data_new";
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_ebrary_sessions_data";
	my $sessions_file = $data_dir."stats/stats_monthly_ebrary_sessions_data_new";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/ebrary";	
	my ($line,$file,$date,$file_name,$zip_file,$inst_code,$inst,$temp,$temp2,$temp_line,$line_out,$match)="";
	my ($past_top,$ebook_central,$quote_found,$comma_found,$fulltext_count,$sessions_count,$line_nu,$just_free)=0;
	my @data_files = <$raw_data_dir/*>;
	my @vars=();
	my @temp_vars=();
	my @line_chars=();
	my %inst_code_lookup=();

	### Make back ups of old datafiles ###
    	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	} #end if
    	if ((-e $sessions_file) && (!($opt_n))){
		system("$makebak","$sessions_file");
	} #end if
	open(INSTDATA,"ebrary_stats_institutions.txt");
	while (<INSTDATA>) {
		$line=$_;
		@vars = split /",/,$line;
		$vars[0] =~ tr/[a-z]/[A-Z]/;
		$vars[1] =~ tr/[a-z]/[A-Z]/;
		$vars[0] =~ s/"//g;
		$vars[1] =~ s/"//g;
		$vars[1] =~ s/ //g;
		chomp($vars[0]);
		chomp($vars[1]);
		#??#print"inst_code_lookup{$vars[1]}=$vars[0]\n";
		$inst_code_lookup{$vars[1]}=$vars[0];
	} #end while
	close(INSTDATA);
	@vars=();
	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/ebrary\///;
		print"loading data from $temp\n";
		$date=$temp;
		chomp($date);
		$date =~ s/_ebrary.csv//;
		$date =~ s/.csv//;	
		$date = "m".$date;
		open(FULLTEXT, ">$temp_fulltext_file");
		open(SESSIONS, ">$temp_sessions_file");
		open(INFILE,"$file");
		$temp="";
		while(<INFILE>){
			$line=$_;
			if ($past_top){
				# line below parses out "5,000" to 5000 for example
				$line =~ s/"([^"]+)"/($match = $1) =~ (s:,::g);$match;/ge;
				#print"$line\n";
				@vars = split /,/,$line;		
				$vars[2] =~ tr/[a-z]/[A-Z]/;
				$vars[2] =~ s/ //g;
				$inst=$inst_code_lookup{$vars[2]};
				$fulltext_count=$vars[3];
				$fulltext_count=$fulltext_count + $vars[9];
				$sessions_count=$vars[7];
				if ($fulltext_count > 0){
					$line_out = $date . " " . $inst . " Y F EBPR " . $fulltext_count . "\n";
					#??#print"fulltext line=$line_out\n";
					print FULLTEXT $line_out;
					$fulltext_count=0;
				} #end if	
				if ($sessions_count > 0){
					$line_out = $date . " " . $inst . " Y A EBPR " . $sessions_count . "\n";
					#??#print"sessions line=$line_out\n";
					print SESSIONS $line_out;
					$sessions_count=0;
				} #end if
				@vars=();
				@temp_vars=();
				$temp="";
				$temp2="";
				$temp_line="";
				$line_out="";
			} #end if
			if (($line=~/ChannelUsed/) || ($line=~/Channel Used/)){
				$past_top=1;
			} #end if
			$sessions_count=0;
			$fulltext_count=0;
		} #end while
		close(INFILE);
		close(FULLTEXT);
		close(SESSIONS);
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		`sort -o $temp_sessions_file $temp_sessions_file`;
		`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
		$past_top=0;
	} #end foreach file
} #end ebrary_stats_build

#################################################################
# subroutine: ebookcentral_stats_build
#################################################################
sub ebookcentral_stats_build {
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_ebookcentral_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_ebookcentral_fulltext_data_new";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/ebookcentral";	
	my ($line,$file,$date,$file_name,$zip_file,$inst_code,$inst,$temp,$temp2,$temp_line,$line_out,$match)="";
	my ($past_top,$quote_found,$comma_found,$fulltext_count,$line_nu)=0;
	my @data_files = <$raw_data_dir/*>;
	my @vars=();
	my @temp_vars=();
	my @line_chars=();
	my %inst_code_lookup=();

	### Make back ups of old datafiles ###
    	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	} #end if
	open(INSTDATA,"ebookcentral_stats_institutions.txt");
	while (<INSTDATA>) {
		$line=$_;
	    @vars = csv_split( $line );
        #@vars = split /",/,$line;
		$vars[0] =~ tr/[a-z]/[A-Z]/;
		$vars[1] =~ tr/[a-z]/[A-Z]/;
        #$vars[0] =~ s/"//g;
        #$vars[1] =~ s/"//g;
		$vars[1] =~ s/ //g;
		chomp($vars[0]);
		chomp($vars[1]);
		#??#print"inst_code_lookup{$vars[1]}=$vars[0]\n";
		$inst_code_lookup{$vars[1]}=$vars[0];
	} #end while
	close(INSTDATA);
	@vars=();
	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/ebookcentral\///;
		print"loading data from $temp\n";
		$date=$temp;
		chomp($date);
		$date =~ s/EBC_//;
		$date =~ s/.csv//;	
		$date = "m".$date;
		open(FULLTEXT, ">$temp_fulltext_file");
		open(INFILE,"$file");
		$temp="";
		while(<INFILE>){
			$line=$_;
			#print"$line\n";
	        @vars = csv_split( $line );
            #@vars = split /,/,$line;		
			$vars[0] =~ tr/[a-z]/[A-Z]/;
			$vars[0] =~ s/ //g;
			$inst=$inst_code_lookup{$vars[0]};
			$fulltext_count=$vars[1];
			chomp($fulltext_count);
			if( $inst and ( $fulltext_count > 0 ) ){
				$line_out = $date . " " . $inst . " Y F EBCN " . $fulltext_count . "\n";
				print FULLTEXT $line_out;
				$fulltext_count=0;
			}
			@vars=();
			$fulltext_count=0;
		}
		close(INFILE);
		close(FULLTEXT);
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		$past_top=0;
	} #end foreach file
} #end ebookcentral_stats_build

#################################################################
# subroutine learning_express_stats_build
#################################################################
sub learning_express_stats_build{
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_learning_express_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_learning_express_fulltext_data_new";
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_learning_express_sessions_data";
	my $sessions_file = $data_dir."stats/stats_monthly_learning_express_sessions_data_new";
	my($file,$temp,$date,$inst,$line,$line_out)="";
	my ($past_top,$fulltext_total,$fulltext_count,$session_count)=0;

  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/learning_express";	
	my @data_files = <$raw_data_dir/*>;
	my @vars=();
	
	### Make back ups of old datafiles ###
    	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	} #end if
    	if ((-e $sessions_file) && (!($opt_n))){
		system("$makebak","$sessions_file");
	} #end if

	foreach $file(@data_files){

		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/learning_express\///;
		print"loading data from $temp\n";
		$date=$temp;
		$temp="";
		chomp($date);
		$date =~ s/LearningExpress_Detailed_Usage_Report_Table_//;
		$date =~ s/.csv//;
		$date = "m".$date;
		open(FULLTEXT, ">$temp_fulltext_file");
		open(SESSIONS, ">$temp_sessions_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line = $_;
	    	@vars = csv_split( $line );
            #@vars = split /,/,$line;
			if($past_top){
				$vars[3] =~ tr/[a-z]/[A-Z]/;
				$inst = $vars[3];
				$session_count = $vars[5];
				$fulltext_count = $vars[7];
				$fulltext_total = $fulltext_total + $fulltext_count;
				$fulltext_count = $vars[8];
				$fulltext_total = $fulltext_total + $fulltext_count;
				$fulltext_count = $vars[9];
				$fulltext_total = $fulltext_total + $fulltext_count;
				$fulltext_count = $vars[10];
				$fulltext_total = $fulltext_total + $fulltext_count;
				$fulltext_count = $vars[11];
				$fulltext_total = $fulltext_total + $fulltext_count;
				if ($fulltext_total > 0){
					$line_out = $date . " " . $inst . " X F ZXLE " . $fulltext_total . "\n";
					#print"$line_out\n";
					print FULLTEXT $line_out;
					$fulltext_total=0;
					$fulltext_count=0;
				} #end if
				if ($session_count > 0){
					$line_out = $date . " " . $inst . " X A ZXLE " . $session_count . "\n";
					#print"$line_out\n";
					print SESSIONS $line_out;
					$session_count=0;
				} #end if
			} #end if to parse file
			if($line =~ /InstitutionName/){
				$past_top=1;
			} #end past first line 
		} #end while
		close(INFILE);
		close(FULLTEXT);
		close(SESSIONS);
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		`sort -o $temp_sessions_file $temp_sessions_file`;
		`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
		$past_top=0;
	} #end foreach
} #end learning_express_stats_build

#################################################################
# subroutine FOD_stats_build
# Films On Demand
#################################################################
sub FOD_stats_build {
	print "FOD_stats_build called\n";
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_films_on_demand_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_films_on_demand_fulltext_data_new";
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_films_on_demand_sessions_data";
	my $sessions_file = $data_dir."stats/stats_monthly_films_on_demand_sessions_data_new";
	my $temp_searches_file = $data_dir."stats/temp_stats_monthly_films_on_demand_searches_data";
	my $searches_file = $data_dir."stats/stats_monthly_films_on_demand_searches_data_new";
	my $tech_inst_code = $data_dir."stats/FOD_Stats_Key_Tech.csv";
	my $usg_inst_code = $data_dir."stats/FOD_Stats_Key_USG.csv";

	my($file,$temp,$date,$inst,$line,$line_out)="";
	my ($past_top,$fulltext_count,$sessions_count,$searches_count)=0;

  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/films_on_demand";	
	my @data_files = <$raw_data_dir/*>;
	my @vars=();
	my %inst_code_data=();
	
	### Make back ups of old datafiles ###
    	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	} #end if
    	if ((-e $sessions_file) && (!($opt_n))){
		system("$makebak","$sessions_file");
	} #end if
    	if ((-e $searches_file) && (!($opt_n))){
		system("$makebak","$searches_file");
	} #end if

	### read in inst code key hash
	open(TECH_INST,"$tech_inst_code");
	while(<TECH_INST>){
		$line=$_;
		@vars = csv_split( $line );
        #@vars = split /,"/,$line;
        #$vars[2] =~ s/"//g;
		$vars[2] =~ tr/[a-z]/[A-Z]/;
		$inst_code_data{$vars[0]}=$vars[2];
	} #end while to read in Tech inst data
	close(TECH_INST);
	@vars=();

	open(USG_INST,"$usg_inst_code");
	while(<USG_INST>){
		$line=$_;
		@vars = csv_split( $line );
        #@vars = split /,"/,$line;
        #$vars[2] =~ s/"//g;
		$vars[2] =~ tr/[a-z]/[A-Z]/;
		$inst_code_data{$vars[0]}=$vars[2];
	} #end while to read in Tech inst data
	close(USG_INST);
	@vars=();

	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/films_on_demand\///;
		print"loading data from $temp\n";
		$date=$temp;
		$temp="";
		chomp($date);
		# get date from files
		if ($date =~ /FOD_Tech/){
			$date =~ s/FOD_Tech_//;
			$date =~ s/.csv//;
		} elsif ($date =~ /FOD_USG/){
			$date =~ s/FOD_USG_//;
			$date =~ s/.csv//;
		} else {
			print "Check file name format. Date not found.\n";
			exit;
		} # end if to find date
		$date = "m".$date;
		open(FULLTEXT, ">$temp_fulltext_file");
		open(SESSIONS, ">$temp_sessions_file");
		open(SEARCHES, ">$temp_searches_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line=$_;
			if ($past_top){
				#??# print"past top\n";
		        @vars = csv_split( $line );
				if(defined($inst_code_data{$vars[0]})){
					$inst=$inst_code_data{$vars[0]};
					$sessions_count=$vars[2];
					$searches_count=$vars[3];
					$fulltext_count=$vars[4];
					if($sessions_count>0){
						$line_out=$date." ".$inst. " C A ZFOD ".$sessions_count."\n";
						print SESSIONS $line_out;
						$line_out="";	
					} #end if			
					if($fulltext_count>0){
						$line_out=$date." ".$inst. " C F ZFOD ".$fulltext_count."\n";
						print FULLTEXT $line_out;
						$line_out="";	
					} #end if			
					if($searches_count>0){
						$line_out=$date." ".$inst. " C S ZFOD ".$searches_count."\n";
						print SEARCHES $line_out;
						$line_out="";	
					} #end if			
				} #end if
			} elsif( $line =~ /AccountID/){
				$past_top=1;
			} #end if

		} #end while	

		close(INFILE);
		close(FULLTEXT);
		close(SESSIONS);
		close(SEARCHES);
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		`sort -o $temp_sessions_file $temp_sessions_file`;
		`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
		`sort -o $temp_searches_file $temp_searches_file`;
		`sort -m -o $searches_file $searches_file $temp_searches_file`;
		$past_top=0;
	} #end foreach
} #end sub FOD_stats_build


#################################################################
# subroutine tumblebooks_stats_build
# TumbleBooks
#################################################################
sub tumblebooks_stats_build{

	print "tumblebooks_stats_build called\n";
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_tumblebooks_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_tumblebooks_fulltext_data_new";
	my $inst_code = $data_dir."stats/TumbleBooks_Stats_Key.csv";

	my($file,$temp,$temp2,$date,$inst,$line,$line_out)="";
	my ($past_top,$fulltext_count)=0;

  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/tumble_books";	
	my @data_files = <$raw_data_dir/*>;
	my @vars=();
	my %inst_code_data=();
	
	### Make back ups of old datafiles ###
    	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	} #end if

	### read in inst code key hash
	open(INST,"$inst_code");
	while(<INST>){
		$line=$_;
		if (!($line =~ /GALILEO Name/)){
		    @vars = csv_split( $line );
            #@vars = split /,"/,$line;
            #$vars[1] =~ s/"//g;
            #$vars[2] =~ s/"//g;
			$vars[1] =~ tr/[a-z]/[A-Z]/;
			$vars[2] =~ tr/[a-z]/[A-Z]/;
			$vars[2] =~ s/ //g;
			$inst_code_data{$vars[2]}=$vars[1];
			#??#print"$vars[2] key for $vars[1]\n";
		} #end if
	} #end while to read in Tech inst data
	close(INST);
	@vars=();
	#??#exit;

	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/tumble_books\///;
		print"loading data from $temp\n";
		$date=$temp;
		$temp="";
		chomp($date);
		# get date from files
		if ($date =~ /Tumblebooks/){
			$date =~ s/Tumblebooks_//;
			$date =~ s/.csv//;
		} else {
			print "Check file name format. Date not found.\n";
			exit;
		} # end if to find date
		$date = "m".$date;
		open(FULLTEXT, ">$temp_fulltext_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line=$_;
			chomp($line);
			$fulltext_count=0;
			if ($past_top){
				#??# print"past top\n";
		        @vars = csv_split( $line );
                #@vars=split /,/,$line;	
				$vars[0] =~ tr/[a-z]/[A-Z]/;
				$vars[0] =~ s/ //g;
				if(defined($inst_code_data{$vars[0]})){
					$inst=$inst_code_data{$vars[0]};
					$fulltext_count=$vars[2];
					#??#print"fulltext_count=$fulltext_count\n";
					if(defined $fulltext_count){
						if($fulltext_count>0){
							$line_out=$date." ".$inst. " T F ZTBO ".$fulltext_count."\n";
							print FULLTEXT $line_out;
							$line_out="";	
						} #end if 
					} #end if			
				} #end if
			} elsif( $line =~ /Library,Username/){
				$past_top=1;
			} #end if

		} #end while	

		close(INFILE);
		close(FULLTEXT);
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		$past_top=0;
	} #end foreach
} #end tumblebooks_stats_build

#################################################################
# subroutine mango_stats_build code: ango
#################################################################
sub mango_stats_build{
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_mango_sessions_data";
	my $sessions_file = $data_dir."stats/stats_monthly_mango_sessions_data_new";
	my $inst_key_file = $data_dir."stats/Mango_Key_Information.txt";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/mango";	
	my @data_files = <$raw_data_dir/*>;
	my %inst_code_data=();
	my @vars=();
	my($file,$temp,$temp2,$date,$inst,$line,$line_out)="";
	my ($past_top,$sessions_count)=0;

	### Make back ups of old datafiles ###
    	if ((-e $sessions_file) && (!($opt_n))) {
		system("$makebak","$sessions_file");
	} #end if


	### read in inst code key hash
	open(INST,"$inst_key_file");
	while(<INST>){
		$line=$_;
		@vars = csv_split( $line );
        #@vars = split /,"/,$line;
        #$vars[0] =~ s/"//g;
        #$vars[1] =~ s/"//g;
		$vars[0] =~ tr/[a-z]/[A-Z]/;
		$vars[1] =~ tr/[a-z]/[A-Z]/;
		$vars[0] =~ s/ //g;
		$inst_code_data{$vars[0]}=$vars[1];
		#??#print"$vars[0] key for $vars[1]\n";
	} #end while to read in Tech inst data
	close(INST);
	@vars=();
	#??#exit;
	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/mango\///;
		print"loading data from $temp\n";
		$date=$temp;
		$temp="";
		chomp($date);
		# get date from files
		if ($date =~ /Mango/){
			$date =~ s/Mango//;
			$date =~ s/_//;
			$date =~ s/.csv//;
		} else {
			print "Check file name format. Date not found.\n";
			exit;
		} # end if to find date
		$date = "m".$date;
		open(SESSIONS, ">$temp_sessions_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line=$_;
			chomp($line);
			$sessions_count=0;
			#if ($past_top){
				#??# print"past top\n";
		        @vars = csv_split( $line );
                #@vars=split /,/,$line;	
				$vars[0] =~ tr/[a-z]/[A-Z]/;
				$vars[0] =~ s/ //g;
				if(defined($inst_code_data{$vars[0]})){
					$inst=$inst_code_data{$vars[0]};
					$sessions_count=$vars[1];
					print"sessions_count=$sessions_count\n";
					if(defined $sessions_count){
						if($sessions_count>0){
							$line_out=$date." ".$inst. " O A ANGO ".$sessions_count."\n";
							print SESSIONS $line_out;
							$line_out="";	
						} #end if 
					} #end if			
				} #end if
			#} elsif(( $line =~ /Month,Year,Uses/) || ($line !~ /Month,Year,Uses/)){
			#	$past_top=1;
			#} #end if

		} #end while	

		close(INFILE);
		close(SESSIONS);
		`sort -o $temp_sessions_file $temp_sessions_file`;
		`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
		$past_top=0;
	} #end foreach
} #end mango_stats_build


#################################################################
# subroutine galelf_stats_build code: zglf
#################################################################
sub galelf_stats_build{
	my $temp_sessions_file = $data_dir."stats/temp_stats_monthly_galelf_sessions_data";
	my $sessions_file = $data_dir."stats/stats_monthly_galelf_sessions_data_new";
	my $inst_key_file = $data_dir."stats/Gale_LegalForm_Key_Information.txt";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/gale_lf";	
	my @data_files = <$raw_data_dir/*>;
	my %inst_code_data=();
	my @vars=();
	my($file,$temp,$temp2,$date,$inst,$line,$line_out)="";
	my ($past_top,$sessions_count)=0;

	### Make back ups of old datafiles ###
    	if ((-e $sessions_file) && (!($opt_n))) {
		system("$makebak","$sessions_file");
	} #end if


	### read in inst code key hash
	open(INST,"$inst_key_file");
	while(<INST>){
		$line=$_;
		@vars = csv_split( $line );
        #@vars = split /,"/,$line;
        #$vars[0] =~ s/"//g;
        #$vars[1] =~ s/"//g;
        #$vars[2] =~ s/"//g;
        #chomp($vars[2]);
        #$vars[2] =~ s/,//g;
		$vars[0] =~ tr/[a-z]/[A-Z]/;
		$vars[2] =~ tr/[a-z]/[A-Z]/;
		$vars[0] =~ s/ //g;
		$inst_code_data{$vars[0]}=$vars[2];
		#??#print"$vars[0] key for $vars[1]\n";
	} #end while to read in Tech inst data
	close(INST);
	@vars=();
	#??#exit;
	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/gale_lf\///;
		print"loading data from $temp\n";
		$date=$temp;
		$temp="";
		chomp($date);

		# get date from files
		if ($date =~ /_Gale/){
			$date =~ s/_GaleLegalForms.csv//;
			#$date =~ s/.csv//;
		}
        elsif ( $date =~/^Gale/ ) {
			$date =~ s/GaleLegalForms_//;
			$date =~ s/.csv//;
		}
        else {
			print "Check file name format. Date not found.\n";
			exit;
		} # end if to find date

		$date = "m".$date;
		#??#print"date=$date\n";
		open(SESSIONS, ">$temp_sessions_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line=$_;
            $line =~ s{\r\n$}{\n};
			chomp($line);
			$sessions_count=0;
			if ($past_top){
				#??# print"past top\n";
		        @vars = csv_split( $line );
                #@vars=split /,/,$line;	
				$vars[0] =~ tr/[a-z]/[A-Z]/;
				$vars[0] =~ s/ //g;
				if(defined($inst_code_data{$vars[0]})){
					$inst=$inst_code_data{$vars[0]};
					$sessions_count=$vars[1];
					chomp($sessions_count);
					$sessions_count =~ s/,//g;
					#??#print"sessions_count=$sessions_count\n";
					if(defined $sessions_count){
						if($sessions_count>0){
							$line_out=$date." ".$inst. " G A ZGLF ".$sessions_count."\n";
							print SESSIONS $line_out;
							$line_out="";	
						} #end if 
					} #end if			
				} #end if
			} elsif(( $line =~ /Row Labels/) || ($line =~ /Retrievals/)) {
				$past_top=1;
			} #end if

		} #end while	

		close(INFILE);
		close(SESSIONS);
		`sort -o $temp_sessions_file $temp_sessions_file`;
		`sort -m -o $sessions_file $sessions_file $temp_sessions_file`;
		$past_top=0;
	} #end foreach

} #end galelf_stats_build

#################################################################
# subroutine tumblecloud_stats_build code: ztbc
#################################################################
sub tumblecloud_stats_build{
	my $temp_fulltext_file = $data_dir."stats/temp_stats_monthly_tumblecloud_fulltext_data";
	my $fulltext_file = $data_dir."stats/stats_monthly_tumblecloud_fulltext_data_new";
	my $inst_key_file = $data_dir."stats/TumbleCloud_Key_Information.txt";
  	my $raw_data_dir = $data_dir . "ftp/galileo_stats/tumble_cloud";	
	my @data_files = <$raw_data_dir/*>;
	my %inst_code_data=();
	my @vars=();
	my($file,$temp,$temp2,$date,$inst,$line,$line_out)="";
	my ($past_top,$fulltext_count)=0;

	### Make back ups of old datafiles ###
    	if ((-e $fulltext_file) && (!($opt_n))) {
		system("$makebak","$fulltext_file");
	} #end if


	### read in inst code key hash
	open(INST,"$inst_key_file");
	while(<INST>){
		$line=$_;
		@vars = csv_split( $line );
        #@vars = split /,"/,$line;
        #$vars[0] =~ s/"//g;
        #$vars[1] =~ s/"//g;
        #$vars[2] =~ s/"//g;
        #chomp($vars[2]);
        #$vars[2] =~ s/,//g;
		$vars[0] =~ tr/[a-z]/[A-Z]/;
		$vars[2] =~ tr/[a-z]/[A-Z]/;
		$vars[0] =~ s/ //g;
		$inst_code_data{$vars[0]}=$vars[2];
		#??#print"$vars[0] key for $vars[2]\n";
	} #end while to read in Tech inst data
	close(INST);
	@vars=();
	#??#exit;
	foreach $file(@data_files){
		$temp = $file;
		$temp =~ s/\/ss\/dbs\/stats\/ftp\/galileo_stats\/tumble_cloud\///;
		print"loading data from $temp\n";
		$date=$temp;
		$temp="";
		chomp($date);
		# get date from files
		if ($date =~ /TumbleCloud/){
			$date =~ s/TumbleCloud_//;
			$date =~ s/.csv//;
		} else {
			print "Check file name format. Date not found.\n";
			exit;
		} # end if to find date
		$date = "m".$date;
		print"date=$date\n";
		open(FULLTEXT, ">$temp_fulltext_file");
		open(INFILE,"$file");
		while(<INFILE>){
			$line=$_;
			chomp($line);
			$fulltext_count=0;
			if ($past_top){
				print"past top\n";
		        @vars = csv_split( $line );
                #@vars=split /,/,$line;	
				$vars[0] =~ tr/[a-z]/[A-Z]/;
				$vars[0] =~ s/ //g;
				if(defined($inst_code_data{$vars[0]})){
					$inst=$inst_code_data{$vars[0]};
					$fulltext_count=$vars[2];
					chomp($fulltext_count);
					$fulltext_count =~ s/,//g;
					print"fulltext_count=$fulltext_count\n";
					if(defined $fulltext_count){
						if($fulltext_count>0){
							$line_out=$date." ".$inst. " U F ZTBC ".$fulltext_count."\n";
							print FULLTEXT $line_out;
							$line_out="";	
						} #end if 
					} #end if			
				} #end if
			} elsif( $line =~ /Username/){
				$past_top=1;
			} #end if

		} #end while	

		close(INFILE);
		close(FULLTEXT);
		`sort -o $temp_fulltext_file $temp_fulltext_file`;
		`sort -m -o $fulltext_file $fulltext_file $temp_fulltext_file`;
		$past_top=0;
	} #end foreach
} #end tumblecloud_stats_build

#################################################################
# main routine
#################################################################
get_options();

if ($opt_c) {
	print"running Films On Demand stats\n";
	FOD_stats_build();
}

if ($opt_e) {
	print"running ebsco stats\n";
	#ebsco_stats_build($textfile_build);
	ebsco_stats_build();
}

if ($opt_f) {
	print "running firstsearch stats\n";
	firstsearch_stats_build();
}

if ($opt_g) {
	print "running gale legalforms stats\n";
	galelf_stats_build();
}

if ($opt_o) {
	print "running mango stats\n";
	mango_stats_build();
}

if ($opt_p) {
	print"running proquest stats\n";
	proquest_stats_build($textfile_build);
}

if ($opt_l) {
	print"running lexis_nexis stats\n";
	lexis_nexis_stats_build();
}

if ($opt_b) {
	print"running britannica stats\n";
	britannica_stats_build();
}

if ($opt_s) {
	print"running sirs stats\n";
	sirs_stats_build();
}

if ($opt_t) {
	print"running tumble_books stats\n";
	tumblebooks_stats_build();
}

if ($opt_u) {
	print"running tumble_cloud stats\n";
	tumblecloud_stats_build();
}

if ($opt_y) {
	print"running ebrary/ebook central stats\n";
	# uncomment libe below to reload old ebrary stats
	#ebrary_stats_build();
	ebookcentral_stats_build();
}

if ($opt_x) {
	print"running LearningExpress stats\n";
	learning_express_stats_build();
}
if ($opt_z) {
	print"no debug routines to run now\n";	
	#print"running new ebsco stats\n";
	#z_ebsco_stats_build();
}
