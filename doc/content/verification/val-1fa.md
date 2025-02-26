# val-1fa

# Heat Conduction with Heat Generation

This heat transfer verification problem is taken from [!cite](longhurst1992verification). In this problem heat conduction through a slab is modeled. The slab has heat generation. One end of the slab is kept at a constant temperature of 300K while the other end acts as an adiabatic surface. The analytical solution for this case is given as:

\begin{equation}
T = T_s \;+\; \frac{QL^2}{2k} \left(1-\frac{x^2}{L^2}\right)
\end{equation}

where:

    $Q$ : internal heat generation rate (10,000 W/m$^3$)

    $L$ : length of the slab (1.6 m)

    $k$ : thermal conductivity (10 W/m-K)

    $T_s$ : imposed surface temperature (300 K)


The slab is assumed to have a density of 1 kg/m$^3$ and a specific heat capabity of 1 J/kg-K.

Comparison of the temperature computed through TMAP8 and calculated analytically is shown in
[val-1fa_comparison_temperature]. The TMAP8 code predictions match very well with
the analytical solution.

!media figures/val-1fa_comparison_temperature.png
    style=width:60%;margin-bottom:2%
    id=val-1fa_comparison_temperature
    caption=Comparison of temperature along the slab calculated
     through TMAP8 and analytically

!bibtex bibliography
