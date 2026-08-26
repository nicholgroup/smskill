# Installation #
The easiest way to install Special Measure is to go to [homepage](https://github.com/yacobylab/special-measure) and click "Clone or Download," choosing "Download As Zip." Then, unzip the folder to the location you want to run it from. 
Next, add to your search path in Matlab, going to "Set Path" on the Home screen in Matlab, and clicking "Add with Subfolders" and selecting the special-measure folders. Then type 'rehash path' in the Matlab command line so that it will recognize the new folders. 

If you are a bit more adept with Git, you can use it, and clone the repository on the command line or GUI once you've installed git. The path is https://github.com/yacobylab/special-measure.git

# Startup #

To set up a MATLAB session for running SM, proceed as follows:
  * You need an instrument control toolbox. (i.e., [Keysight](https://www.keysight.com/main/software.jspx?cc=US&lc=eng&ckey=2175637&nid=-11143.0.00&id=2175637), or [National Instruments](http://www.ni.com/download/ni-visa-18.0/7597/en/)). These links will also install a GUI for locating instruments, which can be helpful when you are setting up your rack. 
  * Make sure the sm and subfolders are in your path.
  * Make smdata accessible from the workspace by typing `global smdata;` This is necessary only once per Matlab session, or after a `clear global` command.
  * Load a rack from a MATLAB (.mat) file. If this is the first time, you will need to create objects for instrument communications. See [Rack Setup](#rack) below. 
  * Open instruments with smopen. (Assuming they follow the standard convention discussed in section [Writing Drivers](Writing-Drivers).

<a name="Rack"></a>
# Rack Setup #

We are still working on simplifying setting up the rack. At this point, it is simplest to start with an already existing rack. When you are starting on a new computer though, you will need to create a set of instrument objects. You need to know what type of connection you have: usually either GPIB, Serial (USB/RS232), or TCPIP (Ethernet). In some other cases, we connect using C libraries, which tends to be very specific to the instrument and won't be discussed further here. Each of these has a number attached to it: the GPIB port number, the serial COM number, the TCPIP IP address. The easiest way to make the objects is to call `smobj`, so read the help file to see how it works. If you save this rack, loading it on the same machine on the future, the instruments should keep working without having to remake the objects. 

<br>
Occasionally, it may be necessary to close and reopen instruments, for example to change certain properties such as the buffer size, or if the instrument crashes. For instruments following the standard convention, this can be done with <a href='smclose.md'>smclose</a> and <a href='smopen.md'>smopen</a>.<br>
<br>


<h3>See Also</h3>
<ul><li><a href='smdata.md'>smdata</a>
</li><li><a href='SpecialMeasure.md'>SpecialMeasure</a>