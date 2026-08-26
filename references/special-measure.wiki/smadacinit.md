**smadacinit**(_inst_,_opts_) 

This should be run whenever a DAC is restarted or hooked up to the computer. 
Running it without any arguments will find all DecaDACs on the rack, perform an 
smadachandshake, reset the update times, and set the mode to use 4 channels / slot (see the ASCII doc for more info). You can also give it inst numbers (as a column) of the DACs you want to initialize. The opt 'zero' 
will set all the channels to 0.  

DAQs often arrive in lab in a mode that has all relays off -- i.e. the DAQ will respond to all commands as normal but not set any voltages. This changes the mode (to 4 channels / slot), so if this doesn't run correctly, you may not be outputting voltages. 