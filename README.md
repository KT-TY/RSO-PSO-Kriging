# RSO-PSO Kriging Code
This repository contains the code for the Kriging interpolation method based on the Particle Swarm Optimization (PSO) algorithm. It includes the main function, plotting functions, and various subfunctions. The code is designed to be executed in a MATLAB environment with parallel processing capabilities (requires configuration adjustments). Additional data calculations can be performed based on the gridRow.mat file
# Main
	pso_variogram_kriging_parallel.m

# Plot function
	Fig_variogram.m          # variogram fitting plot
	Fig_anisotropic.m        # four direction anisotropic plot
	Fig_deltaG.m             # interpolation results of gravity anomaly
	Fig_simulink_region.m    # gravity anomaly contours

# Subfunction
	pso_lost_function.m
	pso_lost_function_parallel.m
	pso_variogram_process.m
	sort_fourdirect.m
	variogram_dataset.m
	global_paramater_switch.m

# Initiate setting
	startup.m		# path, global vars and others paramater initiated

# Data
	gridRow.mat		# synthetic survey area data, include latitude, longitude and gravity
	drMap.mat		# distance and semivariogram based gridRow.mat
	variogram_fitting_250324.mat # RSO-PSO parameter based pso_variogram_kriging_parallel.m

# Contact
Email: <kt-ty@outlook.com>
