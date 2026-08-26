` data = smget(channels) `


Readout current value from _channels_.   _channels_ can be a single string, a cell array of strings, a channel number, or a vector of channel numbers.  Data is returned as a cell array, with length = number of channels. 

If each channels returns data as a scalar, an easy way to convert this into a doubles array is `cell2mat(smget({'1a' '2a' '3a}))`

If you have figure 999 set up to display current values of all channels, this will update it. 