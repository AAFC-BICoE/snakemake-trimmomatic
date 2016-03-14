# snakemake-trimmomatic
Example of a snakemake encapsulation of trimmomatic
This was tested used snakemake 3.5.5 and trimmomatic 0.35 running on CentOS 6.7

More details about trimmomatic can be found at http://www.usadellab.org/cms/?page=trimmomatic

To run this example you must install snakemake, download trimmomatic, and define two environmental variables: the path to the Illumina adapters directory, and the path to the trimmomatic jar file.

```
export HPC_TRIMMOMATIC_ADAPTER = "/path/to/adapter"
export HPC_TRIMMOMATIC_DIR = "/path/to/trimmomatic.jar"
```

The data files used in this repository were taken from example data provided by mothur for the MiSeq SOP.  
The complete data files can be downloaded from http://www.mothur.org/w/images/d/d6/MiSeqSOPData.zip

To run this tool, nagivate to the directory and run `snakemake`

