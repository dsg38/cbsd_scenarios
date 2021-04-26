import utils_parse
from pathlib import Path
import pandas as pd

restartJsonPathStr = './stuff.json'
paramsTemplateDfPathStr = '../launch/2021_03_17_cross_continental_params.txt'

paramsDfOutPath = Path('../launch/2021_04_26_cross_continental_restart_params.txt')

# ----------------------------------------------------
restartJsonPath = Path(restartJsonPathStr)
paramsTemplateDfPath = Path(paramsTemplateDfPathStr)

restartDict = utils_parse.readJsonToDict(restartJsonPath)
paramsTemplateDf = pd.read_csv(paramsTemplateDfPath, delim_whitespace=True)

if paramsTemplateDf.shape[0] != 1:
    raise Exception("inputParamsDfNotOneRow")

rowList = []
for k, v in restartDict.items():

    print(k)

    thisRow = paramsTemplateDf.copy()
    thisRow['RNGSeed'] = v['params']['RNGSeed']

    rowList.append(thisRow)

paramsDf = pd.concat(rowList)

paramsDf.to_csv(paramsDfOutPath, sep=" ", index=False)
