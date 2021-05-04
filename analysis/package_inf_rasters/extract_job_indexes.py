import pandas as pd

progressDfPath = '../../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/progress.csv'
endTime = 2050


progressDf = pd.read_csv(progressDfPath)

x = progressDf['dpcLastSimTime'] == progressDf['simEndTime']
