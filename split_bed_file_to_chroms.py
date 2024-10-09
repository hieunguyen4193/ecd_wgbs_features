import pandas as pd
import numpy as np
import os
from tqdm import tqdm
import pathlib
import pysam
import pyfaidx
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True, help='Path to input bed file')
    args = parser.parse_args()
    inputbed = args.input
    df = pd.read_csv(inputbed, sep = "\t", header = None)
    filename = inputbed.split("/")[-1]
    os.system(f"mkdir -p {os.path.join(inputbed.replace(filename, ''), filename.replace('.bed', ''))}")
    for chr in range(1, 23):
        tmpdf = df[df[0] == chr].copy()
        tmpdf.to_csv(os.path.join(inputbed.replace(filename, ""), filename.replace(".bed", ""), f"chr{chr}.bed"), sep = "\t", header = False, index = False)

if __name__ == '__main__':
    main()
