scale=1.0e24

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
    initial_condition = 0
  [../]
  [./C_Be]
    block = 1
    initial_condition = 0
  [../]
  [./T_BeO]
    block = 0
    initial_condition = 300
  [../]
  [./T_Be]
    block = 1
    initial_condition = 300
  [../]
[]

[AuxVariables]
  [./enclosure_pressure]
    family = SCALAR
    initial_condition = 13300.000001
  [../]
[]  
  
[Kernels]
  [./diff_BeO]
    type = ADMatDiffusion
    variable = C_BeO
    diffusivity = diffusivity_BeO
    block = 0
  [../]
  [./time_BeO]
    type = TimeDerivative
    variable = C_BeO
    block = 0
  [../]
  [./diff_Be]
    type = ADMatDiffusion
    variable = C_Be
    diffusivity = diffusivity_Be
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
    specific_heat = specific_heat_Be
    density = density_Be
  [../]
[]

[InterfaceKernels]
  [tied]
    type = ADPenaltyInterfaceDiffusion
    variable = C_BeO
    neighbor_var = C_Be
    jump_prop_name = "solubility_ratio"
    penalty = 1e6
    boundary = 'interface'
  []
[]

[AuxScalarKernels]
  [./enclosure_pressure_aux]
    type = FunctionScalarAux
    variable = enclosure_pressure
    function = enclosure_pressure_func
  [../]
[]

[BCs]
  [C_left]
    type = EquilibriumBC
    K = solubility_BeO
    boundary = left
    enclosure_scalar_var = enclosure_pressure
    #enclosure_scalar_var = 13300.0
    temp = T_BeO
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
  [enclosure_pressure_func]
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
    type = ADParsedMaterial
    f_name = diffusivity_BeO
# need to figure out how to enable fn of time:
    function = 'if(time<182400, 1.40e-4*exp(-24408/T_BeO), 7e-5*exp(-24408/T_BeO))'
    #args = 'time  T_BeO'
    #function = '1.40e-4*exp(-24408/T_BeO)'
    args = T_BeO
    postprocessor_names = time
    block = 0
  [../]
  [./BeO_s]
    type = ADParsedMaterial
    f_name = 'solubility_BeO'
    args = T_BeO
    function = '5.00e20*exp(9377.7/T_BeO)/${scale}'
    block = 0
  [../]
  [./BeO_HT]
    type = GenericConstantMaterial
    prop_names = 'density_BeO  thermal_conductivity_BeO specific_heat_BeO'
    prop_values = '3010.0  159.2  996.67774'
    block = 0
  [../]
  [./Be_d]
    type = ADParsedMaterial
    f_name = 'diffusivity_Be'
    args = T_Be
    function = '8.0e-9*exp(-4220/T_Be)'
    block = 1
  [../]
  [./Be_s]
    type = ADParsedMaterial
    f_name = 'solubility_Be'
    args = T_Be
    function = '7.156e27*exp(-11606/T_Be)/${scale}'
    block = 1
  [../]
  [./Be_HT]
    type = GenericConstantMaterial
    prop_names = 'density_Be  thermal_conductivity_Be specific_heat_Be'
    prop_values = '1850  168.0  1821.62162'
    block = 1
  [../]
  [./interface_jump]
      type = SolubilityRatioMaterial
      solubility_primary =   solubility_BeO
      solubility_secondary = solubility_Be
      boundary = interface
      concentration_primary = C_BeO
      concentration_secondary = C_Be
  [../]
  [./AD_converter]
    type = MaterialADConverter
    ad_props_in = diffusivity_BeO
    reg_props_out = diffusivity_BeO_noAD
    block = 0
  [../]
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'left'
    diffusivity = diffusivity_BeO_noAD
    variable = C_BeO
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = ${scale}
  []
  [time]
    type = TimePostprocessor
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
  dt = 1.8
  dtmin = .01
  solve_type = PJFNK
  #petsc_options = '-pc_svd_monitor -ksp_view_pmat'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'svd boomeramg'
  automatic_scaling = true
  off_diagonals_in_auto_scaling = true
  verbose = true
  compute_scaling_once = false
  abort_on_solve_fail = true
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
