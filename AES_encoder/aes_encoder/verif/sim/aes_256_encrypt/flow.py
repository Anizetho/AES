#!/usr/bin/python2.7
import os
import sys

PRJ_ROOT_ENV = 'AES_PRJ'
PRJ_DIR_PATH  = os.environ[PRJ_ROOT_ENV]

FLOW_SCRIPT_DIR = "flow/script/"

def main(argv):
   args = ""
   for arg in argv:
      args += (' ' + arg)
   #cmd = "python27 " + PRJ_DIR_PATH + FLOW_SCRIPT_DIR + "flow.py " + args
   print("START")
   cmd = "python " + "../../../" + FLOW_SCRIPT_DIR + "flow.py " + args
   print("END")
   print(cmd)
   os.system(cmd)

print("ROOT")
main(sys.argv[1:])
