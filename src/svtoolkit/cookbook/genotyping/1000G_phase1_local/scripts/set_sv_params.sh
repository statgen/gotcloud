#!/bin/bash

SV_METADATA_DIR=

if [ ! -e "$SV_METADATA_DIR" ]
then
    echo "You must specify SV metadata location in scripts/set_sv_params.sh as SV_METADATA_DIR=..."
    exit 1
fi

export SV_DIR=`cd ../../.. && pwd`

export SV_CLASSPATH="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

SV_TMPDIR=/tmp

export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

java_cmd="java -cp ${SV_CLASSPATH} -Xmx4g"

referenceFile=${SV_METADATA_DIR}/reference/human_g1k_v37.fasta
mdDir=${SV_METADATA_DIR}/metadata
genomeMaskFile=${SV_METADATA_DIR}/svmasks/human_g1k_v37.mask.36.fasta
genderMapFile=${SV_METADATA_DIR}/dataset/samples_1kg_phase1_illumina.gender.map
ploidyMapFile=${SV_METADATA_DIR}/reference/human_g1k_v37.ploidy.map
inputFileIndexCache=${SV_METADATA_DIR}/bam_indices
