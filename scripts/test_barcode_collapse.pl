#!/usr/bin/perl

$die = "

test_barcode_collapse.pl [triplet2ascii file] [ACGT barcode to collapse then expand]

";

if (!defined $ARGV[1]) {die $die};

$TRIPLET2ASCII_FILE = $ARGV[0];

load_triplet2ascii();

$collapsed = collapse_barcode($ARGV[1]);
$expanded = expand_barcode($collapsed);

print "Inp:\t$ARGV[1]\nCol:\t$collapsed\nExp:\t$expanded\n";

sub load_triplet2ascii {
	%TRIPLET2ASCII = (); %ASCII2TRIPLET = ();
	if (!defined $TRIPLET2ASCII_FILE) {die "ERROR: load_triplet2ascii, no file specified as the triplet 2 ascii descriptor!\n"};
	open T2A, "$TRIPLET2ASCII_FILE";
	while ($t2a_line = <T2A>) {
		chomp $t2a_line;
		($triplet,$ascii) = split(/\t/, $t2a_line);
		$TRIPLET2ASCII{$triplet} = $ascii;
		$ASCII2TRIPLET{$ascii} = $triplet;
	} close T2A;
}

sub collapse_barcode {
	@BARCODE_PARTS = split(//, $_[0]);
	$collapsed_out = "";
	for ($barcode_pos = 0; $barcode_pos < @BARCODE_PARTS; $barcode_pos++) {
		$triplet_to_convert = $BARCODE_PARTS[$barcode_pos];
		$barcode_pos++;
		if ($BARCODE_PARTS[$barcode_pos] =~ /[ACGT]/) {$triplet_to_convert .= $BARCODE_PARTS[$barcode_pos]} else {$triplet_to_convert .= "_"};
		$barcode_pos++;
		if ($BARCODE_PARTS[$barcode_pos] =~ /[ACGT]/) {$triplet_to_convert .= $BARCODE_PARTS[$barcode_pos]} else {$triplet_to_convert .= "_"};
		if (!defined $TRIPLET2ASCII{$triplet_to_convert}) {die "ERROR: triplet $triplet_to_convert in barcode $_[0] cannot be converted!\n"};
		$collapsed_out .= $TRIPLET2ASCII{$triplet_to_convert};
	}
	return $collapsed_out;
}

sub expand_barcode {
	@ASCII_PARTS = split(//, $_[0]);
	$expanded_out = "";
	for ($ascii_char = 0; $ascii_char < @ASCII_PARTS; $ascii_char++) {
		$expanded_out .= $ASCII2TRIPLET{$ASCII_PARTS[$ascii_char]};
	}
	$expanded_out =~ s/_+$//;
	return $expanded_out;
}