#!/usr/bin/env Rscript

# Handy set of functions to enable parsing command line arguments in an R script run from the command line
# Usage:
# 	source('/path/to/arrgparse.r')

#set_local_libPath <- function(path){
#  mypaths <- .libPaths()
#  mypaths <- c(path, mypaths)
#  .libPaths(mypaths)
#}

#setting libpath for windows
#set_local_libPath('C:/Users/Sithija/Documents/R/win-library/4.0')
#library('getopt')
#library("getopt", lib.loc="~/R/win-library/4.0")


process_args <- function (spec_list) {

  #' @description Parses arguments provided in the Rscript shell as variables in script

  #' @param spec_list. list object. contains 4 elements per each argument that can be parsed in the following order. long flag (str), shortned flag (str), whether it is compuslory or optional (numeric 0-2), class of expected argument (str)
  #'
  #' eg: spec_list <- c('method', 'm', 1 , "double", 'window', 'w', 2 , "integer", 'smoothing', 's', 2, "bool")
  #'	 process_args(spec_list)

  spec <- matrix(spec_list, byrow=TRUE, ncol=4)
  opt <- getopt(spec)

  list2env(opt, envir=globalenv())
}

set_defaults <- function(variable, value, msg=F) {
  #' @description sets default values for variables. can be used to set default variables for optional args in parse_args
  #' @param variable. string. variable name to check
  #' @param value. value to set if variable doesnt exist
  #' 
  #' eg: set_defaults('method', 'CNN', msg=T)
  
  if (! exists(variable)){
    assign(variable, value, envir = .GlobalEnv)
    if ( msg == T){
      print(paste("default value ", value, "set for variable ", variable))
    }
  }

}
