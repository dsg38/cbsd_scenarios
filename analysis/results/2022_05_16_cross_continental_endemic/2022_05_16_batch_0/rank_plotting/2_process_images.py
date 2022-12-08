import subprocess
import pandas as pd
from pathlib import Path

rankDf = pd.read_csv('./output/rankDf.csv')

posteriorPaths = sorted(list(Path('../plot_posterior/plots/').glob('*')))

for posteriorPath in posteriorPaths:

    smallPath = Path('./posterior_small') / posteriorPath.name

    print(smallPath)
    
    subprocess.call(['convert', posteriorPath, '-resize', '500x500', smallPath])

# Glue together map and small posterior
mapPaths = sorted(list(Path('./plots/').glob('*')))

for mapPath in mapPaths:

    smallPath = Path('./posterior_small') / mapPath.name

    mergedPath = Path('./merged_0') / mapPath.name

    print(mergedPath)

    subprocess.call(['convert', mapPath, smallPath, '-gravity', 'southwest', '-geometry', '+700+185', '-composite', mergedPath])

