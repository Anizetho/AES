file_flist = open("filelist.txt","r")
file_prj   = open("vhdl.prj","w")

file_prj.write("vhdl xil_defaultlib  \\\n")
for line in file_flist:
   file_prj.write('"' + line.replace('\n','') +'"' + " \\\n")
file_prj.write("\nnosort")

file_flist.close()
file_prj.close()
