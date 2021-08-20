import subprocess
from pathlib import Path
import pandas as pd

plotSubsetDf = pd.read_csv("./outputs/2021_03_26_cross_continental/plots/plot_subset.csv")

scenario = '2021_03_26_cross_continental'
batch = '2021_03_29_batch_0'
job = 'job133'
detection_year = 1

num_positive_surveys_column_list = [
    "num_positive_surveys_0_00",
    "num_positive_surveys_0_15",
    "num_positive_surveys_0_30"
]

# ----------------------------------------------

def genMontage(
    scenario,
    batch,
    job,
    detection_year,
    num_positive_surveys_column
):

    detection_year_str = 'detection_year_' + str(detection_year)

    topDir = Path('./outputs') / scenario / 'plots'

    topDirNumPosCol = topDir / num_positive_surveys_column

    infRasterDir = topDir / 'inf_rasters_agg'
    infPropDir = topDir / 'inf_prop'
    surveyDir = topDirNumPosCol / 'surveys'

    infRasterPlotPaths = infRasterDir.glob(batch + '-' + job + '*')

    for infRasterPlotPath in infRasterPlotPaths:

        plotName = infRasterPlotPath.name

        print(plotName)

        outPath = Path('./outputs/2021_03_26_cross_continental/plots/') / num_positive_surveys_column / 'montage' / detection_year_str / plotName

        outPath.parent.mkdir(parents=True, exist_ok=True)

        cmd = [
            'montage',
            surveyDir / plotName,
            './outputs/2021_03_26_cross_continental/plots/host/host.png',
            infRasterPlotPath,
            infPropDir / plotName,
            '-resize',
            'x1000',
            '-density',
            '600',
            '-tile',
            '2x2',
            '-geometry',
            '+5+5',
            '-border',
            '10',
            outPath
        ]

        print(cmd)
        subprocess.call(cmd)


for i, row in plotSubsetDf.iterrows():

    print(i)

    for num_positive_surveys_column in num_positive_surveys_column_list:

        # print(num_positive_surveys_column)

        genMontage(
            scenario=scenario,
            batch=row['batch'],
            job=row['job'],
            detection_year=row['detection_year'],
            num_positive_surveys_column=num_positive_surveys_column
        )
