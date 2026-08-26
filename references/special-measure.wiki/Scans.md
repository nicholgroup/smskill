# Introduction #
A scan is a struct with all the information to acquire data. It is executed by smrun.  There are many fields in this struct (some of which may be left blank), and understanding each one will help you understand how smrun works.

Here is what matlab outputs when you type smscan:
```
 loops: [1x2 struct]
 saveloop: 2
 configfn: [1x1 struct]
 disp: [1x2 struct]
 cleanupfn: []
 consts: [1x2 struct]
```

Here we will go through all of these fields and some additional ones too.
* [Loops](#loops)
* [In Loop Functions](#trigfn)       
* [disp](#disp)
* [consts](#consts)
* [Configfn/Cleanupfn](#configfn)
* [How to specify in-scan functions](#fcns)
* [data](#data)
* [Halting scan](#halt)

<a name="loops"></a>
# Loops #
scan.loops is the meat of the scan. The loops contain all of the information about which channels should be swept or ramped, which channels should be recorded, etc. The size of scan.loops dictates the dimension of the scan to be performed: a 1-D (line scan) will have one loop, a 2-D scan will have two loops, etc. In general, each iteration of a loop might sweep a channel and get another channel. scan.loop(1) is the inner-most loop (executed most often) and scan.loops(end) is the outer-most loop (executed least often). Let's take a look at what is inside each loop.

## setchan ##
These are the channels to be swept in this loop. The setchan can either be a string (one channel) or a cell array of strings if more than one channel is to be swept. Alternatively, setchans can also be numbers, which are indices of smdata.channels.

## rng ##
The range over which the setchan should be swept. In each iteration of the loop the setchan starts at rng(1) and ends at rng(2). Alteratively, rng may be a vector of values to which the setchans are set. For example, scan.loops(l).rng = linspace(0,1,11).

## npoints ##
The number of points in the ramp. Over the course of the loop the setchan will be set to linspace(rng(1),rng(2),npoints). If length(rng) is great than 2, this field is ignored.

<a name="getchan"></a>
## getchan ##
This is the channel whose value is recorded at every point during the loop. Like the setchan, the getchan can be a string or a cell array of strings. The getchan can also be empty, if no data is taken in this loop (for example, the instrument in question can store many values and return them all at once -- buffered acquisition. In this case, the inner loop of a scan would have an empty getchan, and the outer loop would have a getchan that would return its values for an entire iteration of the inner loop.)

<a name="ramptime"></a>
## ramptime ##
The time (in seconds) to spend per point of each loop. If a loop has npoints=100 and a ramptime = .01 then one iteration of this loop will take one second. A negative ramptime is used to note that an instrument is capable of generating a ramp by itself (i.e. special measure does not need to set the setchans to each point). An empty ramptime (often used in outer loops of scans) signifies that the setchan is simply set (at a rate given by smdata.channels(ch).rangeramp(3)) to the appropriate value and held there. 
Note that while rangeramp specifies a ramprate, this gives a ramptime. To check that the ramptime is admissible make sure it that (rng(2)-rng(1))/npoints/ramptime is less than rangeramp(3). 


## waittime 
Amount of time to wait after setting the setchans and before getting data from the getchans.
## In-Loop Functions 
<a name="trigfn"></a>
### trigfn ###
This field, which may be left blank, is a function that is called for the first point of this loop. This is typically used to tell a self-ramping channel to start ramping or a buffered readout channel to start collecting data. 

**Example**
If we want to do an automatic ramp of a voltage channel on a decaDAC it needs to be triggered. This can be done with an AWG marker using
```
scan.loops(1).trigfn.fn = @smatrigawg;
scan.loops(1).trigfn.args = {[16]} 
```
which will call smatrigawg([16]) to trigger each iteration of the first loop. Here we use 16 because smdata.inst(16) is the AWG that will generate the trigger. If the function to be called has more than one argument, they should be specified as different cells in the args cell array. 

This is often used with smatrigfn. 

<a name="trafofn"></a>
### trafofn ###
This is shorthand for transformation function. The first argument (named x below, not be be confused with trafofn.args) to the trafofn is a vector of the current values of loops variables, starting with the inner-most loop. The second argument (named y below) of the trafofn is the current value of all the channels, as store in smdata.chanvals.
scan.loops(l).trafofn(k) will transform the range over which scan.loops(l).setchan{k} is swept. Ordinarily, a setchan is swept from rng(1) to rng(end) in npoints. However, it is often necessary to transform this sweep range into another one. For example, imagine we have
```
 scan.loops(1).setchan = {'V1','V2'}; 
 scan.loops(1).rng = [-.001 .001];
```
This means that both V1 and V2 will be simultaneously swept from -.001 to .001. However, imagine that  we would like to sweep V1 from -.001 to .001, but we want V2 to be swept from .001 to -.001.  The trafofn is a handy way to do this. If we set scan.loops(l).rng=[-.001 .001], which is the range we want for V1, then we want
```
scan.loops(l).trafofn(1).fn = @(x,y) x(1);
```
which is the identity function. This is the trivial trafofn. A blank trafofn will also be set to the identity by smrun.  We want to transform the values of V2, which is scan.loops(l).setchan{2}, so we set
```
scan.loops(l).trafofn(2).fn = @(x,y)-1*x(1);
scan.loops(l).trafofn(2).args = {};
```
which will invert the range for the channel V2.
We can imagine a more complicated trafofn such as
```
scan.loops(l).trafofn(2).fn = @(x,y,p)-p(1)*x(1)+p(2);
scan.loops(l).trafofn(2).args = {[4,23]};
```
which would pass the argument [4,23] to the trafofn to be used in place of p.

**NB**: It is possible to use a variable in the workspace as part of a trafofn.
```
scan.loops(l).trafofn(2).fn = @(x,y,p)slope*x(1)+offset;
scan.loops(l).trafofn(2).args = {};
```
assuming "slope" and "offset" exist. However, when trying to retrieve the scan, the values of slope and offset will not be easily accessed. It is often easier to store these in the trafofn.args field.

The format of how the function is called is: 
`val2 = trafocall(scandef(j).trafofn, x2, smdata.chanvals)`

### prefn
This is a function that is run before each point of the loop. This might be used, for instance, to start a function that feedbacks on a sensor so that it is centered, or to arm a ADQ for acquisition. This uses the same format as the trigfn and postfn. 

The format of how the function is called is: 
`fncall(scandef(j).prefn, xtrans)`;
### postfn
this is a function that is run after each point of the loop. This might be used to start a script to perform nuclear feedback or to check the values of the magnetic field gradient. This uses the same format as the trigfn and prefn. 

fncall(scandef(j).postfn, xtrans);
<a name="procfn"></a>
### procfn ##
See [Procfn](Procfn) for details on how to use procfns.
This is an optional field. If populated the procfn is capable of processing or analyzing data during the scan. This is useful if, for example, the scan produces a lot of data but only certain quantities such as means or histograms are desired.

<a name="datafn"></a>
### datafn ##
Like procfn, scan.loops(l).datafn is able to do simple processing on the data. The datafn doesn't return the data, so it can't be used to change the saved data, but it can be used, for instance, for plotting different than Special Measure performs, or triggering feedback cycles. 

The format of how it is called is 
`fncall(scandef(j).datafn, xtrans, data);`

<a name="saveloop"></a>
# saveloop #
It is often useful to tell smrun when to save the data coming out of the scan to disk. For example, saving every iteration of every loop is very slow, but only saving the data one time at the end of the scan is not optimal since a crash would cause data loss.  You can specify when do save data using scan.saveloop. saveloop is a numeric array; [_loop_, _iteration_].  _iteration_ defaults to 1 if not specified.  _loop_ defaults to 2 if not specified.
Data will get saved to disk every _iteration_'th iteration of the loop _loop_, where 1 is the fastest loop.  For example:

```
scan.saveloop=[1 1]; % Save to disk with every data point.  Slow.
scan.saveloop=[1 5]; % Save to disk with every 5th data point.
scan.saveloop=[3];   % Save every time the third loop is incremented.
```

<a name="disp"></a>
# disp #
What data is displayed is defined in the disp field of the scan. scan.disp is a struct array with the fields listed below. Each element of scan.disp describes one subplot to be displayed in the data window (Figure 1000). If nothing is specified in scan.disp, then figure 1000 will be blank.

fields of _disp_:
  * _loop_: loop during which to update display
  * _dim_: Dimension of data to be displayed, or 2 for plot or false-color image.
  * _channel_: Data channel to be shown. This is an index to all channels stored (i.e. those listed in loops(l).getchan for any loop l), starting with the slowest loop(?). If all channels are read in the same loop l, channel is simply the index of loops(l).getchan;
For example, imagine we have a scan with two loops. Imagine that the inner loop (loop(1)) has two getchangs, out1 and out2. If we want to have a 1-D plot of out1 that updates every time second loop begins and a 2-D color plot of out2 that updates every time the second loops begins we would have
```
scan.disp(1).loop = 2;
scan.disp(1).dim = 1;
scan.disp(1).channel = 1;

scan.disp(2).loop = 2;
scan.disp(2).dim = 2;
scan.disp(2).channel = 1;
```
<a name="consts"></a>
# consts #
It is often handy to have certain channels set to certain values at the beginning of a scan, for example, the sampling rate of a digitizing card. This is handled by scan.consts. scan.consts is a struct array with fields setchan and val. For each entry, i, of scan.consts, scan.consts(i).setchan is set to scan.consts(i).val before the scan executes.  The setchans must be strings of channel names and the consts are numerical values.
**example**
imagine we want to set the sampling rate of a digitizing card to 1e5 and the pulseline of an AWG to 1 before a scan starts. We would use
```
scan.consts(1).setchan = 'samprate';
scan.consts(1).val = 100000;
scan.consts(2).setchan = 'Pulseline';
scan.consts(2).val = 1;
```
<a name="configfn"></a>
# Configfn #
Just as it is handy to set certain variables to certain values before a scan, it is also handy to be able to execute certain function to configure a scan. This is done with scan.configfn. The configfn is a struct array with two fields: configfn.fn, which is the function call, and configfn.args, which are the arguments past to the configfn. In contrast to the in-loop functions (like prefn), this passes the scan as an argument and returns. This means that is necessary to use a wrapper around functions that do not take the scan as an argument. smaconfigwrap is useful for this purpose. (For an example of this, see cleanupfn). 
**Example**
if we want to use buffered acquisition on a scan, we need to configure the scan to do so. We use
```
scan.configfn.fn = @smabufconfig2
scan.configfn.args = {'arm',[1]}
```
which will call smabufconfig2('arm',[1])

<a name="Cleanupfn"></a>
# Cleanupfn #
The scan.cleanupfn is similar to scan.configfn, except it is executed after the scan completes. Like the configfn, it is a struct array with the fields cleanupfn.fn and cleanupfn.args.
**Example**
If we want to set the magnetic field back to zero at the end of a scan we need to use a wrapper function, since smset does not take scan as an argument (see configfn for more information). 
```
scan.cleanupfn.fn = @smaconfigwrap
scan.cleanupfn.args = {[@smset] 'B',[0]};
```
which will call smset('B',0) when the scan completes.

The function's format is: `scan = scan.cleanupfn(k).fn(scan, scan.cleanupfn(k).args{:});`
This is run even if the scan is escaped out of in the middle. 
# postfn 

<a name="fcns"></a>
# A note on specifying user functions in scan #
Functions lists to be executed at various points
(prefn, postfn, datafn, procfn, trigfn) can be specified as
cell arrays of function handles or struct arrays with fields fn
(function handle) and args (cell array with user arguments to be passed).  Any function handle can be replaced by a string, which will be interpreted by MATLAB's `str2func`.

For more details, see the auxiliary function fncall at the end of `smrun.m`.

Sample function for each format: 

Struct: 
`prefn.fn(1).fn = @smset
`prefn.fn(1).args = {'B',0}`

String: 
prefn.fn(1).fn = '@smset'  (this can be useful to avoid carrying around a big workspace) 
prefn.fn(1).args = {'B',0} (same as above) 

Cell: 
prefn.fn{1} = @sm_setgradient;

Cell / string
prefn.fn{1} = '@sm_setgradient'; 
Note that the two cell formats cannot take arguments. 

<a name="data"></a>
#Data#
scan.data is another optional field. Here you can store essentially anything that matlab knows how to handle: doubles, structs, strings, etc. 
Often this is used to store miscellaneous information about the experiment that does not fit neatly into the Special Measure framework. For instance, a Spin Qubits scan contains scan.data.pulsegroups: 
```
          name: 'dBz_21_04_128_1_44_3_A'
        seqind: 260
    lastupdate: 7.3610e+05
        npulse: [128 1]
         nline: 2
          nrep: 1
      lastload: 7.3610e+05
       zerolen: [128x2 double]
       readout: [1 2.3500 1.5000]
```

# What is saved #

When you run smrun with a filename as the second argument, the data from the scan is saved along with scan, the configvals, configdata, and configch. 



# Halting Scans #
<a name="halt"></a>
If you decide in the middle of a scan that you want to end the scan or pause it to get access to MATLAB again, you can do so cleanly by: 
-End scan: press escape. Will then run cleanupfn, save data and quit at the end of current point. 
-Halt scan: press space bar and scan paused with MATLAB keyboard control returned.  

 