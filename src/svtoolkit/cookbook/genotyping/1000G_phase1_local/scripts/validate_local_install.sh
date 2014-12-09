#!/bin/bash

vcfFile=example/1000G_MERGED_DEL_2_99615.vcf
runDir=validation_output

scripts/genotype_sites.sh ${vcfFile} ${runDir}
if [ $? -ne 0 ]
then
    echo "Error running the validation genotyping"
    exit 1
fi

outputVcfFile=`basename ${vcfFile} | sed 's/.vcf$/.genotypes.vcf/'`

(grep -v ^##fileDate= ${runDir}/${outputVcfFile} | grep -v ^##source= | grep -v ^##reference= | diff -q - baseline/${outputVcfFile}) \
    || { echo "Error: validation results do not match baseline data"; exit 1; }

echo "Validation completed successfully"
