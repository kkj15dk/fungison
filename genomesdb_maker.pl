#This script will create a GENOMES folder and a GENOMES.IDs file for all the outputs from the annotation pipeline
#The output is ready for the CORASON3 / fungison pipeline
#by Pablo Cruz-Morales October 2022 pcruzm@biosustain.dtu.dk
#Uses the .faa and .txt files from input_folder. Creates a /GENOMES folder and GENOMES.IDs file in output_folder

$output_folder="./bin";
$input_folder="./genomes_data";

open OUT, ">genomes_database_naming.sh" or die "I cant write the genomes_database_naming.sh file\n";
open GENOMESFILE, ">$output_folder/GENOMES.IDs" or die "I cant write the GENOMES.IDs file\n";
print "Creating the GENOMES.IDs file\n";
@files=`ls $input_folder/*.faa`;
foreach  (@files){
$cont++;
$genome="$_";
$header=`sed -n 1p $genome`;
$genome=~s/.faa//;
$header=~s/>fig\|//;
$header=~s/.peg.1//;
chomp $header;
chomp $genome;
print GENOMESFILE "$cont\t$header\t$genome\t$cont\n";
print OUT "cp $genome.faa $output_folder/GENOMES/$cont.faa\ncp $genome.txt $output_folder/GENOMES/$cont.txt\n";
}
print GENOMESFILE "\n";
close OUT;
print "Preparing the GENOMES database\n";
system "mkdir $output_folder/GENOMES";
system "sh genomes_database_naming.sh"