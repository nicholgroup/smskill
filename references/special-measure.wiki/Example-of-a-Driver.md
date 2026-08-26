**A heavily annotated example of a driver (for an Agilent DMM)**

      function val = smcdmm(ico, val, rate)

All files starting with smc are drivers.

Communications with an instrument occurs through calls of **smdata.inst().cntrlfn** which has the
convention: **val = cntrlfn([inst, channel, operation], val, rate)**. Here, the control function is **smcdmm**.
 
**i** is instrument number

**c** is instrument channel

**o** is read or write where 0 is read and 1 is write.

     global smdata;

**smdata** gives you how many channels there are and what they do for each instrument. These are preprogrammed in.

(for the dmm) channel 1 = **val**, channel 2 = **data** (buffered readout)

      switch ico(2)  % channel
           case 1 %VAL
               switch ico(3) %operation
           case 0 % get (read channel value) 
                val = query(smdata.inst(ico(1)).data.inst,  'READ?', '%s\n', '%f');
                %smdata.inst(3).data.inst is the instrument to talk to.
                %VISA object. 
           otherwise
                error('Operation not supported');
        end
        
           case 2 %DATA. If you want buffered readout 
               switch ico(3)
           case 0 %get (read channel value) 
                  % this blocks until all values are available 
                val = sscanf(query(smdata.inst(ico(1)).data.inst,  'FETCH?'), '%f,')';
           case 3 %trigger
                trigger(smdata.inst(ico(1)).data.inst);
           otherwise
                error('Operation not supported');
           end
     end
 
_Extra notes for the extra challenged_:

In order to figure out what the two channels are:
In smdata, if the dmm is listed as channel 5 (See GUI) then
you can type smdata.channels(5) which gives you the instrument number (3)
Then you cantype smdata.inst(3) to get the instrument. Then you can type
smdata.inst(3).channels to get the two channels VAL and DATA. VAL
corresponds to case 1 and DATA corresponds to case 2.
Figure out what VAL and DATA are using the dmm manual. 
 
 
