"""
maps conll 2003 format (4 fields) to Disrpt expected conll formats (10 fields)
"""

import sys

maptags = {"_":"O",
           "BeginSeg=Yes": "B-S",
           "Seg=B-Conn":"B-Conn",
           "Seg=I-Conn":"I-Conn",
           "SpaceAfter=No":"O",
           "Typo=Yes":"O",
           }

inv_map_tags = {maptags[k]:k for k in maptags}
inv_map_tags["O"]="_"


with open(sys.argv[1]) as f:
    output = []
    idx = 1
    for line in f:
        if line.strip()=="":
            output.append("")
            idx = 1
        else:
            token, pos, chk, label = line.strip().split()
            newline = [str(idx),token]+["_"]*7+[inv_map_tags[label]]
            idx = idx + 1
            output.append("\t".join(newline))


print("\n".join(output))
