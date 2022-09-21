#cl=3.1622e18
cl=1.0

[Mesh]
  [./cmg]
    type = CartesianMeshGenerator
    dim = 1
    dx = '1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 
          1e-9 1e-8 1e-7 1e-6 1e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5'
    subdomain_id = '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1'
  [../]
  [./subdomain_id]
    input = cmg
    type = SubdomainBoundingBoxGenerator
    bottom_left = '18e-9  0 0'
    top_right = '1.99929e-4  0 0'  # sum of all dx's
    block_id = 1
  [../]
  [./interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = subdomain_id
    primary_block = '0'
    paired_block = '1'
    new_boundary = 'interface'
  [../]
[]

[Variables]
  [./C_BeO]
    block = 0
  [../]
  [./C_Be]
    block = 1
  [../]
  [./T_BeO]
    block = 0
  [../]
  [./T_Be]
    block = 1
  [../]
[]

[Kernels]
  [./diff_BeO]
    type = FunctionDiffusion
    variable = C_BeO
    function = diffusivity_BeO
    block = 0
  [../]
  [./time_BeO]
    type = TimeDerivative
    variable = C_BeO
    block = 0
  [../]
  [./diff_Be]
    type = FunctionDiffusion
    variable = C_Be
    function = diffusivity_Be
    block = 1
  [../]
  [./time_Be]
    type = TimeDerivative
    variable = C_Be
    block = 1
  [../]
  [./heat_BeO]
    type = HeatConduction
    variable = T_BeO
    diffusion_coefficient = thermal_conductivity_BeO
    block = 0
  [../]
  [./time_heat_BeO]
    type = SpecificHeatConductionTimeDerivative
    variable = T_BeO
    density = density_BeO
    specific_heat = specific_heat_BeO
    block = 0
  [../]
  [./heat_Be]
    type = HeatConduction
    variable = T_Be
    diffusion_coefficient = thermal_conductivity_Be
    block = 1
  [../]
  [./time_heat_Be]
    type = SpecificHeatConductionTimeDerivative
    variable = T_Be
    block = 1
  [../]
[]

[InterfaceKernels]
  [tied]
    type = PenaltyInterfaceDiffusion
    variable = C_BeO
    neighbor_var = C_Be
    jump_prop_name = "solubility_ratio"
    penalty = 1e6
    boundary = 'interface'
  []
[]
  
[BCs]
  [C_left]
    type = EquilibriumBC
    K = ${solubility_BeO}
    boundary = left
    enclosure_scalar_var = enclosure_pressure
    temp = ${T_BeO}
    variable = C_BeO
    p = 0.5
  []
  [C_right]
    type = NeumannBC
    variable = C_Be
    value = 0
    boundary = right
  []
  [T_left]
    type = FunctionDirichletBC
    variable = T_BeO
    boundary = left
    function = temperature_history
  []
  [T_right]
    type = NeumannBC
    variable = T_Be
    value = 0
    boundary = right
  []
[]

[Functions]
  [enclosure_pressure]
    type = ParsedFunction
  value = 'if(t<180015.0, 13300.000001, if(t<182400.0, 1e-6, 0.001))' #=========================
  []
  [temperature_history]
    type = ParsedFunction
    value = 'if(t<180000.0, 773.0, if(t<182400.0, 773.0-((1-exp(-(t-180000)/2700))*475), 300+0.05*(t-182400)))' #=========================
  []
[]

[Materials]
  [./BeO_d]
    type = ParsedMaterial
    f_name = 'diffusivity_BeO'
    args = 'T_BeO'
    function = 'if(t<182400, 1.40e-4*exp(-24408/T_BeO), 7e-5*exp(-24408/T_BeO))'
  [../]
  [./BeO_s]
    type = ParsedMaterial
    f_name = 'solubility_BeO'
    args = 'T_BeO'
    function = '5.00e20*exp(9377.7/T_BeO)'
  [../]
  [./BeO_HT]
    type = GenericConstantMaterial
    prop_names = 'density_BeO  thermal_conductivity_BeO specific_heat_BeO'
    prop_values = '3010.0  159.2  996.67774'
  [../]
  [./Be_d]
    type = ParsedMaterial
    f_name = 'diffusivity_Be'
    args = 'T_Be'
    function = '8.0e-9*exp(-4220/T_Be)'
  [../]
  [./Be_s]
    type = ParsedMaterial
    f_name = 'solubility_Be'
    args = 'T_Be'
    function = '7.156e27*exp(-11606/T_Be)'
  [../]
  [./Be_HT]
    type = GenericConstantMaterial
    prop_names = 'density_Be  thermal_conductivity_Be specific_heat_Be'
    prop_values = '1850  168.0  1821.62162'
  [../]
  [./interface_jump]
      type = SolubilityRatioMaterial
      mat_prop_primary =   solubility_BeO
      mat_prop_secondary = solubility_Be
      boundary = interface
      concentration_primary = C_BeO
      concentration_secondary = C_Be
  [../]
[]
  
[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'left'
    diffusivity = diffusivity_BeO
    variable = C_BeO
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = ${cl}
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  end_time = 197860
  dt = 60.0
  dtmin = .01
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
  verbose = true
  compute_scaling_once = false
[]

[Outputs]
  csv = true
  [out]
    type = Exodus
    execute_on = 'initial timestep_end'
  []
  [dof]
    type = DOFMap
    execute_on = initial
  []
  perf_graph = true
[]
