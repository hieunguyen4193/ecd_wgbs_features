export PATH=/Users/hieunguyen/samtools/bin:$PATH 

#####----------------------------------------------------------------------#####
##### input args
#####----------------------------------------------------------------------#####
while getopts "i:o:" opt; do
  case ${opt} in
    i )
      inputbam=$OPTARG
      ;;
    o )
      outputdir=$OPTARG
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

for chr in $(seq 1 22) X Y MT; do echo $chr && samtools view -b $inputbam $chr -o ${outputdir}/${sampleid}.chr${chr}.bam;done