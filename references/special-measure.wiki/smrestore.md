**smrestore**(_file_, _channels_, _ramprate_)
 
> Restores channel values to value during previous scan. All Special Measure scans save a list of configch and configvals with the data. The configvals are a list of values of channels at the time of the scan. The configch to save are specified by smdata.configch. 

If _channels_ is not provided, this restores all configch to their previous channel. 
`smrestore` is particularly useful if you are tuning a large set of parameters (e.g. voltages on a quantum dot) and after many scans end up not liking the result. It is good to have in mind a 'good' scan that you can restore to to try again. 