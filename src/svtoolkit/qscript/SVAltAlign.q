
import org.broadinstitute.sv.qscript.SVQScript

class SVAltAlign extends SVQScript {

    @Input(fullName="vcfFile", shortName="vcf", doc="The vcf file of events to genotype.")
    var vcfFile: File = null

    @Output(fullName="outFile", shortName="O", required=false, doc="Output bam file of alternate allele alignments.")
    var outputFile: File = null

    /**
     * In script, you create and add functions to the pipeline.
     */
    def script = {
        var altReference: File = addCommand(new GenerateAltAlleleFasta(vcfFile))
        var altReferenceDict: File = addCommand(new GenerateAltAlleleDictionary(altReference))
        var altReferenceIndex: File = addCommand(new IndexFastaFile(altReference))
        var altReferenceBWAIndex: File = addCommand(new CreateBwaIndex(altReference))
        var altBamFiles: List[File] = Nil
        for (bamLocation <- bamLocations) {
            altBamFiles :+= addCommand(new SVAltAligner(bamLocation, altReference))
        }
        if (outputFile == null) {
            outputFile = new File(runDirectory, swapExt(vcfFile, "vcf", "alt.bam").getName())
        }
        var altMergedBam: File = addCommand(new MergeSamFiles(altBamFiles, outputFile))
        var altMergedBamIndex: File = addCommand(new CreateBamIndex(altMergedBam))
    }
}
