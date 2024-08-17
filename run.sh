cd /home/runner
export PATH=/usr/bin:/bin:/tool/pandora64/bin:/apps/vcsmx/vcs/U-2023.03-SP2//bin:/usr/local/bin
export VCS_VERSION=U-2023.03-SP2
export VCS_PATH=/apps/vcsmx/vcs/U-2023.03-SP2//bin
export LM_LICENSE_FILE=27020@10.116.0.5
export VCS_HOME=/apps/vcsmx/vcs/U-2023.03-SP2/
export HOME=/home/runner
export UVM_HOME=/apps/vcsmx/vcs/U-2023.03-SP2//etc/uvm-ieee
vcs -full64 -licqueue '-timescale=1ns/1ns' '+vcs+flush+all' '+warn=all' '-sverilog' '+define+S50+define+SDR_32BIT' '+define+VCS' '-debug_access+all' '-cm' 'line+tgl+assert' '+plusarg_save' '+UVM_TESTNAME=test_1' '+ntb_random_seed=`date' '+%s`' +incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv $UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS -DVCS design.sv testbench.sv  && ./simv +vcs+lic+wait  ; echo 'Creating result.zip...' && zip -r /tmp/tmp_zip_file_123play.zip . && mv /tmp/tmp_zip_file_123play.zip result.zip