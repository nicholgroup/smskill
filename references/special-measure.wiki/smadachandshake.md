This takes in a column of insts or looks for all DecaDACs on the rack (through 
device name). It then queries the DAC to find its handshake, and compares it 
with the one stored in inst.data. It sends an error if they don't match. 
This is important if you have more than one DAQ on your rack -- occasionally a computer will reassign COM port numbers, and may change the COM port of one DAQ to that of the other. This mixes up channels between DACs with potentially catastrophic results. 