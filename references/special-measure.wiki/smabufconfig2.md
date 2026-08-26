This configures instruments for buffered readout and sets up a trigger. It takes in the arguments below: 
`smabufconfig2(scan, cntrl, getrng, setrng, loop)`
 
* cntrl: 'fast', 'arm', 'trig', 'end'
* getrng: The index of the _getchan(s)_ in _loop_ -- so if you want only the second getchan, _getrng_ = 2. 
* setrng: If the ctrl is 'fast', this gives arguments for the readout driver that will configure readout. Typically _npoints_ and _rate_. If not, this gives indices of _setchans_ in the first loop to trigger. 
* loop: Loop containing the _getchan_ whose readout we are configuring. This is can only be used for fastmode, otherwise loop is set to 2. 

* If this uses the 'fast' `cntrl`, the buffered readout _getchan_ is in the first loop, and data comes from, e.g. many pulses running for each point in the first loop. Otherwise, the _getchan_ is in the 2nd (or greater) loop, and comes from SM sweeping through a line of data. In each case, `smabufconfig2` may reconfigure the number of points and _ramptime_ in the scan so that the rate is a multiple of the sampling rate of the readout instrument, and the _setrng(s)_ fulfill all other weird instrumental requirements.  
* If not using 'fast', _loop_ is set to 2. Loop through the _getchans_, calling their driver with operation 5 and the arguments scan.loops(1).npoints, 1/abs(scan.loops(1).ramptime). The ramptime and npoints of the first loop are reassigned based on what control function returns.  
* If 'trig' is a _cntrl_, sets the trigfn of loop 1 to be `smatrigfn`, and arguments set to trigger all getchans in 2nd loop and setchans in first loop (unless getrng / setrng specify certain chans). 
* The lock-in buffered readout with the lockin as the only getchan is set up using a configfn of the scan and arguments 'trig'. This calls the driver with option 5 to configure the scan, then sets `smatrigfn` as a _trigfn_ in the 1st loop with the arguments of the Lock-In IC and the ICs of the setchans in the first loop. 

## Pulsed Scans  
* When `smabufconfig2` is used with the DAQ for pulsing, the arguments used are: _cntrl_: 'fast arm', _getrng_: 1, and _setrng_: [npulse 1/pulselength]. 
* If 'fast' is used and there's no _loop_ given, sets _loop_ to 1.
* Sets _getic_ to be all the _getchans_ in _loop_ of the passed scan. In this case, these are DAQ channels and Time.
 * Since _getrng_ is passed and is 1, the getchan is now set to be the first of the getchans, i.e. the DAQ channel. 
* Because 'fast' is a _ctrl_, loops through the getchans, in this case just the first DAQ fn, and calls it with option 5 and [npulse 1/pulselength], which will configure the DAQ. 
* If 'arm' is a _ctrl_, sets the first scan _prefn_ to call the `smatrigfn` with operation 4. In the scan, smatrigfn will then call the DAQ driver to arm it. 
* A charge scan would have options ('arm', 1, [scan.loops(1).npoints 1/scan.loops(1).ramptime]). Thus in this case, the buffered readout occurs in the second loop. Here, _npoints_ and _ramptime_ will be redefined if need be. 
  
* Example with Pulses:  
 
  The DAQ is configured in `smabufconfig2` with a 'rate' of the inverse pulse length, and with _npoints_ = _nloop_ * _npulse_. _downsamp_ gives the number of points collected by the DAQ in one pulse. For instance, with _samprate_ = 50 MHz and pulse length = 4 us, _downsamp_=200 = length(mask), which is true for something like 172:193. For _nloop_ = 100 and _npulse_ = 75, npts = 100 * 75 * 200 = 1,500,000, which will take up 2 buffers. 
    
   As the data is gathered, it is reshaped to have size _downsamp_ x _nsamp_, where _nsamp_ is the number of samples per record (see description of DAQ driver above for more information). Points with indices (172:193,:) are gathered and averaged, so that we end up with 100 * 75 = 7500 points. 
