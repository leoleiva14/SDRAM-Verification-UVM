class funct_coverage extends uvm_component;
  `uvm_component_utils(funct_coverage)

  /*********************************/
  /*--------- Constructor ---------*/
  /*********************************/
  function new (string name = "funct_coverage", uvm_component parent = null);
    super.new(name, parent);
    cov_wishbone_write = new();
    cov_wishbone_read = new();
    cov_sdr_config = new();
    cov_col_bits = new();
    cov_chip_select = new(); 
    cov_write_address = new();
    cov_read_address = new();
    cov_sel_range = new();
    cov_cfg_sdr_trcar_d = new();
    cov_cfg_sdr_trp_d = new();
    cov_cfg_sdr_rfmax = new();
    cov_reset_initdone = new();
  endfunction

  /*********************************/
  /*------ General Signals --------*/
  /*********************************/
  virtual interface_bus_master vif;

  /*********************************/
  /*------- Build Phase -----------*/
  /*********************************/
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction

  /*********************************/
  /*--------- Run Phase -----------*/
  /*********************************/
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(posedge vif.sys_clk) begin
        cov_wishbone_write.sample();
        cov_wishbone_read.sample();
        cov_sdr_config.sample();
        cov_col_bits.sample();
        cov_chip_select.sample();
        cov_write_address.sample();
        cov_read_address.sample();
        cov_sel_range.sample();
        cov_cfg_sdr_trcar_d.sample();
    	cov_cfg_sdr_trp_d.sample();
    	cov_cfg_sdr_rfmax.sample();
        cov_reset_initdone.sample();
      end
    end
  endtask

  /*********************************/
  /*--------- Covergroups ---------*/
  /*********************************/
  covergroup cov_wishbone_write;
    feature_wb_stb_i_high: coverpoint vif.wb_stb_i {
      bins stb_i_is_1 = {1};
    }

    feature_wb_cyc_i_high: coverpoint vif.wb_cyc_i {
      bins cyc_i_is_1 = {1};
    }

    feature_wb_we_i_high: coverpoint vif.wb_we_i {
      bins we_i_is_1 = {1};
    }

    feature_wb_ack_o_high: coverpoint vif.wb_ack_o {
      bins ack_o_is_1 = {1};
    }

    feature_data_write: coverpoint vif.wb_dat_i {
      bins range_0_3FFFFFFF = {[32'h00000000 : 32'h3FFFFFFF]};
      bins range_40000000_7FFFFFFF = {[32'h40000000 : 32'h7FFFFFFF]};
      bins range_80000000_BFFFFFFF = {[32'h80000000 : 32'hBFFFFFFF]};
      bins range_C0000000_FFFFFFFF = {[32'hC0000000 : 32'hFFFFFFFF]};
    }

    cross_wb_signals_write: cross feature_wb_stb_i_high, feature_wb_cyc_i_high, feature_wb_we_i_high, feature_wb_ack_o_high, feature_data_write {
      bins all_high_range_0_3FFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                       binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                       binsof(feature_wb_we_i_high.we_i_is_1) &&
                                       binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                       binsof(feature_data_write.range_0_3FFFFFFF);
      bins all_high_range_40000000_7FFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                              binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                              binsof(feature_wb_we_i_high.we_i_is_1) &&
                                              binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                              binsof(feature_data_write.range_40000000_7FFFFFFF);
      bins all_high_range_80000000_BFFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                              binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                              binsof(feature_wb_we_i_high.we_i_is_1) &&
                                              binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                              binsof(feature_data_write.range_80000000_BFFFFFFF);
      bins all_high_range_C0000000_FFFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                              binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                              binsof(feature_wb_we_i_high.we_i_is_1) &&
                                              binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                              binsof(feature_data_write.range_C0000000_FFFFFFFF);
    }
  endgroup

  covergroup cov_wishbone_read;
    feature_wb_stb_i_high: coverpoint vif.wb_stb_i {
      bins stb_i_is_1 = {1};
    }

    feature_wb_cyc_i_high: coverpoint vif.wb_cyc_i {
      bins cyc_i_is_1 = {1};
    }

    feature_wb_we_i_low: coverpoint vif.wb_we_i {
      bins we_i_is_0 = {0};
    }

    feature_wb_ack_o_high: coverpoint vif.wb_ack_o {
      bins ack_o_is_1 = {1};
    }

    feature_data_read: coverpoint vif.wb_dat_o {
      bins range_0_3FFFFFFF = {[32'h00000000 : 32'h3FFFFFFF]};
      bins range_40000000_7FFFFFFF = {[32'h40000000 : 32'h7FFFFFFF]};
      bins range_80000000_BFFFFFFF = {[32'h80000000 : 32'hBFFFFFFF]};
      bins range_C0000000_FFFFFFFF = {[32'hC0000000 : 32'hFFFFFFFF]};
    }

    cross_wb_signals_read: cross feature_wb_stb_i_high, feature_wb_cyc_i_high, feature_wb_we_i_low, feature_wb_ack_o_high, feature_data_read {
      bins all_high_range_0_3FFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                       binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                       binsof(feature_wb_we_i_low.we_i_is_0) &&
                                       binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                       binsof(feature_data_read.range_0_3FFFFFFF);
      bins all_high_range_40000000_7FFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                              binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                              binsof(feature_wb_we_i_low.we_i_is_0) &&
                                              binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                              binsof(feature_data_read.range_40000000_7FFFFFFF);
      bins all_high_range_80000000_BFFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                              binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                              binsof(feature_wb_we_i_low.we_i_is_0) &&
                                              binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                              binsof(feature_data_read.range_80000000_BFFFFFFF);
      bins all_high_range_C0000000_FFFFFFFF = binsof(feature_wb_stb_i_high.stb_i_is_1) &&
                                              binsof(feature_wb_cyc_i_high.cyc_i_is_1) &&
                                              binsof(feature_wb_we_i_low.we_i_is_0) &&
                                              binsof(feature_wb_ack_o_high.ack_o_is_1) &&
                                              binsof(feature_data_read.range_C0000000_FFFFFFFF);
    }
  endgroup
  
  covergroup cov_sdr_config;
    feature_cfg_sdr_mode_reg_023: coverpoint vif.cfg_sdr_mode_reg {
      bins mode_023 = {13'h023};
    }

    feature_cfg_sdr_mode_reg_033: coverpoint vif.cfg_sdr_mode_reg {
      bins mode_033 = {13'h033};
    }

    feature_cfg_sdr_cas_2: coverpoint vif.cfg_sdr_cas {
      bins cas_2 = {3'h2};
    }

    feature_cfg_sdr_cas_3: coverpoint vif.cfg_sdr_cas {
      bins cas_3 = {3'h3};
    }

    feature_read_operation: coverpoint (vif.sdr_cas_n == 0 && vif.sdr_ras_n == 1 && vif.sdr_we_n == 1) {
      bins read_active = {1};
    }

    cross_cfg_023_2_read: cross feature_cfg_sdr_mode_reg_023, feature_cfg_sdr_cas_2, feature_read_operation {
      bins cfg_023_2_read = binsof(feature_cfg_sdr_mode_reg_023.mode_023) && binsof(feature_cfg_sdr_cas_2.cas_2) && binsof(feature_read_operation.read_active);
    }

    cross_cfg_033_3_read: cross feature_cfg_sdr_mode_reg_033, feature_cfg_sdr_cas_3, feature_read_operation {
      bins cfg_033_3_read = binsof(feature_cfg_sdr_mode_reg_033.mode_033) && binsof(feature_cfg_sdr_cas_3.cas_3) && binsof(feature_read_operation.read_active);
    }
  endgroup

  covergroup cov_col_bits;
    feature_cfg_col_bits: coverpoint vif.cfg_col_bits {
      bins cfg_00 = {2'b00};
      bins cfg_01 = {2'b01};
      bins cfg_10 = {2'b10};
      bins cfg_11 = {2'b11};
    }

    feature_we: coverpoint vif.wb_we_i {
      bins we_write = {1};
      bins we_read = {0};
    }

    cross_cfg_bank: cross feature_cfg_col_bits, feature_we {
      bins cfg_00_we_write = binsof(feature_cfg_col_bits.cfg_00) && binsof(feature_we.we_write);
      bins cfg_01_we_write = binsof(feature_cfg_col_bits.cfg_01) && binsof(feature_we.we_write);
      bins cfg_10_we_write = binsof(feature_cfg_col_bits.cfg_10) && binsof(feature_we.we_write);
      bins cfg_11_we_write = binsof(feature_cfg_col_bits.cfg_11) && binsof(feature_we.we_write);
      bins cfg_00_we_read = binsof(feature_cfg_col_bits.cfg_00) && binsof(feature_we.we_read);
      bins cfg_01_we_read = binsof(feature_cfg_col_bits.cfg_01) && binsof(feature_we.we_read);
      bins cfg_10_we_read = binsof(feature_cfg_col_bits.cfg_10) && binsof(feature_we.we_read);
      bins cfg_11_we_read = binsof(feature_cfg_col_bits.cfg_11) && binsof(feature_we.we_read);
    }
  endgroup

  covergroup cov_chip_select;
    feature_sdr_cs_n: coverpoint vif.sdr_cs_n {
      bins cs_n_is_0 = {0};
      bins cs_n_is_1 = {1};
    }

    feature_wb_we_i: coverpoint vif.wb_we_i {
      bins we_is_0 = {0};
      bins we_is_1 = {1};
    }

    cross_chip_select_signals: cross feature_sdr_cs_n, feature_wb_we_i {
      bins cs_n_cross = binsof(feature_sdr_cs_n.cs_n_is_0) && binsof(feature_wb_we_i.we_is_1);
    }
  endgroup

  covergroup cov_write_address;
    feature_we: coverpoint vif.wb_we_i {
      bins we_write = {1};
    }

    feature_addr_range: coverpoint vif.wb_addr_i {
    bins range_0 = {[32'h00000000 : 32'h000000C7]}; // Primeras 200 direcciones
    bins range_1 = {[32'h1FFFFF38 : 32'h200000BF]}; // Direcciones en la mitad de la memoria
    bins range_2 = {[32'h3FFFFF38 : 32'h400000BF]}; // Direcciones al 75% de la memoria
    bins range_3 = {[32'h7FFFFF38 : 32'h800000BF]}; // Últimas 200 direcciones
  }

    cross_we_addr: cross feature_we, feature_addr_range {
      bins we_range_0 = binsof(feature_we.we_write) && binsof(feature_addr_range.range_0);
      bins we_range_1 = binsof(feature_we.we_write) && binsof(feature_addr_range.range_1);
      bins we_range_2 = binsof(feature_we.we_write) && binsof(feature_addr_range.range_2);
      bins we_range_3 = binsof(feature_we.we_write) && binsof(feature_addr_range.range_3);
    }
  endgroup

  covergroup cov_read_address;
    feature_we: coverpoint vif.wb_we_i {
      bins we_read = {0};
    }

    feature_addr_range: coverpoint vif.wb_addr_i {
      bins range_0 = {[32'h00000000 : 32'h000000C7]}; 
      bins range_1 = {[32'h1FFFFF38 : 32'h200000BF]}; 
      bins range_2 = {[32'h3FFFFF38 : 32'h400000BF]}; 
      bins range_3 = {[32'h7FFFFF38 : 32'h800000BF]}; 
    }

    cross_we_addr: cross feature_we, feature_addr_range {
      bins read_range_0 = binsof(feature_we.we_read) && binsof(feature_addr_range.range_0);
      bins read_range_1 = binsof(feature_we.we_read) && binsof(feature_addr_range.range_1);
      bins read_range_2 = binsof(feature_we.we_read) && binsof(feature_addr_range.range_2);
      bins read_range_3 = binsof(feature_we.we_read) && binsof(feature_addr_range.range_3);
    }
  endgroup

  covergroup cov_sel_range;
    feature_wb_sel_i_range: coverpoint vif.wb_sel_i {
      bins range_0_3 = {[0:3]};  
      bins range_4_7 = {[4:7]};   
      bins range_8_11 = {[8:11]};  
      bins range_12_15 = {[12:15]};
    }

    feature_wb_signals_high: coverpoint {vif.wb_stb_i, vif.wb_cyc_i, vif.wb_we_i, vif.wb_ack_o} {
      bins all_high = {4'b1111}; 
    }
    
    feature_wb_sel_i: cross feature_wb_sel_i_range, feature_wb_signals_high {
      bins all_high_range_0_3 = binsof(feature_wb_sel_i_range.range_0_3) &&
                                binsof(feature_wb_signals_high.all_high);

      bins all_high_range_4_7 = binsof(feature_wb_sel_i_range.range_4_7) &&
                                binsof(feature_wb_signals_high.all_high);

      bins all_high_range_8_11 = binsof(feature_wb_sel_i_range.range_8_11) &&
                                binsof(feature_wb_signals_high.all_high);

      bins all_high_range_12_15 = binsof(feature_wb_sel_i_range.range_12_15) &&
                                  binsof(feature_wb_signals_high.all_high);
    }
  endgroup
  

  covergroup cov_cfg_sdr_trcar_d; 
    feature_cfg_sdr_trcar_d: coverpoint vif.cfg_sdr_trcar_d {
      bins range_1_7 = {[1:7]};
      bins range_8_14 = {[8:14]};
      bins range_15 = {15};
    }
  endgroup

  covergroup cov_cfg_sdr_trp_d;
    feature_cfg_sdr_trp_d: coverpoint vif.cfg_sdr_trp_d {
      bins range_1_7 = {[1:7]};
      bins range_8_14 = {[8:14]};
      bins range_15 = {15};
    }
  endgroup

  covergroup cov_cfg_sdr_rfmax; 
    feature_cfg_sdr_rfmax: coverpoint vif.cfg_sdr_rfmax {
      bins range_1_3 = {[1:3]};
      bins range_4_7 = {[4:7]};
    }
  endgroup
  
  covergroup cov_reset_initdone;
    feature_reset_initdone: coverpoint vif.RESETN {
      bins reset_0 = {0};
      bins reset_1 = {1};
    }

    feature_initdone: coverpoint top_hdl.u_dut.sdr_init_done {
      bins init_0 = {0};
      bins init_1 = {1};
    }

    feature_RESETN_coverage: cross feature_reset_initdone, feature_initdone {
      bins reset_0_init_0 = binsof(feature_reset_initdone.reset_0) && binsof(feature_initdone.init_0);
      bins reset_1_init_1 = binsof(feature_reset_initdone.reset_1) && binsof(feature_initdone.init_1);
    }
  endgroup

  /*********************************/
  /*-------- Report Phase ---------*/
  /*********************************/
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    $display("COV Wishbone Write Signals: %3.2f%% coverage achieved (Burst write operation in SDRAM controller).", cov_wishbone_write.cross_wb_signals_write.get_coverage());
    $display("COV Wishbone Read Signals: %3.2f%% coverage achieved (Burst read operation in SDRAM controller).", cov_wishbone_read.cross_wb_signals_read.get_coverage());
    $display("COV Column Bits Configuration: %3.2f%% coverage achieved (Support SDRAM with four bank).", cov_col_bits.cross_cfg_bank.get_coverage());
    $display("COV Chip Select Signals: %3.2f%% coverage achieved (One chip-select signals).", cov_chip_select.cross_chip_select_signals.get_coverage()); 
    $display("COV Write Address Range: %3.2f%% coverage achieved (Full memory read operation in SDRAM controller - print_memory_contents).", cov_write_address.cross_we_addr.get_coverage());
    $display("COV Read Address Range: %3.2f%% coverage achieved (Full memory write operation in SDRAM controller).", cov_read_address.cross_we_addr.get_coverage());
    $display("COV Wishbone Select Range: %3.2f%% coverage achieved (Data mask signals for partial write operations).", cov_sel_range.feature_wb_sel_i.get_coverage());
    $display("COV cfg_sdr_trcar_d (0-20): %3.2f%% coverage achieved (Automatic controlled refresh).", cov_cfg_sdr_trcar_d.feature_cfg_sdr_trcar_d.get_coverage());
    $display("COV cfg_sdr_trp_d (0-20): %3.2f%% coverage achieved (Automatic controlled refresh).", cov_cfg_sdr_trp_d.feature_cfg_sdr_trp_d.get_coverage());
    $display("COV cfg_sdr_rfmax (1-15): %3.2f%% coverage achieved (Automatic controlled refresh).", cov_cfg_sdr_rfmax.feature_cfg_sdr_rfmax.get_coverage());

    $display("Overall Coverage for Configurations coverage achieved (CAS Latency): %3.2f%% (CAS latency)", 
             (cov_sdr_config.cross_cfg_023_2_read.get_coverage() + cov_sdr_config.cross_cfg_033_3_read.get_coverage()) / 2.0);
    $display("COV Reset and Initdone: %3.2f%% coverage achieved (Reset).", cov_reset_initdone.feature_RESETN_coverage.get_coverage());
  endfunction
endclass
