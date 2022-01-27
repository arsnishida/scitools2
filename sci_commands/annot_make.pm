#!/usr/bin/perl

package sci_commands::annot_make;

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
getopts("O:DI:", \%opt);

# DEFAULTS
$index_dir = "";
@LETTERS = ("0", "A", "B", "C", "D", "E", "F", "G", "H");
%LETTER_NUM = ("A"=>"1", "B"=>"2", "C"=>"3", "D"=>"4", "E"=>"5", "F"=>"6", "G"=>"7", "H"=>"8");

$die2 = "

scitools annot-make (options) [design file]
   or    make-annot
   
This tool will parse a design file and generate a compressed barcode
to annotation matching file (annot). For more information run with
option -D only to print a template design file with additional
instructions.
   
Options:
   -O   [STR]   Output annotation file prefix (def = design file prefix)
   -D           Print design file template + instructions, or use:
                  #github URL for csv file here#
   -I   [PATH]  Directory for indexes. (def = $index_dir)

";

# parse options



# quick survey index folder


# parse design file

open IN, "$ARGV[0]";
while ($l = <IN>) {
	
	if ($l !~ /^#/) { # must be an initial line specifying an index
		if ($l =~ /^index/i) {
			chomp $l;
			@P = split(/(,|\t)/, $l);
			$index_number = $P[0]; $index_number =~ s/^index//i;
			$index_name = $P[1];
			if (!defined $INDEX_NAME_SET_file{$index_name}) {
				die "\nERROR: Index name: '$index_name' not present in index directory $index_dir! Quitting!\n";
			}
			$index_set = $P[2];
			if (!defined $INDEX_NAME_SET_file{$index_name}{$index_set}) {
				die "\nERROR: Index set '$index_set' within $index_name not present! Quitting!\n";
			}
			
			
		} else {
			print STDERR "\nWARNING: below line in design file occurs out of order. Check index_format fields. Skipping.\n\t$l\n";
		}
	} # else comment line
	
} close IN;



}
1;