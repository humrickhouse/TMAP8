scale=1.0

[Mesh]
  [./cmg]
    type = CartesianMeshGenerator
    dim = 1
    dx = '0.5  0.5'  # 0.5m each slab (1m total)
    ix = '10  10'  # 10 elements each slab (20 elements total)
    subdomain_id = '0  1'
  [../]
  [./subdomain_id]
    input = cmg
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0.5  0 0'
    top_right = '1.0  0 0'  # sum of all dx's
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
[]

[AuxVariables]
  [./enclosure_pressure]
    family = SCALAR
    initial_condition = 1.0
  [../]
[]  
  
[Kernels]
  [./diff_BeO]
    type = ADMatDiffusion
    variable = C_BeO
    diffusivity = diffusivity_BeO
    block = 0
  [../]
  [./diff_Be]
    type = ADMatDiffusion
    variable = C_Be
    diffusivity = diffusivity_Be
    block = 1
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

[BCs]
  [C_left]
    type = DirichletBC
    variable = C_BeO
    value = 1.0
    boundary = left
  []
  [C_right]
#    type = NeumannBC
    type = DirichletBC
    variable = C_Be
    value = 0.0
    boundary = right
  []
[]

[Materials]
  [./BeO_d]
    type = ADParsedMaterial
    f_name = diffusivity_BeO
    function = 1.0
    block = 0
  [../]
  [./BeO_s]
    type = ADParsedMaterial
    f_name = 'solubility_BeO'
    function = 1.0
    block = 0
  [../]
  [./Be_d]
    type = ADParsedMaterial
    f_name = 'diffusivity_Be'
    #args = T_Be
    #function = '8.0e-9*exp(-4220/T_Be)'
    function = 1.0
    block = 1
  [../]
  [./Be_s]
    type = ADParsedMaterial
    f_name = 'solubility_Be'
    #args = T_Be
    #function = '7.156e27*exp(-11606/T_Be)/${scale}'
    function = 2.0
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
  [./AD_converter_BeO]
    type = MaterialADConverter
    ad_props_in = diffusivity_BeO
    reg_props_out = diffusivity_BeO_noAD
    block = 0
  [../]
  [./AD_converter_Be]
    type = MaterialADConverter
    ad_props_in = diffusivity_Be
    reg_props_out = diffusivity_Be_noAD
    block = 1
  [../]
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'left'
    diffusivity = diffusivity_BeO_noAD
    variable = C_BeO
#    block = 0
  []
#  [outflux2]
#    type = SideDiffusiveFluxAverage
#    boundary = 'right'
#    diffusivity = diffusivity_BeO_noAD
#    variable = C_BeO
#    block = 0
#  []
#  [outflux3]
#    type = SideDiffusiveFluxAverage
#    boundary = 'left'
#    diffusivity = diffusivity_Be_noAD
#    variable = C_Be
#    block = 1
#  []
  [outflux4]
    type = SideDiffusiveFluxAverage
    boundary = 'right'
    diffusivity = diffusivity_Be_noAD
    variable = C_Be
#    block = 1
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = ${scale}
  []
  #[time]
  #  type = TimePostprocessor
  #[]
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  #type = Transient
  type = Steady
  #end_time = 197860
  #dt = 1.8
  #dtmin = .01
  solve_type = PJFNK
  #petsc_options = '-pc_svd_monitor -ksp_view_pmat'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'svd boomeramg'
  automatic_scaling = true
  off_diagonals_in_auto_scaling = true
  verbose = true
  compute_scaling_once = false
  #abort_on_solve_fail = true
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

[VectorPostprocessors]
  [./soln0]
    type = LineValueSampler
    start_point = '0  0  0'
    end_point = '0.5  0  0'
    variable = C_BeO
    num_points = 10
    sort_by = id
    execute_on = timestep_end
  [../]
  [./soln1]
    type = LineValueSampler
    start_point = '0.500001  0  0'
    end_point = '1.0  0  0'
    variable = C_Be
    num_points = 10
    sort_by = id
    execute_on = timestep_end
  [../]
[]
  
