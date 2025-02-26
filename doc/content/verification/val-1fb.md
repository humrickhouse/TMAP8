# val-1fb

# Thermal Transient in a Slab

This verification problem is taken from [!cite](ambrosek2008verification). In this problem thermal transient in a slab is modeled. The ends of a slab are kept fixed at different temperatures. The temperature distribution in the slab evolves from an initial state to steady-state. The analytical solution for this case is given as:

\begin{equation}
T(x,t) = T_o \;+\; (T_1-T_o)\Bigg\{1-\frac{x}{L}-\frac{2}{L}\sum_{m=1}^{\infty} \left(\frac{1}{\lambda_m}  \sin(\lambda_m x) \exp(-\alpha \lambda_m^2 t)  \right)\Bigg\}
\end{equation}

where:

    
    $T$ : temperature in the slab (K)

    
    $x$ : distance across the slab (m)

    $t$ : time (seconds)

    $T_o$ : fixed temperature at one end of the slab (400 K)

    $T_1$ : fixed temperature at the other end of the slab (300 K)

    $L$ : length of the slab (4.0 m)

    $\lambda_m$ : $\frac{m\pi}{L}$

    $\alpha$ : thermal diffusivity (1.0 m$^2$/s) where 

\begin{equation}
\alpha = \frac{k}{\rho C_p}
\end{equation}

$k$ is the thermal conductivity, $\rho$ is the density and $C_p$ is the specific heat capacity of the slab material.

# 


Comparison of the temperature distribution in the slab, computed through TMAP8 and calculated analytically, is shown in [val-1fb_comparison_temperature]. The TMAP8 code predictions match very well with the analytical solution.

!media figures/val-1fb_comparison_temperature.png
    style=width:60%;margin-bottom:2%
    id=val-1fb_comparison_temperature
    caption=Comparison of temperature distribution in the slab calculated
     through TMAP8 and analytically

!bibtex bibliography
