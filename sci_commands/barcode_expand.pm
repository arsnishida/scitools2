#!/usr/bin/perl

package sci_commands::barcode_expand;

use sci_utils::general;
use Exporter "import";
@EXPORT = ("barcode_expand");

sub barcode_expand {

$die2 = "

scitools barcode-expand (options) [BARCODE]

Will take a barcode and expand it.
Use scitools barcode-collapse to go in the reverse.

";

if (!defined $ARGV[0]) {die $die2};

load_triplet2ascii();

$barcode = expand_barcode($ARGV[0]);

print "\n$ARGV[0] -> $barcode\n";

}
1;