#!/usr/bin/perl

package sci_commands::annot_make;

use sci_utils::general;
use Getopt::Std; %opt = ();
use Exporter "import";
@EXPORT = ("annot_make");

# annot-make code to be folded into scitools 2.0
# new index structure to be used - folder-based
#  - level 0 = "name" (eg Tn5_s3)
#    - level 1 = setID (eq A, or AB)
#       - files??? -figure out structure
# new specification files to include:
#   index number in barcode - can be any number of indexes
#   index specificaiton - i.e. the top directory of indexes "name"
#   index set ID within the name
#   plate layout comma-sep

# have it generate ONE file with multiple columns in the new BCINFO format
# columns:
# compressed_barcode full_barcode annot_index1 ... annot_indexN

sub annot_make {

@ARGV = @_;
getopts("O:DI:B:", \%opt);

# DEFAULTS
$index_dir = "";

$die2 = "

scitools annot-make (options) [design file]
   or    make-annot
   
This tool will parse a design file and generate a compressed barcode
to annotation matching file (annot). For more information run with
option -D only to print a template design file with additional
instructions.

If a current BCINFO file is provided, it will create a new version
with the annot fields appended.
   
Options:
   -O   [STR]     Output annotation file prefix (def = design file prefix)
   -B   [BCINFO]  Provide an existing BCINFO file to append to.
   -D             Print design file template + instructions, or use:
                    #github URL for csv file here#
   -I   [PATH]    Directory for indexes. (def = $index_dir)

";

# parse options

if (!defined $ARGV[0]) {die $die2};

# quick survey index folder


# if BCINFO file exists, load it up
if (defined $opt{'B'}) {
	load_bcinfo($opt{'B'});
} else { # new object with fresh mandatory fields.
	%BCINFO = (); @BCFIELDS = ("BARCODE_RAW", "BARCODE_COLLAPSED");
	@{$BCINFO{"BARCODE_RAW"}} = ();
	@{$BCINFO{"BARCODE_COLLAPSED"}} = ();
}

# parse design file

%ANNOT_count = (); %ANNOT_index = ();
open IN, "$ARGV[0]";
while ($l = <IN>) {
	
	if ($l !~ /^#/) { # must be an initial line specifying an index
		if ($l =~ /^index/i) {
			chomp $l;
			@P = split(/,/, $l);
			$index_number = $P[0]; $index_number =~ s/^index//i;
			$index_name = lc($P[1]);
			if (!defined $INDEX_NAME_SET_file{$index_name}) {
				die "\nERROR: Index name: '$index_name' not present in index directory $index_dir! Quitting!\n";
			}
			$index_set = $P[2];
			if (!defined $INDEX_NAME_SET_file{$index_name}{$index_set}) {
				die "\nERROR: Index set '$index_set' within $index_name not present! Quitting!\n";
			}
			
			# now parse based on format
			if ($P[3] =~ /all/i) {
				@{$INDEX_ANNOT{$index_number}{'all'}} = ();
				open IX, "$INDEX_NAME_SET_file{$index_name}{$index_set}";
				while ($ix = <IX>) {
					chomp $ix; 
					push @{$INDEX_ANNOT{$index_number}{'all'}}, $ix;
				} close IX;
			} elsif ($P[3] =~ /row/i) {
				open IX, "$INDEX_NAME_SET_file{$index_name}{$index_set}";
				while ($ix = <IX>) {
					chomp $ix;
					$l = <IN>; chomp $l;
					if ($l =~ /,/) {die "ERROR: line $l is being read in as part of a row specification for $index_number, $index_name, $index_set!\n\tRow specificaitons must have 8 lines after the description line!\n"};
					push @{$INDEX_ANNOT{$index_number}{$l}}, $ix;
					if (!defined $ANNOT_count{$l}) {$ANNOT_count{$l} = 0; $ANNOT_index{$l} = $index_number};
				} close IX;
			} elsif ($P[3] =~ /col/i) {
				open IX, "$INDEX_NAME_SET_file{$index_name}{$index_set}";
				$l = <IN>; chomp $l; @COLS = split(/,/, $l);
				if (length(@COLS) != 12) {die "ERROR: line '$l' is being read as column specification for $index_number, $index_name, $index_set!\n\tColumn specificaitons must have 1 line with 12 fields after the description line!\n"};
				$colID = 0;
				while ($ix = <IX>) {
					chomp $ix;
					push @{$INDEX_ANNOT{$index_number}{$COLS[$colID]}}, $ix;
					if (!defined $ANNOT_count{$COLS[$colID]}) {$ANNOT_count{$COLS[$colID]}; $ANNOT_index{$COLS[$colID]} = $index_number = 0};
				} close IX;
			}
			
		} else {
			print STDERR "\nWARNING: below line in design file occurs out of order. Check index_format fields. Skipping.\n\t$l\n";
		}
	} # else comment line
	
} close IN;


}
1;