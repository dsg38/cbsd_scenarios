import subprocess
import pandas as pd
from pathlib import Path

rankDf = pd.read_csv('./output/rankDf.csv')

posteriorPaths = sorted(list(Path('./plots_bool').glob('*')))

for posteriorPath in posteriorPaths:

    smallPath = Path('./plots_bool_small') / posteriorPath.name

    print(smallPath)
    
    subprocess.call(['convert', posteriorPath, '-resize', '500x500', smallPath])

# Glue together map and small posterior
mapPaths = sorted(list(Path('./merged_0/').glob('*')))

for mapPath in mapPaths:

    smallPath = Path('./plots_bool_small') / mapPath.name

    mergedPath = Path('./merged_1') / mapPath.name

    print(mergedPath)

    subprocess.call(['convert', mapPath, smallPath, '-gravity', 'southwest', '-geometry', '+700+750', '-composite', mergedPath])

