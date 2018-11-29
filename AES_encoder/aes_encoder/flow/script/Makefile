SHELL:=/bin/bash
XVHDL_OPTS=--relax
VHD_FILES := $(shell cat filelist.txt)
VERIF_ROOT=$(PRJ_ROOT)/verif/tests
	
build: vhdl.prj
	xvhdl $(XVHDL_OPTS) -prj vhdl.prj 2>&1 | tee compile.log

vhdl.prj: filelist.txt
	python $(PRJ_ROOT)/flow/script/xprj.py
    
filelist.txt: dirlist.txt
	python $(PRJ_ROOT)/flow/script/filelist.py

clean:
	rm -rf *.log *.jou *.pb vhdl.prj filelist.txt

sim:
	rm -rf ./infiles/*
	for filename in $(VERIF_ROOT)/$(TESTNAME)/*.txt; do cp $$filename ./infiles/; done
	xsim aes_keygen_tb -gui -key {Behavioral:sim_1:Functional:aes_keygen_tb} -tclbatch cmd.tcl -log simulate.log

test:
	for filename in $(VHD_FILES) ; do \
 		echo $$filename ; \
	done

		
