#!/bin/bash

if [ $# -lt 1 ]
then
    echo "You must specify the input VCF file"
    exit 1
fi
vcfFile=$1

if [ $# -lt 2 ]
then
    echo "You must specify the run output directory"
    exit 1
fi
runDir=$2

bamFileList=bamfile_lists/1kg_phase1_s3.list
#bamFileList=bamfile_lists/1kg_phase1_ebi_http.list

source scripts/set_sv_params.sh

confFile=${SV_DIR}/conf/genstrip_parameters.txt

mkdir -p ${runDir}/logs || exit 1

partitionArgs=""
if [ "${partitionList}" != "" ]; then
    partitionArgs=`cat ${partitionList} | sed 's/^/-partition /'`
fi

outFile=`basename ${vcfFile} | sed 's/.vcf$/.genotypes.vcf/'`

${java_cmd} \
    -Djava.io.tmpdir=$SV_TMPDIR \
    org.broadinstitute.sting.queue.QCommandLine \
    -S ${SV_DIR}/qscript/SVGenotyper.q \
    -S ${SV_DIR}/qscript/SVQScript.q \
    -gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
    -cp ${SV_CLASSPATH} \
    -configFile ${confFile} \
    -tempDir ${SV_TMPDIR} \
    -R ${referenceFile} \
    -genomeMaskFile ${maskFile} \
    -md ${mdDir} \
    -genderMapFile ${genderMapFile} \
    -ploidyMapFile ${ploidyMapFile} \
    -runDirectory ${runDir} \
    -vcf ${vcfFile} \
    -I ${bamFileList} \
    -O ${runDir}/${outFile} \
    -run \
    -jobLogDir ${runDir}/logs \
    -inputFileIndexCache ${inputFileIndexCache} \
    || exit 1


scripts/plot_call_list.sh ${vcfFile} ${runDir}
if [ $? -ne 0 ]
then
    echo "Error plotting the genotypes"
    exit 1
fi
