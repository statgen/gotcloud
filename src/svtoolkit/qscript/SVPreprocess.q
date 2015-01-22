import org.broadinstitute.sv.qscript.SVQScript
import org.broadinstitute.sting.utils.help.DocumentedGATKFeature

//@QscriptDocStart
@DocumentedGATKFeature(groupName = "Queue Scripts")
class SVPreprocess extends SVQScript {

    @Argument(shortName="useMultiStep", required=false, doc="Use more parallel jobs to compute the metadata")
    var useMultiStep: Boolean = false

    @Argument(fullName="computeSizesInterval", shortName="computeSizesInterval", required=false, doc="Genome interval for which the genome sizes are to be computed")
    var computeSizesInterval: String = null;

    @Argument(shortName="reduceInsertSizeDistributions", required=false, doc="Reduces memory footprint by creating reduced representations of insert size distributions")
    var reduceInsertSizeDistributions: Boolean = false

    @Argument(shortName="computeGCProfiles", required=false, doc="Compute GC bias profiles needed to do GC-bias normalization (requires copy number mask)")
    var computeGCProfiles: Boolean = false

    @Argument(shortName="computeReadCounts", required=false, doc="Pre-compute read counts and create on-disk cache (experimental, not for general use yet)")
    var computeReadCounts: Boolean = false

//@QscriptDocEnd

    var isdHistFiles: List[File] = Nil
    var depthFiles: List[File] = Nil
    var countFiles: List[File] = Nil
    var spanFiles: List[File] = Nil
    var gcProfileFiles: List[File] = Nil
    var gcRefProfile: File = null

    /**
     * In script, you create and add functions to the pipeline.
     */
    def script = {
        addCommand(new CreateMetaDataDirectory())
        addCommand(new ComputeGenomeSizes(computeSizesInterval))
        if (computeGCProfiles) {
            gcRefProfile = addCommand(new ComputeGCReferenceProfile(computeSizesInterval))
        }

        for (bamLocation <- bamLocations) {
            isdHistFiles :+= addCommand(new ComputeInsertSizeHistograms(bamLocation))
        }
        if (reduceInsertSizeDistributions) {
            var isdDistFiles: List[File] = Nil
            for (histFile <- isdHistFiles) {
                isdDistFiles :+= addCommand(new ReduceInsertSizeHistograms(histFile))
            }
            val isdDistFile = addCommand(new MergeInsertSizeDistributions(isdDistFiles))
            val isdStatsFile = addCommand(new ComputeInsertStatistics(isdDistFile))
        } else {
            val isdHistFile = addCommand(new MergeInsertSizeHistograms(isdHistFiles))
            val isdStatsFile = addCommand(new ComputeInsertStatistics(isdHistFile))
        }

        if (useMultiStep) {
            createMultiStepScript
        } else {
            createTwoStepScript
        }
    }

    def createMultiStepScript = {
        for (bamLocation <- bamLocations) {
            depthFiles :+= addCommand(new ComputeReadDepthCoverage(bamLocation))
        }
        addCommand(new MergeReadDepthCoverage(depthFiles))

        for (bamLocation <- bamLocations) {
            spanFiles :+= addCommand(new ComputeReadSpanCoverage(bamLocation))
        }
        addCommand(new MergeReadSpanCoverage(spanFiles))

        if (computeGCProfiles) {
            for (bamLocation <- bamLocations) {
                gcProfileFiles :+= addCommand(new ComputeGCProfiles(bamLocation, gcRefProfile))
            }
            addCommand(new MergeGCProfiles(gcProfileFiles))
        }

        if (computeReadCounts) {
            for (bamLocation <- bamLocations) {
                val countFile = addCommand(new ComputeReadCounts(bamLocation))
                addCommand(new IndexReadCountFile(countFile))
                countFiles :+= countFile
            }
            mergeReadCountsByLocus(countFiles)
        }
    }

    def createTwoStepScript = {
        for (bamLocation <- bamLocations) {
            val computeMetadataCommand = new ComputeMetadata(bamLocation, computeGCProfiles, computeReadCounts, gcRefProfile)
            addCommand(computeMetadataCommand)

            depthFiles :+= computeMetadataCommand.depthFile
            spanFiles :+= computeMetadataCommand.spanFile

            if (computeGCProfiles) {
                computeMetadataCommand.dependsOnFile :+= gcRefProfile
                gcProfileFiles :+= computeMetadataCommand.gcProfileFile
            }
            if (computeReadCounts) {
                countFiles :+= computeMetadataCommand.readCountFile
                addCommand(new IndexReadCountFile(computeMetadataCommand.readCountFile))
            }
        }

        addCommand(new MergeReadDepthCoverage(depthFiles))
        addCommand(new MergeReadSpanCoverage(spanFiles))

        if (computeGCProfiles) {
            addCommand(new MergeGCProfiles(gcProfileFiles))
        }
        if (computeReadCounts) {
            mergeReadCountsByLocus(countFiles)
        }
    }
}
