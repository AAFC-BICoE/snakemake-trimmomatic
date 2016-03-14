""" Snakemake implementation of the trimmommatic preprocessing pipeline

    © Copyright Government of Canada 2009-2016
    Written by: Tom Sitter, for Agriculture and Agri-Food Canada

    configuration parameters are stored in config.json but can also be changed at runtime
    e.g.
    > snakemake --config minlen=45 

    The following command would be run:

    rule preprocess:
        input: input_reverse.fq.gz, input_forward.fq.gz
        output: output_forward_paired.fq.gz, output_reverse_paired.fq.gz, output_reverse_unpaired.fq.gz, output_forward_unpaired.fq.gz

        java -jar trimmomatic-0.35.jar PE input_forward.fq.gz input_reverse.fq.gz output_forward_paired.fq.gz
        output_forward_unpaired.fq.gz output_reverse_paired.fq.gz output_reverse_unpaired.fq.gz
        ILLUMINACLIP:None LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:45
        
    Job counts:
        count   jobs
        1   preprocess
        1


"""
# Here is an example of how one would get an environmental variable
# In this case, the directory of Illumina Adapters
import os
HPC_TRIMMOMATIC_ADAPTER = os.environ.get("HPC_TRIMMOMATIC_ADAPTER")
HPC_TRIMMOMATIC_DIR = os.environ.get("HPC_TRIMMOMATIC_DIR")

configfile: "config.json"
workdir: config["datadir"]

# The first rule of the file is always executed. 
# This is useful to specify which files you want to be produced programmatically

samples = {f[:16] for f in os.listdir(".") if f.endswith(".fastq.gz")}

rule targets:
    input:
        expand("{sample}_forward_paired.fq.gz", sample=samples)


rule preprocess:
    input:
        forward = "{sample}_R1_001.fastq.gz",
        reverse = "{sample}_R2_001.fastq.gz",
    output:
        forward_paired = "{sample}_forward_paired.fq.gz",
        forward_unpaired = "{sample}_forward_unpaired.fq.gz",
        reverse_paired = "{sample}_reverse_paired.fq.gz",
        reverse_unpaired = "{sample}_reverse_unpaired.fq.gz"
    message: "Trimming Illumina adapters from {input.forward} and {input.reverse}"
    shell:
        """
        java -jar {HPC_TRIMMOMATIC_DIR}/trimmomatic-0.35.jar PE {input.forward} {input.reverse} {output.forward_paired} \
        {output.forward_unpaired} {output.reverse_paired} {output.reverse_unpaired} \
        ILLUMINACLIP:{HPC_TRIMMOMATIC_ADAPTER}/{config[adapter]} LEADING:{config[leading]} TRAILING:{config[trailing]} SLIDINGWINDOW:{config[window]} MINLEN:{config[minlen]}
        """