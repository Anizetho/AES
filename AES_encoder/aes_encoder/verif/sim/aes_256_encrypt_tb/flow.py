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
   cmd = "python " + "../../../" + FLOW_SCRIPT_DIR + "flow.py " + args
   os.system(cmd)

main(sys.argv[1:])
