# export PATH=/Users/hieunguyen/samtools/bin:$PATH 

#####----------------------------------------------------------------------#####
##### input args
#####----------------------------------------------------------------------#####
while getopts "i:o:n:" opt; do
  case ${opt} in
    i )
      inputbam=$OPTARG
      ;;
    o )
      outputdir=$OPTARG
      ;;
    n )
      num_threads=$OPTARG
      ;;
    \? )
      echo "Usage: cmd [-i] inputbam [-o] outputdir [-n]"
      exit 1
      ;;
  esac
done

echo -e "input bam file: " ${inputbam}
# Check if the input BAM file exists
if [ ! -f "${inputbam}" ]; then
    echo "Input BAM file does not exist: ${inputbam}"
    exit 1
fi

sampleid=$(echo ${inputbam} | xargs -n 1 basename)
sampleid=${sampleid%.bam*}
outputdir=${outputdir}/${sampleid}

mkdir -p ${outputdir}

for chr in $(seq 1 22) X Y MT; do \
    echo $chr && \
    samtools view -@ ${num_threads} -f 3 -b $inputbam $chr -o ${outputdir}/${sampleid}.chr${chr}.bam;
    samtools sort -@ ${num_threads} ${outputdir}/${sampleid}.chr${chr}.bam -o ${outputdir}/${sampleid}.chr${chr}.sorted.bam;
    samtools index ${outputdir}/${sampleid}.chr${chr}.sorted.bam -@ ${num_threads};
    rm -rf ${outputdir}/${sampleid}.chr${chr}.bam
    samtools view ${outputdir}/${sampleid}.chr${chr}.sorted.bam | cut -f1,3,4,6,9 > ${outputdir}/${sampleid}.chr${chr}.txt;
    done