# simulate CBB

system.time(sim <- simm(N=N
                        , lag=lag
                        , betasize0=betaSize
                        , effprop0=effprop
                        , Rshape0=Rshape, Rrate0=Rrate
                        , i0=i0
                        , repprop0=repprop
                        , ksshape0=ksshape , ksrate0=ksrate
                        , pDshape0=pDshape , pDrate0=pDrate
                        , kerPos0=kerPos
                        , repDshape0=repDshape , repDrate0=repDrate
                        , numobs=(numobs+forecast)
                        , seed=seed
                        , freq=TRUE
)
)

print(sim)
# rdsave(sim)
