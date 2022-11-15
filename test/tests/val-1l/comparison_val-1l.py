import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special

#============ Verification of SolubilityRatioMaterial.C ========================
#=========== (concentration discontinuity at interfaces) =======================

# Reference 1:
# Analytical solution by P. W. Humrickhouse

x1 = np.linspace(0,0.5,100)
x2 = np.linspace(0.5,1.0,100)

kA = 1
kB = 2

DA = 1
DB = 1

xA = 0.5
xB = 0.5

c0 = 1.0
J = c0/(xA/DA + ((kA/kB)*(xB/DB)))
c1 = c0/(1 + ((xA/xB)*(DB/DA)*(kB/kA)))
c2 = c0/((kA/kB) + ((xA/xB)*(DB/DA)))

cA = 2*(c1 - c0)*x1 + c0
cB = 2*c2*(1-x2)

         
fig = plt.figure(figsize=[6.5,3.9])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

tmap_sol1 = pd.read_csv("./gold/val-1l_out_soln0_0001.csv")
tmap_x1 = tmap_sol1['x']
tmap_c1 = tmap_sol1['C_BeO']
ax.plot(tmap_x1,tmap_c1,label=r"TMAP8",c='tab:gray')

tmap_sol2 = pd.read_csv("./gold/val-1l_out_soln1_0001.csv")
tmap_x2 = tmap_sol2['x']
tmap_c2 = tmap_sol2['C_Be']
ax.plot(tmap_x2,tmap_c2,c='tab:gray')

ax.plot(x1,cA,label=r"Analytical Solution", c='black', linestyle='--')
ax.plot(x2,cB, c='black', linestyle='--')


ax.set_xlabel(u'x')
ax.set_ylabel(u"C")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=1)
ax.set_ylim(bottom=0)
ax.set_ylim(top=1.0)
plt.grid(b=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('val-1l_comparison.png', bbox_inches='tight');
plt.close(fig)
