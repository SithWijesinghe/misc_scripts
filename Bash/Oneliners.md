# Miscellaneous Bash oneliners


Checks if a folder exists before issuing a mkdir command. avoids exiting with an error message when using mkdir alone
```console
function mkdir_if {
if [[ ! -e $1 ]]; then
        mkdir -p $1
fi
}
```

Checks if a matching file exists and breaks a loop if it does not. Useful sometimes when running pipeline generating intermediate files inside a slurm job.
```console
function filetest {
if [[ ! -e $1 ]]; then
        echo "$1" does not exist. Please check the input parameters
        exit 1
fi
}
```
Checks if a variable exists, ideally provided at the time of running the script then if not assigns a default value. Useful for writing scripts with command line arguments that are optional.
```console
function set_default { [ ! -v $1 ] && export $1=$2  ; }
```
Applies a given function to all subdirectories (% character as placeholder) in the working directory
```console
function reach_in {  ls | xargs -I % sh -c "${1}"; }
```
Calculates the read count of a given compressed fastq file
```console
function calc_mean_fq_len { zcat ${1} | awk '{if(NR%4==2) {count++; bases += length} } END{print bases/count}' - ; }
```
Calculates the ratio between two floats and returns the value (When you want some division done and you absolutely do not want python involved)
Positional args: $1=denominator, $2=numerator, $3=floating point precision
```console
function calc_ratio { printf %.${3}f $(echo ${2}/${1} | bc -l) ; }
```
Alternative for ```tree``` when it's unavailable.
```console
function dir_tree { ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/' ; }
```
Extract paired end fastq files from bam (needs samtools and 4 threads available)
```console
function extract_fq_reads { samtools view -O BAM -@4 $1 $2 | samtools bam2fq -@4 - | tee >(grep '^@.*/1$' -A 3 --no-group-separator > ${3}_R1.fq) | grep '^@.*/2$' -A 3 --no-group-separator > ${3}_R2.fq  ; }
```

