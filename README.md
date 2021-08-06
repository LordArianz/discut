# disCut

Discourse segmenter for DISRPT 2021

Useful Links:
- Data for DISRPT 2021: https://github.com/disrpt/sharedtask2021 
- Website DISRPT 2021: https://sites.google.com/georgetown.edu/disrpt2021
- Code for DISRTP 2019: https://gitlab.inria.fr/andiamo/tony

Requirements:
- python 3.7
- requirements.txt: `pip install -r requirements.txt`
- pytorch: `pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio===0.9.0 -f https://download.pytorch.org/whl/torch_stable.html`

Before start:
- Please put the data at `data` directory

Usage:
- split all datasets for the first time: `bash code/main.sh preprocess`
- generate the best result for a dataset: `bashe code/main.sh eng.rst.rstdt conllu train`
- train: `bash code/contextual_embeddings/expes.sh eng.rst.rstdt conllu bert train [-s 200]`
#for split the long sentences
- test: `bash code/contextual_embeddings/expes.sh eng.rst.rstdt conllu bert test`
- fine-tune with other model: `bash code/contextual_embeddings/expes.sh eng.rst.rstdt conllu bert train eng`
- test on other model: `bash code/contextual_embeddings/expes.sh eng.rst.rstdt conllu bert test eng`
- merge two datasets: `bash code/contextual_embeddings/merger.sh eng.rst.rstdt eng.rst.gum eng`
- split with stanza: `python code/ssplit/parse_corpus.py eng.rst.rstdt --parser stanza`
