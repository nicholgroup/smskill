[_nextstr_,_nextnum_]=**smnext**(_name_, _opts_)
> smnext creates a numbered filename, and increments number by one each time it is called to create unique names, with the pattern name_number. The filename is copied to the cut buffer.  opts = 'quiet' will not print next filename to cmd line, 'nocutbuffer' prevents coyping name.

smnext only works if you are saving files in the current directory. 

If not using with smrun, it's necessary to preface file with sm_, as in  save(['sm_' smnext('filename')],'data') or smnext will not increment numbers.  

This is typically used as 
```
smrun(scan, smnext('chrg')) 
Next file: chrg_0104 
```
Which will save the file sm_chrg_0104.mat in the current directory. 

If you are using a new directory with no sm files, smnext will create the filename 'sm_chrg_0001'. 