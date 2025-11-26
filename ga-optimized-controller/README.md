This folder contains the implementation of the GA-based PID tuning used in the project.

Included:
-Simulink model comparing GA-tuned PID response with the MATLAB auto-tuned PID.
-MATLAB Script used to configure the GA parameters(population size, bounds, generations).
-Objective function used to minimize the Integral Time Weighted Absolute Error (ITAE).

The controller performance metrices (rise time, settling time, overshoot, steady-state error, and ITAE) were derived from the output of this model.
