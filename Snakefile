""" Snakemake implementation of the trimmommatic preprocessing pipeline

    © Copyright Government of Canada 2009-2016
    Written by: Tom Sitter, for Agriculture and Agri-Food Canada

    configuration parameters are stored in config.json but can also be changed at runtime
    e.g.
    > snakemake --config minlen=45 

    The following command would be run:

    rule preprocess:
        input: F3D149_S215_L001_R1_001.fastq.gz, F3D149_S215_L001_R2_001.fastq.gz
        output: F3D149_S215_L001_forward_paired.fq.gz, F3D149_S215_L001_forward_unpaired.fq.gz, F3D149_S215_L001_reverse_unpaired.fq.gz, F3D149_S215_L001_reverse_paired.fq.gz

        java -jar /usr/local/bin/trimmomatic-0.35.jar PE F3D149_S215_L001_R1_001.fastq.gz F3D149_S215_L001_R2_001.fastq.gz F3D149_S215_L001_forward_paired.fq.gz
        F3D149_S215_L001_forward_unpaired.fq.gz F3D149_S215_L001_reverse_paired.fq.gz F3D149_S215_L001_reverse_unpaired.fq.gz
        ILLUMINACLIP:/vagrant/snakemake-trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:45
    
    ...

    localrule targets:
        input: F3D148_S214_L001_forward_paired.fq.gz, F3D150_S216_L001_forward_paired.fq.gz, F3D147_S213_L001_forward_paired.fq.gz, F3D149_S215_L001_forward_paired.fq.gz
   
    Job counts:
        count   jobs
        4   preprocess
        1   targets
        5


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