#!/usr/bin/perl

package sci_commands::barcode_collapse;

use sci_utils::general;
use Exporter "import";
@EXPORT = ("barcode_collapse");

sub barcode_collapse {

$die2 = "

scitools barcode-collapse (options) [BARCODE]

Will take a barcode and collapse it.
Use scitools barcode-expand to go in the reverse.

";

if (!defined $ARGV[0]) {die $die2};

load_triplet2ascii();

$barcode = collapse_barcode($ARGV[0]);

print "\n$ARGV[0] -> $barcode\n";

}
1;