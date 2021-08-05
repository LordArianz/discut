"""
Convert to ner Connl format to use allennlp dataset reader

basically, just skip lines between docs, strip to 4 fields with words as 1st and tag as last, and format as BIO

TODO: try BIOUL (L=last, U=unit entity = 1 token)
"""
import sys, os, re
import argparse 

parser = argparse.ArgumentParser()
parser.add_argument("filepath", help="path to file to convert")
parser.add_argument("output", help="path of output file")
parser.add_argument("--lemmatize", default=False, action='store_true', help="to use with conll input: replace token with its lemma (useful for turk)")
parser.add_argument("--mark-end", default=False, action='store_true', help="add explicit label for end of segment")
parser.add_argument("--split-too-long", default=[False, 180], help="split sentences longer than threshold", nargs=2)
parser.add_argument("--input-format",default="conll", help="input format: tok, split.tok, conll ner")


args = parser.parse_args()


maptags = {
    "_":"O",
    "BeginSeg=Yes": "B-S",
    "Seg=B-Conn":"B-Conn",
    "Seg=I-Conn":"I-Conn",
    "SpaceAfter=No":"O",
    "Typo=Yes":"O",
}

badbytes = {
    'eus.rst.ert': [b'\xc2\x93', b'\xc2\x94'],
    'spa.rst.rststb': [b'\xc2\x96', b'\xc2\x91', b'\xc2\x80'],
    'spa.rst.sctb': [b'\xe2\x80\x90']
}

badchars = {
    '”': '\"',
    'Í': 'I',
    'Á': 'A',
    'Ã': 'A',
    'à': 'a'
}

# 
MARK_END = args.mark_end
# take lemmas instead of token forms (useful for turkish)
# also tag all proper nouns with same token
LEMMATIZE = args.lemmatize
# split for too long sentences (default 180) for bert
SPLIT_TOO_LONG= args.split_too_long[0]
THRESHOLD = int(args.split_too_long[1])

#filepath = sys.argv[1]
filepath = args.filepath

input_format = args.input_format
output_file = args.output

if SPLIT_TOO_LONG:
    print("warning: too-long sentence splitting mode = ON ",file=sys.stderr)

token_number=0
res = []
with open(filepath, encoding='utf-8') as f:
    start_doc = True
    
    for line in f:
        if input_format=="ner":
            token_number +=1
            if SPLIT_TOO_LONG and token_number>THRESHOLD:
                # sentence too long: insert a newline to make a separate sequence       
                res.append([])
                token_number = 0 
            res.append(line.split())
        elif "\t" not in line:
            if not(start_doc): 
                res.append([]) # [line.strip()])
            start_doc = True
        #elif line.strip()=="":
        #    res.append([])
        #    start_doc = True
        else:
            fields = line.strip().split()
            if len(fields[0].split('-')) > 1: # or len(fields[0].split('.')) > 1:
                continue
            #print(fields,file=sys.stderr)
            token_number = int(fields[0].split("-")[0].split(".")[0])
            if SPLIT_TOO_LONG and token_number>THRESHOLD:
                # sentence too long: insert a newline to make a separate sequence
                res.append([])
            w = fields[1] if not(LEMMATIZE) else fields[2]
            label = fields[-1].split("|")[0]
            if input_format=="conll":
                if LEMMATIZE and fields[3]=="PROPN":
                    w = "NAME"
                pos = "NN"
            else:
                pos = "NN"
            tag = maptags.get(label,"O")
            #if start_doc:
            #    tag = "B-S"
            if not(start_doc) and MARK_END and tag=="B-S" and res[-1][-1]!="B-S":
                # then, previous token label is set to B-E to signal end of previous segment
                res[-1][-1] = "B-E"
            start_doc = False
            if label not in maptags:
                print("warning, strange label ",label,file=sys.stderr)
            res.append([w,pos,"O",tag])
            
    # for line in res:
    #     print("\t".join(line))
dataset = filepath.split('/')[-1].split('_')[0]
with open(output_file, 'w', encoding='utf-8') as out:
    for ind, line in enumerate(res):
        if len(line) > 0:
            for bb in badbytes.get(dataset, []):
                enc = line[0].encode().replace(bb, b'')
                line[0] = enc.decode()
            for bc, gc in badchars.items():
                line[0] = line[0].replace(bc, gc)
            if len(line[0]) == 0:
                line[0] = ','
        tmp = '\t'.join(line) + '\n'
        out.write(tmp)
