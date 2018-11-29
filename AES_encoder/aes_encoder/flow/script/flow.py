#!/usr/bin/python2.7
import os
import sys
import datetime

import file_compare

PRJ_ROOT_ENV = 'AES_PRJ'
PRJ_DIRPATH  = os.environ[PRJ_ROOT_ENV]

WORKDIR      = os.environ['PWD']
TOP_LVL      = WORKDIR.split('/')[-1]

#WORK_DIRPATH      = PRJ_DIRPATH + '/verif/sim/' + TOP_LVL + '/'
#GEN_DIRPATH       = WORK_DIRPATH + "gen_" + TOP_LVL + "/"
#GEN_DIRPATH       = WORKDIR + "/gen_" + TOP_LVL + "/"

DEFAULT_SNAPSHOT  = TOP_LVL

WORKLIB_NAME      = "mylib"
WORKLIB_DIRNAME   = WORKLIB_NAME + "\\"
WORKLIB_PATH      = WORKLIB_DIRNAME + '\\'

DIRLIST_FILENAME  = 'dirlist.txt'
FILELIST_FILENAME = 'filelist.txt'
SIMOUT_FILENAME   = 'simout_compare_filelist.txt'

DIRLIST_FILEPATH  = "..\\" + DIRLIST_FILENAME  #WORK_DIRPATH + DIRLIST_FILENAME
FILELIST_FILEPATH = "..\\" + FILELIST_FILENAME #GEN_DIRPATH  + FILELIST_FILENAME

XPRJ_FILENAME     = 'vhdl.prj'

TEST_DIRPATH      = PRJ_DIRPATH + "/verif/tests/"

def check(filepath, failOnWarning = False):
   '''
   '''
   rpt_log    = ""
   for logfile in filepath:
      if not os.path.isfile(logfile):
         flowMsg("ERROR", "File "+ logfile + " not found !")
      else:
         warningCnt = 0
         warninglog = ""
         errorCnt   = 0
         errorlog   = ""

         flowMsg("INFO", "Checking "+ logfile + "...")
         with open(logfile,'r') as r_file:
            for line in r_file:
               if 'WARNING' in line:
                  warninglog += line
                  flowMsg("WARNING", "reported in " + logfile + "\n" + line)
               elif 'ERROR' in line:
                  errorlog += line
                  flowMsg("ERROR", "reported in " + logfile + "\n" + line)
         rpt_log += "-- " + logfile + "\n" + errorlog + warninglog
   with open('log/report.txt',"w") as report :
      report.write(rpt_log)
   return not (errorCnt > 0 or ((warningCnt > 0) and failOnWarning))

def gen_filelist():
   '''
   Generate filelist.txt, a list of files found in directories mentionned by dirlist.txt
   '''
   file_dlist = open(DIRLIST_FILEPATH,"r")
   file_flist = open(FILELIST_FILEPATH,"w+")
   for line in file_dlist:
      path = os.environ[PRJ_ROOT_ENV] + "/" + line.replace('\n','');
      print(path)
      for elem in os.listdir(path):
         full_path = path + "/" + elem
         if (not (os.path.isdir(full_path)) and (elem.split('.')[-1] == "vhd")):
            file_flist.write(full_path + "\n")
   file_dlist.close()
   file_flist.close()

def gen_xprj():
   '''
   Generate a xilinx project file including the files mentionned in the filelist file.
   '''
   file_flist = open(FILELIST_FILEPATH,"r")
   file_prj   = open(XPRJ_FILEPATH,"w+")

   file_prj.write("vhdl xil_defaultlib  \\\n")
   for line in file_flist:
      file_prj.write('"' + line.replace('\n','') +'"' + " \\\n")
   file_prj.write("\nnosort")

   file_flist.close()
   file_prj.close()

