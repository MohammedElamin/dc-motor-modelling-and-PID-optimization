% Genetic Algorithm to tune PID Parameters
% Initialization

no_var = 4;
lb = [0 0 0 0];
ub = [200 200 200 100000];

% GA Options
ga_opt = gaoptimset('Display','off','Generations',25,'PopulationSize',50);

% Custom plot function for plotting convergence curve
ga_opt.PlotFcns = {@gaplotbestf};

obj_fn = @(k) optimization_PID(k);

% GA Command
[k, best] = ga(obj_fn, no_var, [], [], [], [], lb, ub, [], ga_opt);

function cost = optimization_PID(k)
    assignin('base','k',k);
    sim("GA_DCmotor_with_PID.slx");
    cost = ITAE(end);
end