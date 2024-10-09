inputbam="/media/hieunguyen/GSHD_HN01/storage/bam_files/highdepth_cancer_WGBS_bismark.bam";
outputdir="./output";
bash split_bam_file_to_chroms.sh -i $inputbam -o $outputdir;