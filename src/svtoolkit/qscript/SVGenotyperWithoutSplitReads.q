
import org.broadinstitute.sv.qscript.SVQScript

import org.broadinstitute.sv.queue.ComputeVCFPartitions

class SVGenotyperWithoutSplitReads extends SVQScript {

    @Input(fullName="vcfFile", shortName="vcf", doc="The vcf file of sites to genotype.")
    var vcfFile: File = null

    @Output(shortName="O", doc="The output vcf file.")
    var outputFile: File = null

    @Argument(shortName="partition", required=false, doc="Specific partitions to rerun")
    var partitionList: List[String] = null

    /**
     * In script, you create and add functions to the pipeline.
     */
    def script = {
        parameterList :+= "genotyping.modules:depth,pairs"
        var runFilePrefix = outputFile.getName.stripSuffix(".vcf").stripSuffix(".genotypes")
        var unfilteredOutFile = new File(runDirectory, swapExt(outputFile, "vcf", "unfiltered.vcf").getName)
        var annotatedOutFile = new File(runDirectory, swapExt(outputFile, "vcf", "annotated.vcf").getName)
        val partitions = computeVCFPartitions(vcfFile)
        if (partitions.isEmpty) {
            addCommand(new SVGenotyper(vcfFile, unfilteredOutFile, runFilePrefix))
        } else {
            var gtPartFiles: List[File] = Nil
            for ((partitionName, partitionArg) <- partitions) {
                if (partitionList == null || partitionList.contains(partitionName)) {
                    gtPartFiles :+= addCommand(new SVParallelGenotyper(vcfFile, partitionName, partitionArg))
                }
            }
            addCommand(new MergeGenotyperOutput(vcfFile, unfilteredOutFile, gtPartFiles, runFilePrefix))
        }
        addCommand(new GenotyperDefaultFilterAnnotations(unfilteredOutFile, annotatedOutFile))
        addCommand(new SVGenotyperDefaultFilter(annotatedOutFile, outputFile))
        addCommand(new GenotyperDefaultQCAnnotations(outputFile, null))
    }
}
