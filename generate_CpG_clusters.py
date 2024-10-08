import pandas as pd
import numpy as np
import os
from tqdm import tqdm
import pathlib
import pysam
import pyfaidx
import argparse

'''
Run this script to construct CpG clusters across the whole genome. 
A CpG cluster is defined as a cluster of at least 5 CpG sites within a radius of 100 bp (default).
The output is a bed file with the following columns: chromosome, region start, region end, region name, number of CpG sites in the region.
Download the latest version of human reference genome hg19 at: https://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/
'''

# path to the folder containing all the fasta files of the human reference genome hg19
def main():
    # path_to_all_fa = "/Users/hieunguyen/data/resources/hg19"
    # radius = 100
    # min_num_Cpg = 4

    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True, help='Path to input FASTA of hg19/hg38')
    parser.add_argument('--output', type=str, required=True, help='Path to save output')
    parser.add_argument('--radius', type=int, required=True, help='Length of the CpG cluster windows (radius)')
    parser.add_argument('--min_num_cpg', type=int, required=True, help='Minimum number of CpG sites in a region')
    
    args = parser.parse_args()
    path_to_all_fa = args.input
    radius = args.radius
    min_num_Cpg = args.min_num_cpg
    outputdir = args.output
    
    os.system(f"mkdir -p {outputdir}")
    
    all_fa_files = [file for file in pathlib.Path(path_to_all_fa).glob("*.fa")]

    output = open(f"{outputdir}/CpG_clusters_whole_genome_radius_{radius}_minCpG_{min_num_Cpg}.bed", 'w')
        
    for file in sorted(all_fa_files):
        filename = file.name.strip(".fa")
        
        print("Working on {}".format(file))
        fasta_file = pyfaidx.Fasta(file)

        ref_seq = fasta_file.get_seq(name = file.name.strip(".fa"), start = 1, end = fasta_file[file.name.strip(".fa")][-1].start)
        ref_seq = ref_seq.seq

        def find_CpG(ref_seq):
            import re
            all_C_positions = [m.start(0) for m in re.finditer("CG", ref_seq)]
            all_c_positions = [m.start(0) for m in re.finditer("cg", ref_seq)]
            all_cG_positions = [m.start(0) for m in re.finditer("cG", ref_seq)]
            return all_C_positions + all_c_positions + all_cG_positions

        all_cpg_positions = sorted(find_CpG(ref_seq))

        all_pos = all_cpg_positions.copy()

        anchor = all_pos[0]

        tmp_cpg_clusters = dict()
        cpg_cluster_idx = 0
        tmp_cpg_clusters[cpg_cluster_idx] = [anchor]

        for item in tqdm(all_pos[1:]):
            if (item - anchor) <= radius:
                tmp_cpg_clusters[cpg_cluster_idx].append(item)
            else:
                cpg_cluster_idx += 1
                anchor = item        
                tmp_cpg_clusters[cpg_cluster_idx] = [anchor]

                all_cpg_cluster = dict()

        for key in tmp_cpg_clusters.keys():
            if (len(tmp_cpg_clusters[key]) >= min_num_Cpg):
                all_cpg_cluster[key] = tmp_cpg_clusters[key]
                
        for key in all_cpg_cluster.keys():
            cluster = all_cpg_cluster[key]
            start = np.min(cluster) - 1
            end = np.max(cluster) + 1
            chrom = filename.strip("chr")
            num_cpg = len(cluster)
            region_name = "{}:{}-{}".format(chrom, start, end)

            output.write(chrom + '\t' + str(start) + '\t' + str(end) + '\t' + "{}_bin_{}".format(chrom, key) + "\t" + str(num_cpg) + "\t" + region_name + '\n')

if __name__ == '__main__':
    main()
