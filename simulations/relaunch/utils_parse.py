
from pathlib import Path
import pandas as pd
import json

def parseMaster(masterPath: Path) -> dict:
    
    masterLines = masterPath.read_text().split('\n')

    masterDict = {}
    for masterLine in masterLines:

        notEmptyBool = not masterLine.isspace()
        startsWithLetterBool = masterLine[:1].isalpha()

        if notEmptyBool and startsWithLetterBool:

            splitLine = masterLine.split(None, maxsplit=1)

            masterDict[splitLine[0]] = splitLine[1]
    
    return masterDict


def buildRestartDict(
    batchDfPath: Path,
    ):

    progressDfPath = batchDfPath / 'progress.csv'

    progressDf = pd.read_csv(progressDfPath)

    relaunchDf = progressDf[progressDf['dpcLastSimTime'] != 2050]

    restartDict = {}
    for i, row in relaunchDf.iterrows():

        scenarioName = row['scenarioName']
        batchName = row['batchName']
        jobName = row['jobName']

        simPath = Path(scenarioName) / batchName / jobName

        jobDir = batchDfPath / jobName

        # Parse master file
        masterPathList = list(jobDir.rglob("M_MASTER.txt"))

        if len(masterPathList) != 1:
            raise Exception("masterListLenError")
        
        masterDict = parseMaster(masterPathList[0])

        # Parse sim params file
        simParamsPathList = list(jobDir.rglob("O_0_ParameterDistribution_0_Log.txt"))
        
        if len(simParamsPathList) != 1:
            raise Exception("simParamsPathListLenError")
        
        simParamsDf = pd.read_csv(simParamsPathList[0], delim_whitespace=True)

        simParamsDict = {k: v[0] for k, v in simParamsDf.to_dict('list').items()}

        thisJobDict = {
            'scenarioName': scenarioName,
            'batchName': batchName,
            'jobName': jobName,
            'params': {
                'RNGSeed': masterDict['RNGSeed'],
                **simParamsDict,
            }
        }

        restartDict[str(simPath)] = thisJobDict
    
    return(restartDict)
    

def writeDictToJson(myDict, dictPath):

    dictJson = json.dumps(myDict, ensure_ascii=False, indent=4)
    with open(dictPath, 'w') as f:
        f.write(dictJson)

def readJsonToDict(dictPath) -> dict:
    with open(dictPath, 'r') as f:
        myDict = json.load(f)
    
    return myDict
