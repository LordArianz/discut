export CONFIG=${1}

datasets=("deu.rst.pcc" "eng.rst.gum" "eng.rst.rstdt" "eng.sdrt.stac" "eus.rst.ert" "fas.rst.prstc" "fra.sdrt.annodis" "nld.rst.nldt" "por.rst.cstn" "rus.rst.rrt" "spa.rst.rststb" "spa.rst.sctb" "zho.rst.sctb" "eng.pdtb.pdtb" "tur.pdtb.tdb" "zho.pdtb.cdtb")
groups=("eng.rst.gum","eng.rst.rstdt","eng_rst" "eng_rst","eng.sdrt.stac","eng" "deu.rst.pcc","nld.rst.nldt","deu_nld" "deu_nld","eng","ger" "spa.rst.rststb","spa.rst.sctb","spa" "spa","por.rst.cstn","spo")

if [ "$CONFIG" = "preprocess" ]; then
    for dataset in ${datasets[*]}; do
        echo "splitting "${dataset}" begins..."
        # python code/ssplit/parse_corpus.py ${dataset} --parser stanza --out_dir data
        echo "splitting "${dataset}" is done"
    done
    for group in ${groups[*]}; do IFS=","; set -- $group;
        echo "merging "$1" and "$2" into "$3" begins..."
        bash code/contextual_embeddings/merger.sh $1 $2 $3
        echo "merging "$1" and "$2" into "$3" is done"
    done
    exit
fi

if [ "$CONFIG" = "tok" ]; then
    for dataset in ${datasets[*]}; do
        if [ "$dataset" = "rus.rst.rrt" ] || [ "$dataset" = "tur.pdtb.tdb" ]; then
            bash code/contextual_embeddings/expes.sh ${dataset} split.tok bert train -s 200
        else
            bash code/contextual_embeddings/expes.sh ${dataset} split.tok bert train
        fi
    done
else    
    for group in "eng" "ger" "spo"; do 
        bash code/contextual_embeddings/expes.sh ${group} conllu bert train
    done
    for dataset in ${datasets[*]}; do
        if [ "$dataset" = "eng.pdtb.pdtb" ] || [ "$dataset" = "tur.pdtb.tdb" ] || [ "$dataset" = "zho.pdtb.cdtb" ] || [ "$dataset" = "eng.rst.rstdt" ] || [ "$dataset" = "eus.rst.ert" ] || [ "$dataset" = "fas.rst.prstc" ] || [ "$dataset" = "fra.sdrt.annodis" ] || [ "$dataset" = "nld.rst.nldt" ] || [ "$dataset" = "rus.rst.rrt" ] || [ "$dataset" = "zho.rst.sctb" ]; then
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert train
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert test
        elif [ "$dataset" = "deu.rst.pcc"]; then 
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert test ger
        elif [ "$dataset" = "eng.rst.gum"]; then
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert test eng
        elif [ "$dataset" = "eng.sdrt.stac"]; then
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert train eng
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert testft eng
        elif [ "$dataset" = "spa.rst.sctb"]; then
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert test spo
        elif [ "$dataset" = "spa.rst.rststb"] || [ "$dataset" = "por.rst.cstn"]; then
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert train spo
            bash code/contextual_embeddings/expes.sh ${dataset} ${CONFIG} bert testft spo
        fi
    done
fi