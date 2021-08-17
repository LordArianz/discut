export FIRST=${1}
export SECOND=${2}
export OUTPUT=${3}

echo "first=${FIRST}, second=${SECOND}, output=${OUTPUT}"

export BASE="data/"
export CONV="data_converted/"

mkdir -p $BASE$OUTPUT

for file1 in "$BASE$FIRST"/*
do
    if [ "${file1: -7}" == ".conllu" ] || [ "${file1: -5}" == ".rels" ] || [ "${file1: -4}" == ".tok" ]; then
        TYPE=${file1#$BASE$FIRST"/"$FIRST}
        file2=$BASE$SECOND"/"$SECOND$TYPE
        out=$BASE$OUTPUT"/"$OUTPUT$TYPE
        
        cat ${file1} ${file2} > ${out}
    fi
done

