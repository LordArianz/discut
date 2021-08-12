import pandas as pd
import os
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir', default='.', help='Scores directory')
    args = parser.parse_args()

    BASE_DIR = args.dir

    base_results = {}
    group_results = {}
    finetune_results = {}

    scnt = len(BASE_DIR.split('\\'))

    for root, dirs, files in os.walk(BASE_DIR):
        for file in files:
            is_group = False
            is_finetune = False
            if file.endswith('.scores'):
                address = os.path.join(root, file)
                # print(address)
                try:
                    cfg = address.split('\\')[scnt + 0].split('_')[1]
                    datasets = address.split('\\')[scnt + 1].split('-')
                    target = file.split('_')[0]
                    # print(datasets)
                    if len(datasets) > 1:
                        is_finetune = True
                        dts = '_'.join(datasets[-1].split('_')[:-1])
                    else:
                        dts = '_'.join(datasets[0].split('_')[1:-1])
                    evl = address.split('\\')[-1].split('_')[-1].split('.')[0]
                except:
                    continue
                if not is_finetune:
                    if len(dts.split('.')) != 3:
                        if len('_'.join(file.split('_')[:-1]).split('.')) != 3:
                            continue
                        is_group = True
                # print(is_group, is_finetune, cfg, dts, target, evl)
                if not is_group:
                    if not is_finetune:
                        if cfg not in base_results:
                            base_results[cfg] = {}
                        if dts not in base_results[cfg]:
                            base_results[cfg][dts] = {}
                        if evl not in base_results[cfg][dts]:
                            base_results[cfg][dts][evl] = {}
                    else:
                        if cfg not in finetune_results:
                            finetune_results[cfg] = {}
                        if target not in finetune_results[cfg]:
                            finetune_results[cfg][target] = {}
                        if dts not in finetune_results[cfg][target]:
                            finetune_results[cfg][target][dts] = {}
                        if evl not in finetune_results[cfg][target][dts]:
                            finetune_results[cfg][target][dts][evl] = {}
                else:
                    if cfg not in group_results:
                        group_results[cfg] = {}
                    if target not in group_results[cfg]:
                        group_results[cfg][target] = {}
                    if dts not in group_results[cfg][target]:
                        group_results[cfg][target][dts] = {}
                    if evl not in group_results[cfg][target][dts]:
                        group_results[cfg][target][dts][evl] = {}
                with open(address, 'r') as f:
                    for line in f:
                        if line.startswith('o'):
                            data = line.split()
                            if data[1][:-1] in ['Precision', 'Recall', 'F-Score']:
                                if not is_group:
                                    if not is_finetune:
                                        base_results[cfg][dts][evl][data[1][:-1]] = "{:.2f}".format(float(data[-1]) * 100.0)
                                    else:
                                        finetune_results[cfg][target][dts][evl][data[1][:-1]] = "{:.2f}".format(float(data[-1]) * 100.0)
                                else:
                                    group_results[cfg][target][dts][evl][data[1][:-1]] = "{:.2f}".format(float(data[-1]) * 100.0)

    # print(base_results)
    # print(group_results)
    # print(finetune_results)                        
    columns = ['Precision', 'Recall', 'F-Score']
    eval = 'test'
    tables = {}
    base = {'system': [], 'task': [], 'input': [], 'corpus': [], 'f1': []}
    best = {'system': [], 'task': [], 'input': [], 'corpus': [], 'f1': [], 'type': [], 'parent': []}

    for input, data in base_results.items():
        rst = pd.DataFrame(index=[x for x in data.keys() if x.split('.')[1] != 'pdtb'], columns=columns)
        pdtb = pd.DataFrame(index=[x for x in data.keys() if x.split('.')[1] == 'pdtb'], columns=columns)

        for dataset, vals in data.items():
            base['system'].append('disrpt21')
            base['input'].append('conll' if input in ['conll', 'conllu'] else 'tok')
            base['corpus'].append(dataset)
            best['system'].append('disrpt21')
            best['input'].append('conll' if input in ['conll', 'conllu'] else 'tok')
            best['corpus'].append(dataset)

            base['f1'].append(vals[eval]['F-Score'])
            if dataset.split('.')[1] == 'pdtb':
                base['task'].append('pdtb')
                best['task'].append('pdtb')
                pdtb.loc[dataset] = vals[eval]
            else:
                base['task'].append('seg')
                best['task'].append('seg')
                rst.loc[dataset] = vals[eval]
            
            results = [(vals[eval]['F-Score'], vals['test']['F-Score'], 'IND', '-')]
            try:
                results.extend([(res[eval]['F-Score'], res['test']['F-Score'], 'GRP', par) for par, res in group_results[input][dataset].items()])
            except:
                pass
            try:
                results.extend([(res[eval]['F-Score'], res['test']['F-Score'], 'FTN', par) for par, res in finetune_results[input][dataset].items()])
            except:
                pass
            winner = max(results, key = lambda i : i[0])
            best['f1'].append(winner[1])
            best['type'].append(winner[2])
            best['parent'].append(winner[3])
            #print(input, dataset, winner)

        tables[input] = [rst, pdtb]

    # df1 = pd.DataFrame(base)
    # df1 = df1.sort_values(['task', 'input', 'corpus'])
    # df1.to_csv('scores21.tsv', sep = '\t', index=False)

    df2 = pd.DataFrame(best)
    df2 = df2.sort_values(['task', 'input', 'corpus'])
    df2.to_csv('best_scores21.tsv', sep = '\t', index=False)