def compile():
   '''
   VHD Analysis of files mentionned in the filelist file (generated if not existing).
   Elaboration of the testbench
   '''
   log = "log/compile.log"
   # Regen filelist in case it doesn't exist
   if not os.path.exists(FILELIST_FILEPATH):
      gen_filelist()

   file_flist     = open(FILELIST_FILEPATH,"r")
   regen_filelist = ""
   regen_cnt      = 0
   for line in file_flist:
      #remove endline character ("\n")
      srcfilepath = line[0:-1]
      filename    = srcfilepath.split('/')[-1].split('.')[0] + ".vdb"
      genfilepath = WORKLIB_PATH + filename     
      
      # Generation not required if a gen file exist and is older than source
      regen=True
      if os.path.isfile(genfilepath):
         if os.path.getmtime(genfilepath)>os.path.getmtime(srcfilepath):
            regen=False

      if (regen):
         regen_cnt     += 1
         regen_filelist = regen_filelist + " " + srcfilepath

   if (regen_cnt>0):
      # File Analysis
      cmd  = "xvhdl"
      cmd += " -relax"                             # Relax strict language rules
      cmd += " -work " + WORKLIB_NAME              # Specify the work library
      cmd += " -initfile='./../xsim.ini'"          # Library mapping file
      cmd += " -log " + log                        # Log filename
      cmd += " " + regen_filelist                  # 
      cmd += "> log/garbage.log"
      flowMsg("INFO", str(regen_cnt) + " .vdb files needs to be regenerated:\n Vivado Anylysis cmd: " + cmd)
      os.system(cmd);

      # Elaboration
      cmd  = "xelab"
      cmd += " -relax"                             # Relax strict language rules
      cmd += " -debug typical"                     # typical/line/xlibs/off/all
      cmd += " -mt auto"                           # Number of subc-compilation jobs
      cmd += " -L secureip"                        # Specify search libraries for the instantiated non-VHDL design unit
      cmd += " -log log/elaborate.log"             # Log filename
      cmd += " -initfile='./../xsim.ini'"          # Library mapping file
      cmd += " " + WORKLIB_NAME + '.' + TOP_LVL    #
      cmd += "> log/garbage.log"
      flowMsg("INFO","Vivado Elaboration cmd: " +cmd)
      os.system(cmd);
   else:
      flowMsg("INFO", "No change in soure files")

def flowMsg(msg_type, msg_txt, msg_rpt=False, clr_cnt=False):
   '''
   Function to be used for any Flow debug message
      msg_type - 'INFO'/'WARNING'/'ERROR'
      msg_txt  - Personalised message
      msg_rpt  - Display Message Report after the message 
   '''
   if msg_type=='INFO': 
      flowMsg.info_cnt += 1
   elif msg_type=='WARNING':
      flowMsg.warning_cnt += 1
   elif msg_type=='ERROR':
      flowMsg.error_cnt += 1
   else:
      flowMsg.other_cnt += 1
   print("HWPYFLOW - " + msg_type + ": " + msg_txt)

   # Print stats 
   if msg_rpt:
      print("HWPYFLOW - Execution reported " + str(flowMsg.info_cnt)    + " INFO(s), "     \
                                             + str(flowMsg.warning_cnt) + " WARNING(s), "  \
                                             + str(flowMsg.error_cnt)   + " ERROR(s) and " \
                                             + str(flowMsg.other_cnt)   + " UNKNONW MESSAGE(s).")
   # Clear count
   if clr_cnt:
      flowMsg.info_cnt    = 0
      flowMsg.warning_cnt = 0
      flowMsg.error_cnt   = 0
      flowMsg.other_cnt   = 0
  
def sim(testname):
   '''
   
   '''
   testdir = TEST_DIRPATH + testname + '/'
   if not os.path.exists(testdir):
      flowMsg("ERROR", "Test directory '" + testdir + "' doesn't exist.")
   
   cmd = "cp -rf " +  PRJ_DIRPATH + "/flow/script/cmd.tcl ./"
   os.system(cmd)  

   infiles_dir  = "./infiles/"
   outfiles_dir = "./outfiles/"
   for dir in [infiles_dir, outfiles_dir]:
      if os.path.exists(dir):
         os.system("rm -rf " + dir + "/*")
      else:
         os.makedirs(dir)
   cmd = "cp -rf " + testdir + "* " + infiles_dir
   os.system(cmd)
   
   cmd  = "xsim"
   cmd += " -key {Behavioral:sim_1:Functional:XXX" + TOP_LVL + "}" 
   cmd += " -tclbatch cmd.tcl" 
   cmd += " -log log/simulate.log"
   cmd += " " + WORKLIB_NAME + '.' + TOP_LVL    #
   cmd += "> garbage.log"
   flowMsg("INFO", "Vivado simulation cmd: " + cmd)
   os.system(cmd)
   
   f2compare_fp = "../simout_compare_filelist.txt"
   if not os.path.isfile(f2compare_fp):
      flowMsg("ERROR","File " + WORKDIR + "/simout_compare_filelist.txt doesn't exist")
   else:
      f2comp_f_handler = open("../simout_compare_filelist.txt",'r')
      for f in f2comp_f_handler:
         filename = f.strip('\n')
         if (file_compare.f_compare(infiles_dir + filename, outfiles_dir + filename) != 0):
            flowMsg("ERROR","Mismatch in file " + filename)
            return -1
         else:
            flowMsg("INFO","Check of outfile " + filename + " is OK.")
   return 0

