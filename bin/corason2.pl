######################################################################
use lib './';
use globals;
use experimental 'smartmatch';
############################################################
my $specialOrg=$SPECIAL_ORG; #globals.pm
my $nameFolder=$NAME; #globals
my $queries=$QUERIES; #globals
my $num=$NUM;
my $lista=$LIST;
my $download=$DOWNLOAD;
my $formatDB=$FORMAT_DB;
my $genomesID=$GENOMES_IDs;
my $password=$PASS;
my $user=$USER;
my $directorio=$dir;
######################################################################
sub listas;
sub create_listfaa;
sub cleanFiles;
########## Main ######################################################

print "\n\n##########################################################################\n";
print "CORASON: CORE ANALYSIS OF SYNTENIC ORTHOLOGOUS NATURAL PRODUCT BGCs\n";
print "this is version 2.1 uses iqtree, no trimming, phylo sort with nw_distances\n";
print "Smartmatch silenced, order files exist if trees fail, aligning with mafft\n";
print "Adapted to run with wrapper fungison.pl\n";
print "latest version modified by Pablo Cruz-Morales september 2022\n";
print "##########################################################################\n\n";
print "Your working directory is $directorio\n";

open (REPORTE, ">./Report.report") or die "Couldn't open report file $!";
my $list=listas($num,$lista);  #$list stores in a string the genomes that will be used
my @LISTA=split(",",$list);
if ($formatDB==1){
	print "Formatting the database...\n";
	`perl  header.pl`;
	`makeblastdb -in Concatenados.faa -dbtype prot -out ProtDatabase.db -logfile run`;
	print "the database has been formatted\n";
	}
else {
	print "I am assuming that you have a ProtDatabase ready for Blast\n";
}
print "\nSearching for homologs of the query...\n";
	if ($lista eq ""){
                `perl  1_Context_text.pl $queries 0 prots`;
		}
        else {
                print "searching for homologs within selected genomes...\n";        
                `perl  1_Context_text.pl $queries 1 prots`;
               }
print "Sequences found\n";
print "Searching for clusters related to the query...\n";
	`perl  ReadingInputs.pl`;
print "Clusters found\n";
`cat *.input2> QUERY_HITS.txt`;
`perl RenameQueryHits.pl`;
my $NumClust= `ls *.input2|wc -l`;
chomp $NumClust;
print "There are $NumClust organisms with similar clusters\n"; 
print REPORTE "There are $NumClust organisms with similar clusters\n"; 
print "Aligning the sequences...\n";
system "mafft --quiet QUERY_HITS.faa  > QUERY_HITS.aln";
#constructing a tree with IQTREE with a 1000 bootstrap replicates
print "Creating a tree of query homologs (single marker)...\n";
system "iqtree2 -s QUERY_HITS.aln -m TEST -bb 1000 -nt AUTO -quiet";
system "./nw_distance -n  QUERY_HITS.aln.contree |sort -k2 -n -r|cut -f1 >QUERY_HITS.order";
my $orderFile="QUERY_HITS.order";
	#checking of orderfile is empty (if the tree is too small or failed)
	if ($orderFile==''){
	`grep ">" QUERY_HITS.faa|sed 's/>//'>QUERY_HITS.order`;
	my $orderFile="QUERY_HITS.order";	
	}

#GENERATE A SORTED LIST OF NAMES FROM THE TREE
#############################################################################

print "Calculating the BGC core...\n";
	`perl  2_OrthoGroups.pl`;
print "The core has been calculated\n";
my $boolCore= `wc -l Core`;
chomp $boolCore;
print "core line number $boolCore!\n";
$boolCore=~s/[^0-9]//g;
$boolCore=int($boolCore);
print "core line number ¡$boolCore!\n";
my $INPUTS=""; ## Orgs sorted according to a tree (Will be used on the Context draw)

if ($boolCore>1){
	print REPORTE "There is a core composed by $boolCore orhtolog(s) in this BGC\n";
	print REPORTE "The core is annotated in the reference organism as follows:\n";
	## Grabbing the reference BGC
	my $specialCluster=specialCluster($specialOrg);
	print "Best cluster $specialCluster\n";
        `cut -f1,2 $nameFolder/FUNCTION/$specialCluster.core.function >> Report.report`;
	print "Aligning...\n";
	`perl  multiAlign.pl`;
	print "Sequences were aligned\n";
	print "Creating matrix...\n";
	`perl  ChangeName.pl`;
	`perl  EliminadorLineas.pl`;
	print "renaming...\n";
	`perl  Concatenador.pl`;
	`perl  Rename_Ids_Star_Tree.pl`;
	print "\nFormating matrix for BGC tree..\n";
	print "constructing the BGC tree using IQTREE with  1000 bootstraps replicates...\n";
	system "iqtree2 -s concatenated_matrix.aln -m TEST -bb 1000 -nt AUTO -quiet";
	system "./nw_distance -n  concatenated_matrix.aln.contree |sort -k2 -n -r|cut -f1 >BGC_TREE.order";
	$orderFile="BGC_TREE.order";
	#checking of orderfile is empty (if the tree is too small or failed)
	if ($orderFile==''){
	`grep ">" concatenated_matrix.aln|sed 's/>//'>BGC_TREE.order`;
	my $orderFile="BGC_TREE.order";	
	}	
	print "Drawing the genome contexts with the order of the BGC tree...\n";
	print $orderFile;	
	$INPUTS=getDrawInputs($orderFile);
	}
	else{  ### If there is no core, then sort according to principal hits
	print REPORTE "The only genes in common are the homologs of the query\n";
	print REPORTE "No concatenation of core sequences and core phylogeny expected\n\n";
	if (-e $orderFile){
		print "I will draw with the single hits order\n";
		print  REPORTE "I will draw with the single hits order\n";
		$INPUTS=getDrawInputs($orderFile);
        	}
        }
