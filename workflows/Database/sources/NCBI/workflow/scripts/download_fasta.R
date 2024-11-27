# Purpose: Download fasta file from NCBI
#
# Author: John Brittain
# Modified from https://rpubs.com/syedulla1/847184

# Install packages
install.packages("devtools", repos = "http://cran.us.r-project.org")
devtools::install_cran("rentrez")
devtools::install_cran("seqinr")
devtools::install_cran("optparse")
devtools::install_github("brouwern/compbio4all")

# Load packages
library(rentrez)
library(seqinr)
library(compbio4all)
library(optparse)

# Parse command line arguments
option_list <- list(
    make_option(c("-d", "--db"), type="character", default="nucleotide", 
                help="database to search"),
    make_option(c("-i", "--id"), type="character", default="NC_001477", 
                help="id to search"),
    make_option(c("-r", "--rettype"), type="character", default="fasta", 
                help="return type"),
    make_option(c("-o", "--output"), type="character", default="seq.fasta", 
                help="output file")
);
opt <- parse_args(OptionParser(option_list=option_list))

# Download fasta file
fasta <- rentrez::entrez_fetch(
    db = opt$db,
    id = opt$id,
    rettype = opt$rettype
)

# Write fasta file
write(fasta, file = opt$output)
