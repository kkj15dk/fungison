use lib './';
use globals;

$RAST_IDs2=$RAST_IDs;

$GENOME_DB2="";

$LIST2 = "10_11297,10_5658,11_8666,12_6317,12_6677,1_8047,2_3547,3_1329,3_2299,3_893,4_7055,4_8158,4_983,5_294,5_6743,5_8481,6_3717,6_795,6_8939,7_422,7_5880,7_7363,8_2450,8_5508,8_7027,9_4777"; 					##Wich genomes would you process 
						##Can be left blank if you want consecutive genomes starting from 1
$NUM2 = "26";

$NAME2=$NAME;					##Name of the group (Taxa, gender etc)
$BLAST2="Core$NAME.blast";
$dir2=$dir;		##The path of your directory
$e2=$eCore; 							# E value. Minimal for a gene to be considered a hit.

