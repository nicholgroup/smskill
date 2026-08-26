Takes in list of instchans and operation numbers, then calls each instruments control function with that channel and operation numbers. If the operation number isn't specified, 3 is called.  For unfortunate reasons of history, the instchan can be specified as the first or second argument; the operation number is the third argument. This will (typically) be the number corresponding to a software trigger of that instrument. 

This is typically set as a trigfn in a scan loop to either start a ramp or begin buffered readout at the beginning of a loop. For instance, using buffered readout with the LockIn, we have: 
```
scan.loops(1).trigfn

ans = 

      fn: @smatrigfn
    args: {[2 32]}
```