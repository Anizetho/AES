#!/usr/bin/python2.7
import os
import sys

def f_compare(ref_filepath, comp_filepath, comment_line_start="--", stop_at_1st_error = True):
   if not os.path.isfile(ref_filepath):
      print("Reference file not found: " + ref_filepath)
      return -1
   if not os.path.isfile(comp_filepath):
      print("Comparison file not found: " + comp_filepath)
      return -1

   ref_f_handler  = open(ref_filepath,  'r')
   comp_f_handler = open(comp_filepath, 'r')

   ref_l_cnt    = 0
   comp_l_cnt   = 0

   mismatch_cnt = 0
  
   for ref_line in ref_f_handler:
      ref_l = ref_line.strip('\n')
      ref_l_cnt += 1
      if not ref_l.startswith(comment_line_start):
         comp_l     = comp_f_handler.readline().strip('\n')
         comp_l_cnt += 1
         if not comp_l:
            print("Error - Comparison file is too short")
            return (mismatch_cnt + 1)
         if (comp_l != ref_l):
            mismatch_cnt += 1
            print("Error mismatch:\n \
                   EXPECTED: " + ref_l + " (l" + str(ref_l_cnt) + ")\n \
                   ACTUAL  : " + comp_l + " (l" + str(comp_l_cnt) + ")")
            if stop_at_1st_error:
               return mismatch_cnt
   rem_line = comp_f_handler.readline()
   comp_l_cnt += 1
   if rem_line:
      print("Error - Comparison file is too long\n (l" + ")")
      print("Line is <" + rem_line + ">")
      return (mismatch_cnt + 1)
   return mismatch_cnt


