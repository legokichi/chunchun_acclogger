# http://jsdo.it/duxca/tLfB/
import csv
from pylab import *

def getRows(reader):
    rows = []
    for row in reader:
        rows.append(row)
    return rows

dir = ""

timeStamps = []
alpha = []
beta = []
gamma = []
x = []
y = []
z = []
gx = []
gy = []
gz = []

for row in getRows(csv.reader(open(dir+"devicemotion.csv", 'rb')))[40:]:
    timeStamps.append(int(row[0]))
    alpha.append(float(row[1]))
    beta.append(float(row[2]))
    gamma.append(float(row[3]))
    x.append(float(row[4]))
    y.append(float(row[5]))
    z.append(float(row[6]))
    gx.append(float(row[7]))
    gy.append(float(row[8]))
    gz.append(float(row[9]))
norms = []
for i, _ in enumerate(x):
    norms.append(abs(x[i]) + abs(y[i]) + abs(z[i]))
times = map(lambda n:n-timeStamps[0], timeStamps)

widnowSize = 16
sampleRate = int(1000/(times[1]-times[0]))

subplot(6,1,1)
plot(times, alpha)
plot(times, beta)
plot(times, gamma)

subplot(6,1,2)
plot(times, gx)
plot(times, gy)
plot(times, gz)

subplot(6,1,3)
plot(times, x)
plot(times, y)
plot(times, z)

subplot(6,1,4)
plot(times, norms)

subplot(6,1,5)
specgram(norms, NFFT=widnowSize, Fs=sampleRate, noverlap=widnowSize-1)

show()
