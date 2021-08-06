if [ $# -eq 3 ]; 
then
    echo "data=$1, config=$2, action=$3"
else
    echo "Preprocessing..."
fi

export DATASET=${1}
export CONFIG=${2}
export ACTION=${3}


if [ "$DATASET" = "preprocess" ]; then
    echo "splitting deu.rst.pcc begins..."
    python code/ssplit/parse_corpus.py deu.rst.pcc --parser stanza --out_dir data
    echo "splitting deu.rst.pcc is done"
    echo "splitting eng.rst.gum begins..."
    python code/ssplit/parse_corpus.py eng.rst.gum --parser stanza --out_dir data
    echo "splitting eng.rst.gum is done"
    echo "splitting eng.rst.rstdt begins..."
    python code/ssplit/parse_corpus.py eng.rst.rstdt --parser stanza --out_dir data
    echo "splitting eng.rst.rstdt is done"
    echo "splitting eng.sdrt.stac begins..."
    python code/ssplit/parse_corpus.py eng.sdrt.stac --parser stanza --out_dir data
    echo "splitting eng.sdrt.stac is done"
    echo "splitting eus.rst.ert begins..."
    python code/ssplit/parse_corpus.py eus.rst.ert --parser stanza --out_dir data
    echo "splitting eus.rst.ert is done"
    echo "splitting fas.rst.prstc begins..."
    python code/ssplit/parse_corpus.py fas.rst.prstc --parser stanza --out_dir data
    echo "splitting fas.rst.prstc is done"
    echo "splitting fra.sdrt.annodis begins..."
    python code/ssplit/parse_corpus.py fra.sdrt.annodis --parser stanza --out_dir data
    echo "splitting fra.sdrt.annodis is done"
    echo "splitting nld.rst.nldt begins..."
    python code/ssplit/parse_corpus.py nld.rst.nldt --parser stanza --out_dir data
    echo "splitting nld.rst.nldt is done"
    echo "splitting por.rst.cstn begins..."
    python code/ssplit/parse_corpus.py por.rst.cstn --parser stanza --out_dir data
    echo "splitting por.rst.cstn is done"
    echo "splitting rus.rst.rrt begins..."
    python code/ssplit/parse_corpus.py rus.rst.rrt --parser stanza --out_dir data
    echo "splitting rus.rst.rrt is done"
    echo "splitting spa.rst.rststb begins..."
    python code/ssplit/parse_corpus.py spa.rst.rststb --parser stanza --out_dir data
    echo "splitting spa.rst.rststb is done"
    echo "splitting spa.rst.sctb begins..."
    python code/ssplit/parse_corpus.py spa.rst.sctb --parser stanza --out_dir data
    echo "splitting spa.rst.sctb is done"
    echo "splitting zho.rst.sctb begins..."
    python code/ssplit/parse_corpus.py zho.rst.sctb --parser stanza --out_dir data
    echo "splitting zho.rst.sctb is done"
    echo "splitting eng.pdtb.pdtb begins..."
    python code/ssplit/parse_corpus.py eng.pdtb.pdtb --parser stanza --out_dir data
    echo "splitting eng.pdtb.pdtb is done"
    echo "splitting tur.pdtb.tdb begins..."
    python code/ssplit/parse_corpus.py tur.pdtb.tdb --parser stanza --out_dir data
    echo "splitting tur.pdtb.tdb is done"
    echo "splitting zho.pdtb.cdtb begins..."
    python code/ssplit/parse_corpus.py zho.pdtb.cdtb --parser stanza --out_dir data
    echo "splitting zho.pdtb.cdtb is done"
    echo "merging eng.rst.gum and eng.rst.rstdt begins..."
    bash code/contextual_embeddings/merger.sh eng.rst.gum eng.rst.rstdt eng_rst
    echo "merging eng.rst.gum and eng.rst.rstdt is done"
    echo "merging eng_rst and eng.sdrt.stac begins..."
    bash code/contextual_embeddings/merger.sh eng_rst eng.sdrt.stac eng
    echo "merging eng_rst and eng.sdrt.stac is done"
    echo "merging deu.rst.pcc and nld.rst.nldt begins..."
    bash code/contextual_embeddings/merger.sh deu.rst.pcc nld.rst.nldt deu_nld
    echo "merging deu.rst.pcc and nld.rst.nldt is done"
    echo "merging deu_nld and eng begins..."
    bash code/contextual_embeddings/merger.sh deu_nld eng ger
    echo "merging deu_nld and eng is done"
    echo "merging spa.rst.rststb and spa.rst.sctb begins..."
    bash code/contextual_embeddings/merger.sh spa.rst.rststb spa.rst.sctb spa
    echo "merging spa.rst.rststb and spa.rst.sctb is done"
    echo "merging spa and por.rst.cstn begins..."
    bash code/contextual_embeddings/merger.sh spa por.rst.cstn spo
    echo "merging spa and por.rst.cstn is done"
    exit
fi

if [ "$CONFIG" = "tok" ]; then
    if [ "$DATASET" = "rus.rst.rrt" ] || [ "$DATASET" = "tur.pdtb.tdb" ]; then
        bash code/contextual_embeddings/expes.sh ${DATASET} split.tok bert ${ACTION} -s 200
    else
        bash code/contextual_embeddings/expes.sh ${DATASET} split.tok bert ${ACTION}
    fi
elif [ "$DATASET" = "eng.pdtb.pdtb" ] || [ "$DATASET" = "tur.pdtb.tdb" ] || [ "$DATASET" = "zho.pdtb.cdtb" ] || [ "$DATASET" = "eng.rst.rstdt" ] || [ "$DATASET" = "eus.rst.ert" ] || [ "$DATASET" = "fas.rst.prstc" ] || [ "$DATASET" = "fra.sdrt.annodis" ] || [ "$DATASET" = "nld.rst.nldt" ] || [ "$DATASET" = "rus.rst.rrt" ] || [ "$DATASET" = "zho.rst.sctb" ]; then
    bash code/contextual_embeddings/expes.sh ${DATASET} ${CONFIG} bert ${ACTION}
elif [ "$DATASET" = "deu.rst.pcc"]; then # you don't have to merge two dataset many times or train a dataset many times. you can comment these parts after the first time.
    bash code/contextual_embeddings/expes.sh ger conllu bert train
    bash code/contextual_embeddings/expes.sh deu.rst.pcc conllu bert test ger
elif [ "$DATASET" = "eng.rst.gum"]; then
    bash code/contextual_embeddings/expes.sh eng conllu bert train
    bash code/contextual_embeddings/expes.sh eng.rst.gum conllu bert test eng
elif [ "$DATASET" = "eng.sdrt.stac"]; then
    bash code/contextual_embeddings/expes.sh eng conllu bert train
    bash code/contextual_embeddings/expes.sh eng.sdrt.stac conllu bert train eng
elif [ "$DATASET" = "spa.rst.sctb"]; then
    bash code/contextual_embeddings/expes.sh spo conllu bert train
    bash code/contextual_embeddings/expes.sh spa.rst.sctb conllu bert test spo
elif [ "$DATASET" = "spa.rst.rststb"]; then
    bash code/contextual_embeddings/expes.sh spo conllu bert train
    bash code/contextual_embeddings/expes.sh spa.rst.rststb conllu bert train spo
elif [ "$DATASET" = "por.rst.cstn"]; then
    bash code/contextual_embeddings/expes.sh spo conllu bert train
    bash code/contextual_embeddings/expes.sh por.rst.cstn conllu bert train spo
fi