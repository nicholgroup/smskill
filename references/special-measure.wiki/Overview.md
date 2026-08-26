# Introduction #

Special Measure provides a simple frontend for MATLAB's instrument control toolbox, allowing users to quickly set up flexible scans through parameter space.

---

# Quick Reference #
## Structures ##
  * [Scans](Scans)
  * [smdata](smdata)

## Functions ##
### Main measurement routine ###
| **[smrun](smrun)** | Run a scan. |
|:----------------------|:------------|

### Channel Control ###
| | |
|:----------------------|:----------------------|
| **[smset](smset)** |   Set channel values. |
| **[smget](smget)** |  Read channel values. |
| **sminc** |  Increment list of channels by given value. |
| **[smprintchannels](smprintchannels)** | Print channel information |
| **[smprintrange](smprintrange)** |    Print range and rate information |
| **[smprintinst](smprintinst)** |    Print instrument information |

### Scan configuration ###
| | |
|:----------------------|:----------------------|
| **[smdiagpar](smdiagpar)**   | Configure scan rotation. |
| **[smscanpar](smscanpar)**   | Set scan range and resolution. |
| **[smalintrafo](smalintrafo)** | Set up a rotated scan.   |
| **smsetscanconst** | Sets a new value for a scan const of given setchan |
| **smgetscanconst** | Gets value of scan const of given setchan |
| **[smprintscan](smprintscan)** | Print scan parameters.   |

### Running Scans ###
| | |
|:----------------------|:----------------------|
| **[smnext](smnext)**   | Create numbered filenames for scans |
| **[smabufconfig2](smabufconfig2)** | Configure buffered readout |  
| **[smatrigfn](smatrigfn)** | Send a software trigger | 
| **[smundo](smundo)** | Deletes most recent sm file in folder | 

### Setup ###
| | |
|:----------------------------|:-------------------------------------|
| **[smaddchannel](smaddchannel)** | Create a new channel |
| **[sminitdisp](sminitdisp)**     |   Configure  figure 1001 to display current channel values.  To disable this feature, close figure 1001. |
| **[smrestore](smrestore)** | Restore channel values of channels in configch to earlier time | 
| **smcheckdata** | Adds empty configch, configfn, chanvals to smdata if they don't exist |
| **smdispchan**   | Update display of current values |
| **smsaveinst**   |  Export insts from current rack into separate files after stripping data.inst if present. |
| **smloadinst**   | Load instrument from file and add to some position in smdata. 
| **smsavechans**   | Save all channels from smdata to file. |
| **smloadchans**   | Load list of channels and replace smdata.channels with it. |

### Instrument Control ###
| | |
|:----------------------|:----------------------|
| **[smopen](smopen)**  |   Open instruments. |
| **[smclose](smclose)** | Close instruments.  |
| **[smprintinst](smprintinst)** |	 Print instrument information |
| **smflush**   | Read data from instrument until BytesAvailable=0  |

### Low-level Instrument I/O ###
| | |
|:----------------------|:----------------------|
| **[smprintf](smprintf)** | Wrapper for fprintf. |
| **[smscanf](smscanf)**   | Wrapper for fscanf.  |
| **[smquery](smquery)**   |  Wrapper for query.  |

### Lookup Functions ###
|    |      | 
|:---------------- | :-------------- |
| **sminstlookup** | Converts str or cell array of instrument names to vertical list of smdata indices |  
| **smchanlookup** | Converts str or cell array of channel names to vertical list of smdata indices | 
| **smchaninst** | Gets the instrument and channel index for list of channels | 


### Logging ###
|    |      | 
|:---------------- | :-------------- |
| **logadd** | Add line to logfile. Mostly used by smrun to save chanvals at the beginning of scan. |  
| **logentry** | Add line to logfile with date. Mostly used by smrun to log times of all scans. | 
| **logsetfile** | Change logfile | 

---

## Auxiliary functions ##
### Configuration and control of specific instruments ###

| **smarampYokoSR830dmm** | Set up linewise acquisition with dmm and/or lockin |
|:------------------------|:---------------------------------------------------|
| **smarampYokoSR830**    |    Subset of above, no dmm support                 |
| **smarampYokoTDS**      |      Set up linewise acquisition with TDS5104.     |
| **smaDMMsnglmode**      |	     Restore default sample parameters for DMM(s). |
| **smastopYokos**        |	     Stop ramps on Yokos.                          |
| **[smadacinit](smadacinit)**          | Initialize DACs to correct mode, values | 
| **[smadachandshake](smadachandshake)**     | Check which DAC you are connected to | 




