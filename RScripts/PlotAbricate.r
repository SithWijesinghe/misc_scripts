#!/usr/bin/Rscript

# Takes abricate summary tsv file as input and generates feature map.
# Optionally can subset a gene family.
#
# Usage: Rscript PlotAbricate.r -i abricate_output.tsv -o plot.pdf
#        Rscript PlotAbricate.r -i abricate_output.tsv -o plot.pdf -p "blaCTX-M"
#
#
# ABRicate is an antimicrobial resistance screenning tool for WGS written by Torsten Seemann https://github.com/tseemann/abricate

#####################################################################
#Libraries
#####################################################################


source ("~/scripts/R/Process_args.r")

library(reshape)
library(stringr)
library(ggplot2)


#####################################################################
#Argument handling
#####################################################################


spec_list <- c('infile', 'i', 1 , "character",
               'out', 'o', 1 , "character",
               'pattern', 'p', 2, "character",
               'binary', 'b', 2, "logical",
               'header', 't', 2, "logical",
               'y_label', 'y', 2, "character",
               'height', 'h', 2, 'integer',
               'width', 'w', 2, 'integer')

process_args(spec_list)

#####################################################################
#Parameters
#####################################################################

set_defaults("header", "Abricate summary")
set_defaults('y_label', "Antimicrobial resistance gene")
set_defaults('binary', F)
set_defaults('height', 12)
set_defaults('width', 12)
height <- as.numeric(height)
width <- as.numeric(width)
#####################################################################
#Functions
#####################################################################



subset_gene_fam <- function(table,  pattern){
  #' @param table: abricate summary tsv read into R as dataframe. First two columns contain the sample name and the total number of hits respectively
  #' @param pattern: Pattern to subset
  
  #base columns with filename and Number of genes
  list <- c(1,2)
  
  if (grepl(',', pattern)){
    patterns <- str_split(pattern, ', ', n=Inf)[[1]]
    for(string in patterns){
      list <- c(list, grep(string, colnames(table)))
    }
  } else {
    list <- c(list, grep(pattern, colnames(table)))
  }
  
  table.strip <- table[,list]
  return(table.strip)
}


replace_null_values <- function (table, binary=F){
  #' replace '.' values with 0. And if required converts all non zero values to 1.
  #'
  #' @param table: abricate summary tsv
  #' @param binary: whether to convert all non-zero values to 1
  #'
  
  if (binary == F) {
    df <- apply(table[,-c(1,2)], 2, function(x){x[x=="."] <- 0; return(as.numeric(x))})
  } else {
    df <- apply(table[,-c(1,2)], 2, function(x){x[x=="."] <- 0;x[x!="0"] <- 1+str_count(x,";"); return(as.numeric(x))})
  }
  row.names(df) <- table$FILE
  return(df)
}




#####################################################################
#Input and preprocess
#####################################################################

#setwd("~/Work/Projects/ACE_Illumina_PE150_NZ-ESBL-Enterobacteriaceae_20170310/WD/Contamination_Strainest/abricate")
table <- read.delim(infile, header=T, sep='\t')

if (exists("pattern")){table <- subset_gene_fam(table, pattern)}
table <- replace_null_values(table)


colnames(table) <- sub("^X.", "", colnames(table))
row.names(table)<- as.vector(sapply(row.names(table),function(x) gsub(".tsv", "", x)))
row.names(table)<- as.vector(sapply(row.names(table),function(x) gsub("abricate_", "", x)))



#####################################################################
#Processing
#####################################################################
molten <- melt(table)

if (binary==F){
  legendtitle = "Gene coverage"
} else {
  legendtitle = "Gene presence"
}


heatmap <- ggplot(molten, aes(x=X1, y=X2, fill=value)) +
  geom_tile() +
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  scale_fill_gradient(low="white", high="black", name=legendtitle)+
  xlab("Sample ID")+
  ylab(y_label)+
  ggtitle(header)


ggsave(paste0(out, ".pdf"), plot=heatmap, device = pdf, width = width, height = width, units = "in", dpi = 600)