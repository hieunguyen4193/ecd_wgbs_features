// ----- ----- ----- CHANNEL ----- ----- -----
params.input_file= "$params.input/*.bam"
src=file(params.src)
params.num_threads = ""
params.src = ""
Channel
    .fromPath( params.input_file )
    .ifEmpty { error "Cannot find any reads matching: ${params.input_file}"  }
    .view()
    .set {input_ch}

process split_bam_to_22_chroms {
    cache "deep";
    publishDir "$params.output/output", mode: 'copy'
    // errorStrategy 'retry'
    // maxRetries 1
    maxForks 3

    input:
        file(input_file) from input_ch
        file src
    output:
        file("*") into output_ch
    script:
    """
    bash ${params.src} -i ${input_file} -o . -n ${params.num_threads}
    """
}

// nextflow run preprocessing_WGBS_highdepth_bam.nf \
//     --input /mnt/archiving/DATA_HIEUNHO/GW-bismark_cfDNA-highdepth_pair-end/04_bismark_deduplicated_sorted \
//     --output /mnt/archiving/DATA_HIEUNHO/GW-bismark_cfDNA-highdepth_pair-end/04_bismark_deduplicated_sorted \
//     --src /datassd/DATA_HIEUNGUYEN/2024/outdir/WGBS_highdepth_readID/ecd_wgbs_features/split_bam_file_to_chroms.sh \
//     --num_threads 10 \
//     -resume 