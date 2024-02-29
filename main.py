# Python
import os
import subprocess
import argparse

args = {
    'reference': '1234',
    'evalue': 0.0000001,
    'score': 200,
    'flanks': 10,
    'eCluster': '0.1',
    'eCore': '0.1',
    'GENOMES_IDs': 'GENOMES.IDs',
    'BLAST_CALL': '',
    'currWorkDir': os.getcwd(),
    'dir': os.getcwd(),
    'NAME': os.getcwd().split('/')[-1],
    'BLAST': f"{os.getcwd().split('/')[-1]}.blast",
    'NUM': sum(1 for line in open('GENOMES.IDs')),
    'RESCALE': 195000
}

parser = argparse.ArgumentParser(description='USAGE: python fungison.py <OPTIONS>')
parser.add_argument('-q', type=str, help='QUERY FILE, [a file with .query extension]')
parser.add_argument('-r', type=str, help='REFERENCE GENOME ID FROM GENOMES.IDs, WHEN NOT USING -d full MAKE SURE THE ENTRY IS LISTED IN -d [a number]')
parser.add_argument('-e', type=float, help='E-VALUE CUTOFF, [a number]')
parser.add_argument('-s', type=int, help='BIT-SCORE CUTOFF [a number]')
parser.add_argument('-f', type=int, help='NUMBER OF FLANKING GENES INCLUDED IN THE ANALYSIS, [a number]')
parser.add_argument('-d', type=str, help='IDs OF THE GENOMES INCLUDED IN THE ANALYSIS, [full= entire database OR selected genomes separated by \',\' ]')
parser.add_argument('-x', type=str, help='FORMAT THE DATABASE SELECTED WITH THE -d OPTION, [\'no\' is the recommeded option or \'FORMATDB\']')

update_args = parser.parse_args()

# Check if all required arguments are provided
if not all([args.q, args.r, args.e, args.s, args.f, args.d, args.x]):
    parser.error('All arguments must be provided')

# Check if query file has .query extension
if not args.q.endswith('.query'):
    parser.error('Query file must have .query extension')

# Check if reference genome ID is in GENOMES.IDs
with open('./bin/GENOMES.IDs', 'r') as file:
    if args.r not in file.read():
        parser.error('Reference genome ID not found in GENOMES.IDs')

# Check if database option is valid
if args.d != 'full' and ',' not in args.d:
    parser.error('Invalid database option. It should be either \'full\' or a list of genome IDs separated by \',\'')

# Check if format option is valid
if args.x not in ['no', 'FORMATDB']:
    parser.error('Invalid format option. It should be either \'no\' or \'FORMATDB\'')

# Set the path to the query file
query = os.path.join(os.getcwd(), args.q)

def run_corason2(args):
    # Use the arguments from the dictionary
    reference = args['reference']
    evalue = args['evalue']
    score = args['score']
    flanks = args['flanks']
    # Rest of the function...

run_corason2(args)