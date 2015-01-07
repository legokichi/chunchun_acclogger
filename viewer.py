# http://jsdo.it/duxca/tLfB/
import csv
from pylab import *

def getRows(reader):
    rows = []
    for row in reader:
        rows.append(row)
    return rows

dir = "./sitting/"

rows2 = getRows(csv.reader(open(dir+"deviceorientation.csv", 'rb')))[20:]
timeStamps2 = []
alpha = []
beta = []
gamma = []
for row in rows2:
    timeStamps2.append(int(row[0]))
    alpha.append(float(row[1]))
    beta.append(float(row[2]))
    gamma.append(float(row[3]))
norms2 = []
for i, _ in enumerate(alpha):
    norms2.append(abs(alpha[i]) + abs(beta[i]) + abs(gamma[i]))
times2 = map(lambda n:n-timeStamps2[0], timeStamps2)

rows = getRows(csv.reader(open(dir+"devicemotion.csv", 'rb')))[20:]
timeStamps = []
x = []
y = []
z = []
for row in rows:
    timeStamps.append(int(row[0]))
    x.append(float(row[1]))
    y.append(float(row[2]))
    z.append(float(row[3]))
norms = []
for i, _ in enumerate(x):
    norms.append(abs(x[i]) + abs(y[i]) + abs(z[i]))
times = map(lambda n:n-timeStamps[0], timeStamps)



widnowSize = 16
sampleRate = int(1000/(times[1]-times[0]))

subplot(6,1,1)
plot(times2, alpha)
plot(times2, beta)
plot(times2, gamma)

subplot(6,1,2)
plot(times2, norms2)

subplot(6,1,3)
specgram(norms2, NFFT=widnowSize, Fs=sampleRate, noverlap=widnowSize-1)

subplot(6,1,4)
plot(times, x)
plot(times, y)
plot(times, z)

subplot(6,1,5)
plot(times, norms)

subplot(6,1,6)
specgram(norms, NFFT=widnowSize, Fs=sampleRate, noverlap=widnowSize-1)

show()
