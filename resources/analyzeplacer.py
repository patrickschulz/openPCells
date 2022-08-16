import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

FILENAME = 'output_asdf.csv'
csvdata = pd.read_csv(FILENAME)

temp = csvdata['temperature'].astype('float64')
iteration = csvdata['iteration'].astype('int')
length = csvdata['oldlen'].astype('int')

plt.scatter(temp, length)

z = np.polyfit(temp, length, 10)
p = np.poly1d(z)

plt.plot(temp, p(temp), "r--")
plt.xscale("log")
plt.show()

