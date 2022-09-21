import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special

#============ Comparison of 'Material Diffusion Experiment =====================
#==================(Beryllium absorption/desorption) ===========================

# Reference 1:
# R.G. Macaulay-Newcombe, D.A. Thompson, and W.W. Smeltzer, "Deuterium diffusion,
# trapping and release in ion-implanted beryllium," Fusion Engineering and Design
# 18 (1991) 419-424.

# Reference 2:
# GR Longhurst, SL Harms, ES Marwil, and BG Miller. Verification and validation of
# tmap4. Technical Report, EG and G Idaho, Inc., Idaho Falls, ID (United States), 1992.

fig = plt.figure(figsize=[6.5,3.9])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

exp_data = pd.read_csv("val-2b-expdata.csv")
ax.plot(exp_data['Temperature'],exp_data['Flux'], label=r"Experimental Data", c='black', marker='+', linestyle='none')

#tmap_sol = pd.read_csv("./gold/val-2b_out.csv")
#tmap_temp = tmap_sol['temp']
#tmap_flux = tmap_sol['scaled_outflux']
#ax.plot(tmap_temp,tmap_flux,label=r"TMAP8",c='black')

ax.set_xlabel(u'Temperature (\u00B0C)')
ax.set_ylabel(u"Desorbed D ($10^{15}$ atom/m$^2\cdot$s)")
ax.legend(loc="best")
ax.set_xlim(left=400)
ax.set_xlim(right=800)
ax.set_ylim(bottom=-10)
ax.set_ylim(top=70)
plt.grid(b=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('val-2b_comparison.png', bbox_inches='tight');
plt.close(fig)
