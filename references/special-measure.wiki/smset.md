**smset**(_channels_,_vals_,_`[`ramprate`]`_)

Set _channels_ to _vals_.  _channels_ can be a single string, a cell array of strings, a channel number, or a vector of channel numbers.  _vals_ can correspondingly be a single value, a cell array of values, or a vector of values.  If _ramprate_ is not specified, the default from [smdata.channels] is used.

Normally **smset** does not terminate until the ramp is complete.  However, if the ramprate is negative, it will set up the ramp for self-ramping channels but not wait for it to finish.  (This feature is chiefly used by [smrun](smrun).
### Examples ###
```
  smset('1a',-.123);            % sets '1a' to -.123
  smset(1:5,[ 0 0 0 0 0]);      % sets channels 1:5 (in smdata.channels) all to 0
  smset({'1b','2b'},{-.2,-.2}); %sets '1b' and '2b' to -.2 each
  smset('1a',-.4, .01);         % sets '1a' to -.4 ramping at .01/second
```

For more advanced users: 

* If ramprate is given, smset checks that it is finite and within bounds of rangeramp.
* Make sure that new val is within bounds of the rangeramp, then multiply the vals and rate by rangeramp 4
* If either is not within bounds, it is set to closest value within rangeramp limits.
* If a ramprate is finite and type = 0, smset will step the channels value to the final value in 10 ms increments (change in value per step is calculated from the ramprate and difference between initial and final values. 
* If a ramprate is positive and type = 1, smset assumes that the driver has selframping capabilities, and calls the driver with the final value and the ramprate. smset waits the amount of time for the ramp to complete, then quits. Note that this means that you cannot use this mode with triggering.
* If a ramprate is negative and type = 1, smset assumes the driver has selframping capabilities, and calls the driver with the final value and  (still negative) ramprate, then quits (not waiting for the ramp to complete). This allows one to trigger the ramps separately. 
* If a ramprate is infinite, smset simply sets the channel to its final value. 
* The use of the negative ramprate to signify autoramping occasionally causes problems. Be especially aware that if you set a negative multiplier for the channel, smset will change a negative ramprate to a positive one and 
vice versa, and then call the driver with that ramprate.  

### See Also ###
  * [smget](smget)
  * [smprintchannels](smprintchannels)
  * [smprintrange](smprintrange)
  * [smdata](smdata) for a description of [smdata.channels].