def regression(testlist):
   '''
   
   '''
   if not os.path.isfile("../" + testlist):
      flowMsg("ERROR", "Testlist '" + testlist + "' not found. Please re-run ./flow.py build.")
   else:
      os.system("cp ../" + testlist + " ./" + testlist)
   #Result directory creation
   dt = datetime.datetime.now()
   regr_dir = "regression_test_rslt_" + str(dt.year) + str(dt.month) + str(dt.day) + '_' + str(dt.hour) + str(dt.minute) + str(dt.second) + '/'
   os.system("mkdir " + regr_dir)
   os.system("mkdir " + regr_dir + "failed")
   os.system("mkdir " + regr_dir + "passed")
   test_passed_file = open(regr_dir + "passed.txt","w")
   test_failed_file = open(regr_dir + "failed.txt","w")

   tests_cnt   = 0
   success_cnt = 0
   with open(testlist,'r') as file_testlist:
      for tn in file_testlist:
         testname    = tn.strip('\n')
         test_passed = (sim(testname)==0)

         if test_passed:
            test_rslt_dir = regr_dir + "passed/"
            test_passed_file.write(testname)
         else:
            test_rslt_dir = regr_dir + "failed/"
            test_failed_file.write(testname)
         test_rslt_dir += testname

         os.system("mkdir " + test_rslt_dir)
         os.system("cp -rf infiles " + test_rslt_dir + '/')
         os.system("cp -rf outfiles " + test_rslt_dir + '/')

         tests_cnt += 1
         rslt = check(['log/simulate.log']) and test_passed
         if rslt:
            success_cnt += 1
   flowMsg("INFO", "Tests succeded: " + str(success_cnt) + "/" + str(tests_cnt))

def clean():
   '''
   Remove all generated files and directories
   '''
   cmd = "rm -rf gen* LASTBUILD filelist.txt"
   flowMsg("INFO", "pwd:<" + os.environ['PWD'] + ">")
   flowMsg("INFO","Clean cmd: " + cmd)
   os.system(cmd)

def wave():
   wdb_filename = WORKLIB_NAME + '.' + TOP_LVL + ".wdb"
   tcl_filename = "loadwave.tcl"
   if os.path.isfile(wdb_filename):
      with open(tcl_filename, "w") as tcl_file:
         tcl_file.write("open_wave_database " + wdb_filename)      
      cmd = "vivado -source " + tcl_filename
      os.system(cmd)
   else:
      flowMsg("ERROR", "File '" + wdb_filename + "' doesn't exist! Please run a simulation first")

def use():
   '''
   '''

# Main function
   # argv[0] = build OR sim OR syn

flowMsg.info_cnt    = 0
flowMsg.warning_cnt = 0
flowMsg.error_cnt   = 0
flowMsg.other_cnt   = 0

def main(argv):
   '''
   Usage: <action>_<snapshot> <parameters>
      where <action>     : is the command to execute (build, sim, syn, ...)
            <snapshot>   : default is TOP_LVL 
            <parameters> : are parameters for specified <action>
   '''
   flowMsg("INFO", "---> Starting hwpyflow at : " + WORKDIR + " --")
   flowMsg("INFO", "PRJ_ROOT = " + PRJ_DIRPATH)
   flowMsg("INFO", "TOP_LVL  = " + TOP_LVL)

   # Deal with different snapshots.
   # If not specified in the command, use the latest one.
   if len(argv)<1:
      flowMsg("ERROR", "No enough arguments! (<" + str(argv) + ">).")
      instr = "use"
   else:
      instr_snapshot = argv[0].split('_')
      instr          = instr_snapshot[0]
      snapshot       = "img"
      if len(instr_snapshot)>1:
         for subword in instr_snapshot[1:]:
            snapshot += ('_' + subword)
      else:
         if os.path.isfile('LASTBUILD'):
            file_lastbuild = open('LASTBUILD',"r")
            snapshot = file_lastbuild.read().strip('\n')
         else:
            snapshot = DEFAULT_SNAPSHOT
   flowMsg("INFO","SNAPSHOT = " + snapshot)
   
   # Directories creation (if necessary)
   genpath = "gen_" + snapshot
   if not os.path.exists(genpath):
      flowMsg("INFO", "It's 1st execution (or clean occured), creation of directory: '" + genpath + "'")
      os.system("mkdir " + genpath)

   logdir = genpath + "\log"
   if not os.path.exists(logdir):
      os.system("mkdir " + logdir)
      os.system("chmod 777 " + logdir)

   # Command analysis and execution
   if (instr=='clean'):
      clean()
   else:
      os.chdir(genpath)
      if (instr=='build'):
         compile()
         os.system("pwd")
         check(['./log/compile.log', './log/elaborate.log'])
         with open("../LASTBUILD",'w') as lastbuild:
            lastbuild.write(snapshot)
      elif (instr=='sim'):
         if len(argv)>1:
            testname = argv[1]
         else:
            testname = 'test_cipher_256_fips197'
         sim(testname)
         check(['./log/simulate.log'])
      elif (instr=='syn'):
         flowMsg("WARNING", "Synthesis hasn't been implemented yet!\nExit")
         return 1
      elif (instr=='wave'):
         wave()
      elif (instr=='regression'):
         regression(argv[1])
      else:
         flowMsg("ERROR", "Command '" + argv[0] + "' is unknown")
         return 1
      os.chdir("./..")
      flowMsg('INFO',"<--- Ending hwpyflow", msg_rpt=True)
   return 0

main(sys.argv[1:])
