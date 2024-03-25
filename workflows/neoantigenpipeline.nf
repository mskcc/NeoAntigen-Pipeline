/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_neoantigenpipeline_pipeline'
include { PHYLOWGS_CREATEINPUT } from '../modules/msk/phylowgs/createinput/main'
include { PHYLOWGS_MULTIEVOLVE } from '../modules/msk/phylowgs/multievolve/main'
include { PHYLOWGS_PARSECNVS } from '../modules/msk/phylowgs/parsecnvs/main'
include { PHYLOWGS_WRITERESULTS } from '../modules/msk/phylowgs/writeresults/main'
include { NEOANTIGENINPUT } from '../modules/msk/neoantigeninput/main'
include { NETMHCPAN } from '../modules/msk/netmhcpan/main'
include { NEOANTIGENEDITING_ALIGNTOIEDB } from '../modules/msk/neoantigenediting/aligntoIEDB'
include { NEOANTIGENEDITING_COMPUTEFITNESS } from '../modules/msk/neoantigenediting/computeFitness'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NEOANTIGENPIPELINE {

    take:
    ch_samplesheet // channel: samplesheet read in from --input It should have maf, polysolver file, facets gene level file
    netMHCpan_input_ch

    main:

    ch_versions = Channel.empty()

    ch_samplesheet.map {
            meta, maf, facets_gene, hla_file ->
                [meta.id, maf, hla_file]
                
        }
        .set { netMHCpan_input_ch }
    

    ch_samplesheet.map {
            meta, maf, facets_gene, hla_file ->
                [meta.id, maf, facets_gene]
                
        }
        .set { phylowgs_input_ch }

    // phylowgs workflow

    NETMHCPAN(netMHCpan_input_ch)

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(storeDir: "${params.outdir}/pipeline_info", name: 'nf_core_pipeline_software_mqc_versions.yml', sort: true, newLine: true)
        .set { ch_collated_versions }



    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
