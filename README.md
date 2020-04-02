# Discrete-time Stochastic Epi-model template generator 

All the code in this repo are mainly for our [simulation study](https://journals.sagepub.com/doi/full/10.1177/0962280217747054).

## Package versions
rstan 2.19.2
stan_version 2.19.1

nimble 0.9.0

R2jags 0.5.7
JAGS 4.2.0

## Other uses
Treat this as a template builder to build the BUGS and STAN scripts for the models in the paper. 
In source.R, run the fitmod function by specifying the type of model you would like to run. Please see name.R to see how to correctly specify the type of model. 
It will generate the appropriate BUGS/STAN script in the template subfolder in jags_dir, nimble_dir, stan_dir.


## New pipeline

### Jags: 

#### Initialize model
- reads in BUGS script 
- constructs the model object
- Adapt 1000 iterations 

#### Sampling phase
- Takes the adaptive model object and run (n.burnin + n.iterations)
- Keeps the last n.iterations 
- Check convergence via Rhat < 1.1 (ESS > 40 optional, currently NA)

- If covergence test fails, sample another n.iterations from the previous chains and repeat last two steps.


### Nimble and Stan

#### Initialize model
- reads in BUGS script 
- construct model object

#### Sampling phase
- start with 2000 iterations
- Takes the model object and run n.iterations (half burnin)
- If convergence test fails, redo previous step with double the amount of iterations.


