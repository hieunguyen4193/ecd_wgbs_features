// ----- ----- ----- CHANNEL ----- ----- -----
params.input_file= "$params.input/*.bam"
src=file(params.src)
params.num_threads = ""

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
    bash split_bam_file_to_chroms.sh -i ${input_file} -o . -n ${params.num_threads}
    """
}

// example command:
//  nextflow run run_nextflow_for_03.nf \
//  --input /mnt/archiving/DATA_HIEUNHO/ecd_wgs_features_trong_hieu/ready-to-use \
//  --output /datassd/hieunguyen/2024/outdir/ecd_wgs_features/images \
//  --src /datassd/hieunguyen/2024/src/ecd_wgs_features/03_generate_WGS_features.py \
//  --motif_order /datassd/hieunguyen/2024/src/ecd_wgs_features/motif_order.csv \
//  --feature_version "old" --generate_feature "image_only" --old_nuc "none" -resume