import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as sts

rv = sts.norm()


plt.ion()


x = np.linspace(-3,3,1000)
x1 = np.linspace(-15,15,1000)
x2 = np.linspace(-20,20,1000)
I = np.zeros(x.shape[0])



linear = -np.absolute(x1) + 15
quadratic = (-x2**2)/9 +15
def gaussian(x, mu, sig):
    return np.exp(-np.power(x - mu, 2.) / (2 * np.power(sig, 2.)))

normal = 15*gaussian(x1,0,6.7) 


fig = plt.figure(figsize=(5.5,6))
ax = fig.add_subplot(111)
ax.plot(x,linear, label = "Linear", lw = 2)
ax.plot(x,quadratic,label = "Quadrática",  lw = 2)
ax.plot(x,normal, label = "Normal", lw =2 )
ax.set_ylim((0,20))
ax.set_xlabel('Posição no Espaço Político',size = 15)
ax.set_ylabel("Utilidade", size = 15)
ax.legend()
plt.savefig("utilities.pdf",dpi = 300)





