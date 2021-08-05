import stanza, os
import numpy as np
from tok_format import tok_tokens_labels
from conll_format import begin_toks_sents
from task_data import rebuild_text
from stanza.utils.conll import CoNLL

RES_DIR = 'C:\\Users\\pc\\stanza_resources'

def ssplit_stanza(lang, fp_toks, out_dir, treebank=None):
    
    if not os.path.exists(os.path.join(RES_DIR, lang)):
        if treebank is not None:
            stanza.download(lang, package=treebank)
        else:
           stanza.download(lang) 
    processors = 'tokenize'
    nlp = stanza.Pipeline(lang, processors=processors, use_gpu=True)

    for fp_tok in fp_toks:
        # FIXME do both in one go
        # for each doc, get the list of tokens and labels
        tok_tok_lbls = [(doc_id, doc_toks, doc_lbls) for doc_id, doc_toks, doc_lbls in tok_tokens_labels(fp_tok)]
        # for each doc, get the character offset of tokens
        with open(fp_tok, encoding='utf-8') as f_tok:
            tok_str = f_tok.read()
        tok_tok_begs = [(doc_id, doc_chars, tok_begs) for doc_id, doc_chars, tok_begs, _ in begin_toks_sents(tok_str)]
        #
        # parse
        fp_out = os.path.join(out_dir, os.path.basename(fp_tok))
        fp_out = fp_out.replace('.tok', '.split.tok')
        with open(fp_out, mode='w', encoding='utf-8') as f_out:
            # parse each doc in turn
            for (doc_id, doc_toks, doc_lbls), (_, doc_chars, tok_begs) in zip(tok_tok_lbls, tok_tok_begs):
                doc_text = rebuild_text(doc_toks, lang=lang)
                # print(doc_text)
                ann = nlp(doc_text)
                conll_str = CoNLL.conll_as_string(CoNLL.convert_dict(ann.to_dict()))
                conll_tok_begs = list(begin_toks_sents(conll_str, True))
                # we parse one doc at a time
                assert len(conll_tok_begs) == 1
                _, p_doc_chars, p_tok_begs, p_sent_begs = conll_tok_begs[0]
                try:
                    assert p_doc_chars == doc_chars
                except AssertionError:
                    for i, (pdc, dc) in enumerate(zip(p_doc_chars, doc_chars)):
                        if pdc != dc:
                            print(fp_tok, i, p_doc_chars[i - 10:i + 10], doc_chars[i - 10:i + 10])
                            raise
                # for each beginning of sentence (in the parser output), find the corresponding token index in the original .tok
                sent_beg_idc = np.searchsorted(tok_begs, p_sent_begs, side='left')
                sent_beg_idc = set(sent_beg_idc)
                # output CONLL-U file
                f_out.write('# newdoc id = ' + doc_id + '\n')
                #print('# newdoc id = ' + doc_id, file=f_out)
                tok_sent_idx = 1
                for tok_doc_idx, (tok, lbl) in enumerate(zip(doc_toks, doc_lbls), start=0):
                    if tok_doc_idx in sent_beg_idc:
                        if tok_doc_idx > 0:
                            # add an empty line after the previous sentence (not for the first token in doc)
                            f_out.write('\n')
                            #print('', file=f_out)
                        tok_sent_idx = 1
                    else:
                        tok_sent_idx += 1
                    row = (str(tok_sent_idx), tok, '_', '_', '_', '_', '_', '_', '_', lbl)
                    f_out.write('\t'.join(row)+'\n')
                    #print('\t'.join(row).encode('utf-8'), file=f_out)
                f_out.write('\n')
                #print('', file=f_out)