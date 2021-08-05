import spacy, stanfordnlp

def sstanford(text):
    nlp = stanfordnlp.Pipeline(processors='tokenize', lang='en')
    doc = nlp(text)
    for sentence in doc.sentences:
        sent = ' '.join(word.text for word in sentence.words)
        print(sent)

def sspacy(text):
    nlp = spacy.load("en_core_web_sm")
    doc = nlp(text)
    for sent in doc.sents:
        print(sent)


text = "This is the first sentence. This is the second sentence This is the third sentence."
sstanford(text)
sspacy(text)