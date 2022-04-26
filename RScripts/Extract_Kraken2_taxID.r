#!/usr/bin/env Rscript


#####################################################################
#Input handling
#####################################################################
welcome_message <- "This script parses Kraken2 report file given it's filename and provides the taxid of the most abundant taxa at a given level (Default: Species). Please provide the working directory and taxonomic level \
as positional arguments. defaults to species level but can be overriden by positional argument 2 (optional)

Usage:
\t eg: To process a summary of all the samples at the genus level
\t Rscript extract_kraken_taxid.r ./kraken_report.kreport G

\t eg: To assign a value to a bash variable
\t $ TAXID=$(Rscript.exe id_kraken_taxid.r ./kraken_report/MS14629.S10_report.kreport S)

"


args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop(welcome_message, call.=FALSE)
  
} else if (length(args) > 1) {
  kreport <- args[1]
  level <- args[2]
} else {
  kreport <- args[1]
  level <- "S"
}

#####################################################################
#Functions
#####################################################################

extract_taxid <- function(filename){
  kreport <- read.csv2(filename, header=F, sep='\t')
  abundance <- kreport[which(kreport$V4==level),]
  dominant_taxid <- abundance$V5[which.max(abundance$V1)]
  return(as.numeric(dominant_taxid))
}


#####################################################################
#Main ()
#####################################################################

cat(extract_taxid(kreport))
