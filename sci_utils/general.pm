package sci_utils::general;

use Getopt::Std; %opt = ();
use Exporter "import";

# Export all of the subroutines and variables that should be passed to scitools
@EXPORT = (
	"load_defaults",
		qw($color_mapping),qw($ref_shortcuts),qw(@BASES),qw(%REF),qw(%VAR),qw($gzip),qw($zcat),
		qw($bwa),qw($samtools),qw($scitools),qw($macs2),qw($bedtools),qw($Rscript),qw($Pscript),
		qw($bismark),qw($bowtie2),
	"load_bcinfo",
		qw(@BCFIELDS),qw(%BCINFO),
	"load_triplet2ascii",
		qw(%TRIPLET2ASCII),qw(%ASCII2TRIPLET),
	"collapse_barcode", "expand_barcode"
);

sub load_defaults {
	# Some global ones that are not configured
	$color_mapping = "none";
	$ref_shortcuts = "";
	$log_check = "F";
	@BASES = ("A", "C", "G", "T", "N");
	%REF; %VAR;
	if (-e "$_[0]") {
		open DEF, "$_[0]";
		while ($def = <DEF>) {
			if ($def !~ /^#/) {
				chomp $def;
				($var,$val) = split(/=/, $def);
				if ($var =~ /_ref$/) {
					$refID = $var; $refID =~ s/_ref$//;
					$REF{$refID} = $val;
					$ref_shortcuts .= "\t$refID = $val\n";
				} else { # software calls
					if ($var eq "gzip") {$gzip = $val}
					elsif ($var eq "zcat") {$zcat = $val}
					elsif ($var eq "bwa") {$bwa = $val}
					elsif ($var eq "samtools") {$samtools = $val}
					elsif ($var eq "scitools") {$scitools = $val}
					elsif ($var eq "macs2") {$macs2 = $val}
					elsif ($var eq "bedtools") {$bedtools = $val}
					elsif ($var eq "Rscript") {$Rscript = $val}
					elsif ($var eq "Pscript") {$Pscript = $val}
					elsif ($var eq "bowtie2") {$bowtie2 = $val}
					elsif ($var eq "bismark") {$bismark = $val}
					else {$VAR{$var} = $val};
				}
			}
		} close DEF;
	}
	# Load vars that need to be specified for functionality if they are not found in the config file
	if (!defined $gzip) {$gzip = "gzip"};
	if (!defined $zcat) {$zcat = "zcat"};
	if (!defined $bwa) {$bwa = "bwa"};
	if (!defined $samtools) {$samtools = "samtools"};
	if (!defined $scitools) {$scitools = "scitools"};
	if (!defined $macs2) {$macs2 = "macs2"};
	if (!defined $bedtools) {$bedtools = "bedtools"};
	if (!defined $Rscript) {$Rscript = "Rscript"};
	if (!defined $Pscript) {$Pscript = "python"};
	if (!defined $bedops) {$bedops = "bedops"};
	if (!defined $seqtk) {$seqtk = "seqtk"};
}


sub load_bcinfo {
	open BCINFO, "$_[0]";
	$header = <BCINFO>; %BCINFO = ();
	@BCFIELDS = split(/,/, $header);
	foreach $field (@BCFIELDS) {@{$BCINFO{$field}} = ()};
	while ($data_line = <BCINFO>) {
		@BCDATA = split(/,/, $data_line);
		for ($field_pos = 0; $field_pos < @BCFIELDS; $field_pos++) {
			push @{$BCINFO{$BCFIELDS[$field_pos]}}, $BCDATA[$field_pos];
		}
	} close BCINFO;
}

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

}
1;
