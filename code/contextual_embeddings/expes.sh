# usage
# bash expes.sh dataset config model action [parent]

echo "data=$1, config=$2, model=$3, action=$4"
   
export DATASET=${1}
# eg "eng.rst.gum"

export CONFIG=${2}
# options: conll tok split.tok

export MODEL=${3}
# options: bert xlm

export ACTION=${4}
# options: train test
 
if [ -z "$5" ];
then
    export HAS_PAR=false
    export TOOLONG=false
elif [ "${5}" = "--s" ];
then
    export TOOLONG=true
    export SPLIT=${6}
else
    export HAS_PAR=true
    export TOOLONG=false
    export PARENT=${5}
fi

if [ $# -eq 7 ] && [ "${6}" = "--s" ]; 
then
    export TOOLONG=true
    export SPLIT=${7}
fi

if [ "$MODEL" = "xlm" ]; 
then 
    export BERT_VOCAB="xlm-roberta-base"
    export BERT_WEIGHTS="xlm-roberta-base"
else
    export BERT_VOCAB="bert-base-multilingual-cased"
    export BERT_WEIGHTS="bert-base-multilingual-cased"                                                                                                   
fi

if [ "$ACTION" = "train" ];
then
    export EVAL=dev
else
    export EVAL=test
fi

export GOLD_BASE="data/"
export CONV="data_converted/"
export CODE="code/contextual_embeddings/"
export TRAIN_DATA_PATH=${CONV}${DATASET}"_train.ner."${CONFIG}
export TEST_A_PATH=${CONV}${DATASET}"_"${EVAL}".ner."${CONFIG}
export OUTPUT=${DATASET}"_"${MODEL}
export GOLD=${GOLD_BASE}${DATASET}"/"${DATASET}"_"${EVAL}"."${CONFIG}

mkdir -p ${CONV}

for val in "train" ${EVAL}; do
    export original=${GOLD_BASE}"/"${DATASET}"/"${DATASET}"_"${val}"."${CONFIG}
    export converted=${CONV}/${DATASET}"_"${val}".ner."${CONFIG}
    # conversion of datasets to NER / BIO format by first testing the existence of files so as not to redo it each time
    if [ ! -f ${converted} ]; then
        echo "converting "${val}" to ner format -> in data_converted ..."
        if [ $TOOLONG = true ];
        then 
            python ${CODE}conv2ner.py ${original} ${converted} --split-too-long True ${SPLIT}
        else
            python ${CODE}conv2ner.py ${original} ${converted}
        fi
    fi

done

if [ "$ACTION" = "train" ]; 
then
    if [ $HAS_PAR = true ]; 
    then
        echo "fine tune"
        # fine tune
        allennlp fine-tune -m Results_${CONFIG}/results_${PARENT}_${MODEL}/model.tar.gz -c ${CODE}configs/bert.jsonnet -s Results_${CONFIG}/results_${DATASET}-${PARENT}_${MODEL}
    else
        echo "train"
        # train with config in bert.jsonnet; the config references explicitely variables TRAIN_DATA_PATH and TEST_A_PATH
        allennlp train -s Results_${CONFIG}/results_${OUTPUT} ${CODE}configs/bert.jsonnet
    fi
elif [ $HAS_PAR = true ];
then
    if [ "$ACTION" = "test" ];
    then
        echo "parent test"
        export TRAIN_DATA_PATH=${CONV}${PARENT}"_train.ner."${CONFIG}
        export OUTPUT=${PARENT}"_"${MODEL}
    else
        echo "finetune test"
        export OUTPUT=${DATASET}"-"${PARENT}"_"${MODEL}
    fi
fi

# predict with model -> outputs json
allennlp predict --use-dataset-reader --output-file Results_${CONFIG}/results_${OUTPUT}/${DATASET}_${EVAL}.predictions.json Results_${CONFIG}/results_${OUTPUT}/model.tar.gz ${TEST_A_PATH} --silent
# convert to disrpt format 
python ${CODE}json2conll.py Results_${CONFIG}/results_${OUTPUT}/${DATASET}_${EVAL}.predictions.json ${CONFIG} Results_${CONFIG}/results_${OUTPUT}/${DATASET}_${EVAL}.predictions.${CONFIG}
# eval with disrpt script
python code/utils/seg_eval.py $GOLD Results_${CONFIG}/results_${OUTPUT}/${DATASET}_${EVAL}.predictions.${CONFIG} >> Results_${CONFIG}/results_${OUTPUT}/${DATASET}_${EVAL}.scores
