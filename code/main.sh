echo "data=$1, config=$2, action=$3"

export DATASET=${1}
export CONFIG=${2}
export ACTION=${2}


if [ "$DATASET" = "stanza" ] then
    python ssplit/parse_corpus.py deu.rst.pcc --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py eng.rst.gum --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py eng.rst.rstdt --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py eng.sdrt.stac --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py eus.rst.ert --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py fas.rst.prstc --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py fra.sdrt.annodis --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py nld.rst.nldt --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py por.rst.cstn --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py rus.rst.rrt --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py spa.rst.rststb --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py spa.rst.sctb --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py zho.rst.sctb --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py eng.pdtb.pdtb --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py tur.pdtb.tdb --parser stanza --out_dir ../data
    python ssplit/parse_corpus.py zho.pdtb.cdtb --parser stanza --out_dir ../data
    exit
fi

if [ "$CONFIG" = "tok" ] then
    if [ "$DATASET" = "rus.rst.rrt" ] || [ "$DATASET" = "tur.pdtb.tdb" ] then
        bash contextual_embeddings/expes.sh ${DATASET} split.tok bert ${ACTION} -s 200
    else
        bash contextual_embeddings/expes.sh ${DATASET} split.tok bert ${ACTION}
    fi
elif [ "$DATASET" = "eng.pdtb.pdtb" ] || [ "$DATASET" = "tur.pdtb.tdb" ] || [ "$DATASET" = "zho.pdtb.cdtb" ] || [ "$DATASET" = "eng.rst.rstdt" ] || [ "$DATASET" = "eus.rst.ert" ] || [ "$DATASET" = "fas.rst.prstc" ] || [ "$DATASET" = "fra.sdrt.annodis" ] || [ "$DATASET" = "nld.rst.nldt" ] || [ "$DATASET" = "rus.rst.rrt" ] || [ "$DATASET" = "zho.rst.sctb" ] then
    bash contextual_embeddings/expes.sh ${DATASET} ${CONFIG} bert ${ACTION}
elif [ "$DATASET" = "deu.rst.pcc"] then # you don't have to merge two dataset many times or train a dataset many times. you can comment these parts after the first time.
    bash merger.sh eng.rst.gum eng.rst.rstdt eng_rst
    bash merger.sh eng_rst eng.sdrt.stac eng
    bash merger.sh deu.rst.pcc nld.rst.nldt deu_nld
    bash merger.sh deu_nld eng ger
    bash expes.sh ger conllu bert train
    bash expes.sh deu.rst.pcc conllu bert test ger
elif [ "$DATASET" = "eng.rst.gum"] then
    bash merger.sh eng.rst.gum eng.rst.rstdt eng_rst
    bash merger.sh eng_rst eng.sdrt.stac eng
    bash expes.sh eng conllu bert train
    bash expes.sh eng.rst.gum conllu bert test eng
elif [ "$DATASET" = "eng.sdrt.stac"] then
    bash merger.sh eng.rst.gum eng.rst.rstdt eng_rst
    bash merger.sh eng_rst eng.sdrt.stac eng
    bash expes.sh eng conllu bert train
    bash expes.sh eng.sdrt.stac conllu bert train eng
elif [ "$DATASET" = "spa.rst.sctb"] then
    bash merger.sh spa.rst.rststb spa.rst.sctb spa
    bash merger.sh spa por.rst.cstn spo
    bash expes.sh spo conllu bert train
    bash expes.sh spa.rst.sctb conllu bert test spo
elif [ "$DATASET" = "spa.rst.rststb"] then
    bash merger.sh spa.rst.rststb spa.rst.sctb spa
    bash merger.sh spa por.rst.cstn spo
    bash expes.sh spo conllu bert train
    bash expes.sh spa.rst.rststb conllu bert train spo
elif [ "$DATASET" = "por.rst.cstn"] then
    bash merger.sh spa.rst.rststb spa.rst.sctb spa
    bash merger.sh spa por.rst.cstn spo
    bash expes.sh spo conllu bert train
    bash expes.sh por.rst.cstn conllu bert train spo
fi