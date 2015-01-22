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

source scripts/set_sv_params.sh

sitesFile=${runDir}/`basename ${vcfFile} | sed 's/.vcf$/.genotypes.sites.list/'`
pdfFile=${runDir}/`basename ${vcfFile} | sed 's/.vcf$/.genotypes.pdf/'`
grep -v '^#' ${vcfFile} | awk '{print $3}' > ${sitesFile}

if [ ! -e ${runDir}/partition.genotypes.map.dat ]; then
    auxFilePrefix=`ls ${runDir}/*.genotypes.vcf | sed 's/.genotypes.vcf$//'`
    auxFilePrefixArgs="-auxFilePrefix ${auxFilePrefix}"
fi

${java_cmd} \
    org.broadinstitute.sv.apps.PlotGenotypingResults \
    -site ${sitesFile} \
    -runDirectory ${runDir} \
    ${auxFilePrefixArgs} \
    -genderMapFile ${genderMapFile} \
    -O ${pdfFile} \
    || exit 1
