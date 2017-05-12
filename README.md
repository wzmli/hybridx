# hybridx


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


