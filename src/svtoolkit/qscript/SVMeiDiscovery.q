
import org.broadinstitute.sv.qscript.SVQScript

import org.broadinstitute.sv.queue.ComputeDiscoveryPartitions

class SVMeiDiscovery extends SVQScript {

    @Output(shortName="O", doc="The output vcf file.")
    var outputFile: File = null

    @Argument(shortName="partition", required=false, doc="Specific partitions to rerun")
    var partitionList: List[String] = null

    /**
     * In script, you create and add functions to the pipeline.
     */
    def script = {
        var unfilteredOutFile = new File(runDirectory, swapExt(outputFile, "vcf", "unfiltered.vcf").getName)
        val partitions = computeDiscoveryPartitions()
        if (partitions.isEmpty) {
            var runFilePrefix = outputFile.getName.stripSuffix(".vcf").stripSuffix(".discovery")
            addCommand(new SVDiscovery(unfilteredOutFile, runFilePrefix))
        } else {
            var discoPartFiles: List[File] = Nil
            for ((partitionName, partitionArgs) <- partitions) {
                if (partitionList == null || partitionList.contains(partitionName)) {
                    discoPartFiles :+= addCommand(new SVParallelDiscovery(partitionName, partitionArgs))
                }
            }
            addCommand(new MergeDiscoveryOutput(unfilteredOutFile, discoPartFiles))
        }
    }
}
