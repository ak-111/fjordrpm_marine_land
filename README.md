# FjordRPM: Marine- vs Land- Terminating Investigations

Using the model FjordRPM developed by D. Slater et al. (`https://github.com/fjord-mix/fjordrpm.git`), we simulate and compare fjords with marine- or land-terminating glaciers. 
We investigate parameter sensitivities, analyze stratification differences, identify behavioral regimes, and briefly compare coastal stratification differences. 



## code modifications
Changes to original FjordRPM simulation code
* `default_parameters`: we add a parameter `p.sm = 1 or 0` that switches submarine melting on or off
* `initialise_variables`, `get_final_output`: we initialize then calculate the following quantities during runtime and add to solution structure s
    * averaged fluxes and salinities $Q_{in}$, $Q_{out}$, $S_{in}$, $S_{out}$ as `s.Qin, s.Qout, s.Sin, s.Sout`
    * timescales $t_{adv}$, $t_{mix}$ as `s.t_adv, s.t_mix`

## code additions
Additional code falls into 4 categories: **experiments**, **sensitivity tests**, **analysis**, and **functions**. 
### experiments
We run 16 base experiments (marine/land) and (deep/shallow) and (sill/no sill) and (1x/3x freshwater). We also vary the shelf salinity profile between constant and linear, giving us 32 experiments total.
* `experiments.m` runs 16 experiments x2 shelf profile types (constant `c` or linear `ls`). saves runs to experiment_data
* folders:
    * `experiment_data` contains all 32 experiments (see `experiment_filenames.xlsx` for reference)
    * `experiment_sheets` contains all .xlsx files
    * `experiment_figures` contains all .fig files
#### export
* `write_experiments_sheet` and `write_coastal_sheet` create .xlsx spreadsheets for a set of runs
### sensitivity_tests
* `C0_K0_Kb_test.m` tests relative importance of $C_0$, $K_0$, $K_b$ on $S_{out}$, $Q_{in}$, $\Delta S$
* `N_H_C0_sensitivity.m` tests $Q_{in}$ scaling relationships
* `fw_scaling.m` tests  $Q_{in}$ scaling with freshwater input
### analysis
#### stratification
* `plot_stratification.m` plots density, stratification index as a function of depth, and potential energy anomaly $\Delta \phi$ for a single run 
* `compare_stratification.m` compares potential energy anomalies $\Delta \phi$ on one graph, for a given set of runs (currently one marine and land pair at a time)
#### regimes
* `regimes_experiments.m` visualizes Knudsen relationship between $Q_{in} / Q_{FW}$ and $(S_{out}-S_{in})/ S_{out}$ and plots 16 saved experiments for a given shelf type
* `regimes_H_fw.m` tests effects of depth or freshwater input on regimes
#### coastal 
* `coastal_profile.m` assumes a simple coastal box model with the same vertical resolution as a given run, and feeds in fjord outflowing flux for a specified time; coast eventually relaxes to fjord conditions
### functions
* `setup_fjordrpm.m` takes in a set of adjustable parameters `(type, fw, shelf, H, sill, N, dt, t_end, t_save_dt)`; returns structures ` p t f a ` to be fed into `run_model`
* `get_stratification` takes in two salt slices and calculates density, stratification index, and potential energy anomaly
* `find_outflow_layer` takes in a run and returns the layer of outflow

