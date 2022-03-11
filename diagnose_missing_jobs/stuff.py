from pathlib import Path

stuff = Path('./find.txt').read_text().splitlines()

jobList = set([Path(x).parts[0] for x in stuff])

fullList = set(['job' + str(i) for i in range(100)])

x = fullList.difference(jobList)
