import os

prj_dir = os.environ['PRJ_ROOT']

file_dlist = open("dirlist.txt","r")
file_flist = open("filelist.txt","w")
for line in file_dlist:
   path = prj_dir + "/" + line.replace('\n','');
   print(path)
   for elem in os.listdir(path):
      full_path = path + "/" + elem
      if not (os.path.isdir(full_path)):
         file_flist.write(full_path + "\n")
file_dlist.close()
file_flist.close()