print "Drawing the BGCs with files $INPUTS : \n";
	`perl  3_Draw.pl $INPUTS`;

cleanFiles;
print "BGCs found in the following genome IDs:\n\n";
system 'grep LIST2 globals2.pm |cut -d "\"" -f2|tr "," "\n"|cut -d "_" -f1|sort|uniq|tr \'\\n\' \'\\,\'';
print "\n";
system 'cat Report.report';
print "Done\n";
print "Have a great day\n\n";

#####################   Sub  routines  ###############################
sub specialCluster{
	my $specialOrg=shift;
	my @CLUSTERS=qx/ls $specialOrg\_*.input/;
	my $specialCluster="";
	my $score=0;
	foreach my $cluster (@CLUSTERS){
		chomp $cluster;
		#print "I will open #$cluster#\n";
		open (FILE, $cluster) or die "Couldn't open $cluster\n"; 
		my $firstLine = <FILE>; 
		chomp $firstLine;
		close FILE;
		my @sp=split(/\t/,$firstLine);
			if ($score<=$sp[7]){
				$specialCluster=$cluster;
				}
		}
	$specialCluster=~s/\.input//;
	return $specialCluster;
}
sub cleanFiles{
        `rm *.lista`;
        `rm lista.*`;
        `rm *.input`;
        if (-e "*.input2"){`rm *.input2`;}
        `rm *.input2`;
        `rm Core`;
        `rm *.order`;
        `rm Core0`;
        `rm -r OUTSTAR`;
        `rm -r MINI`;
	`rm -r ./bin`;
        `rm -r *.faa`;
        `rm -r *.BLAST.pre`;
        `rm -r *.txt`;
        `rm -r *.aln.iqtree`;
        `rm -r *.aln.log`;
        `rm -r *.aln.ckp*`;
        `rm -r *.aln.model*`;
        `rm -r *.aln.mldist`;
        `rm -r *.aln.splits.nex`;
        `rm -r *.aln.treefile`;
        `rm -r *.aln.bionj`;
	`rm *.parser*`;
	`rm Corebin.blast`;
	`rm Cluster*.BLAST`;
	`rm QUERY_HITS.aln.uniqueseq.phy`;
	`rm run*`;

        }
#_____________________________________________________________________________________

sub getDrawInputs{
	my $file=shift;
	my $INPUTS="";
	open (NAMES,$file) or die "Couldnt open $orderFile $!";
	foreach my $line (<NAMES>){
		chomp $line;
		my @spt=split(/_org_|_peg_/,$line);
		$INPUTS.=$spt[2]."_".$spt[1]."\.input,";
		}
		my $INPUT=chop($INPUTS);
	return $INPUTS;
	}
#_________________________________________________________________________
sub listas{
	my $NUM=shift;
	my $LIST=shift;
	my $lista="";
	create_list($NUM,$LIST);
	create_listfaa($NUM,$LIST);	
   
	if ($LIST){ 
		print "These are the genomes that you selected: $LIST\n";
		$lista=$LIST;
		}
	else {
		for( my $COUNT=1;$COUNT <= $NUM ;$COUNT++){
			$lista.=$COUNT;
			if($COUNT<$NUM){
				$lista.=",";
				}
			}
		}
	print "Program lists have been created\n";
	print "An organism identifier has been added to each sequence\n";

	return $lista;
	}
#_____________________________________________________________________________________
sub create_list{  ########### Creates a numbers lists			
	my $NUM=shift;
	my $LIST=shift;
	if (-e "lista.$NUM"){
			unlink("lista.$NUM");
			}
	open (LISTA, ">","lista.$NUM");
	if ($LIST){
		my @Genomas=split(",",$LIST);	
		foreach (@Genomas) {
		print LISTA "$_\n";		
			}
		}
	else{	
		my $COUNT=1;
		while  ( $COUNT <= $NUM ){
			print LISTA "$COUNT\n";		
			$COUNT=$COUNT+1;
			}
		}


	close LISTA;
	}
#_____________________________________________________________________________________
sub create_listfaa{
	my $NUM=shift;
	my $LIST=shift;
	if (-e "$NUM.lista"){unlink( "$NUM.lista");}
	open (LISTA,"<","lista.$NUM") or die "Could not open the file lista.$NUM:$!";
	open (LISTAFAA,">$NUM.lista") or die "Could not open the file $NUM.lista:$!";
	for my $line (<LISTA>){
		chomp $line;
		$line.="\.faa\n";
		print LISTAFAA $line;
		}
	close LISTA;
	close LISTAFAA;	
	}
