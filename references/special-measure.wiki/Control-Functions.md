**smclose** 
See [smclose](smclose)

**smflush**`(inst)` 

Reads data from instrument until BytesAvailable is 0. 
Useful for clearing aborted data collections. 


**smopen**
See [smopen](smopen)


**smquery**`(inst, fmt, varargin)`

Wrapper for query that takes in special measure instrument number. 

**smprintf**`(inst, fmt, varargin)`

Wrapper for fprintf that takes in special measure instrument number. 

**smscanf**`(inst,varargin)`

Wrapper for fscanf that takes in special measure instrument number. 