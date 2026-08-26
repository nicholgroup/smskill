**smprintchannels**(_ch_)
> Print the number, name, device, device name, and device's channel name for a list of channels. ch can be a vector of channel numbers, a channel name, or a cell array of channel names. If ch is omitted, all channels are printed.

```
smprintchannels
CH   Name        Device      Dev. Name   Dev. Ch. 
------------------------------------------------------------
1   1a          DecaDAC     DAC1        RAMP3    
2   2a          DecaDAC     DAC1        RAMP4    
3   3a          DecaDAC     DAC1        RAMP2    
4   4a          DecaDAC     DAC1        RAMP9    
5   B           AMI430      AMI430      B        
6   Lockin      SR830       LockinLower  X        
7   LockSens    SR830       LockinLower  SENS     
8   LockFreq    SR830       LockinLower  FREQ     
9   DMM         HP34401A    DMM         VAL      
10  DMMbuf      HP34401A    DMM         DATA     
11   PulseClock  AWG5000     AWG1        CLOCK    
12   Time        Aux                     Time     
13   count       test                    CH1      
14   RFfreq1     LabBrick                FRQ      
15   RFpow1      LabBrick                POW      
```