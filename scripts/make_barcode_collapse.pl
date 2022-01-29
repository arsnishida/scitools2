#!/usr/bin/perl

@BASES = ("A", "C", "G", "T");
@ORD = (33,35,36,37,38,40,41,42,43,45,46,48,49,50,51,52,53,54,55,
56,57,59,60,61,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
80,81,82,83,84,85,86,87,88,89,90,91,93,95,97,98,99,100,101,102,
103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,
119,120,121,122,123,125,126);

foreach $base1 (@BASES) {
	foreach $base2 (@BASES) {
		foreach $base3 (@BASES) {
			$TRIPLET{$base1.$base2.$base3} = 1;
		}
		$TRIPLET{$base1.$base2."_"} = 1;
	}
	$TRIPLET{$base1."__"} = 1;
}

$ordID = 0;
foreach $trip (sort {$a cmp $b} keys %TRIPLET) {
	print "$trip\t".chr($ORD[$ordID])."\n";
	$ordID++;
}