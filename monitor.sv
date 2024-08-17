class sdram_monitor extends uvm_monitor;
  `uvm_component_utils(sdram_monitor)

  /*********************************/
  /*------- General Signals -------*/
  /*********************************/
  virtual interface_bus_master vif;
  bit enable_check = 0;
  bit enable_coverage = 0;
  uvm_analysis_port #(sdram_item) mon_analysis_port;

  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    mon_analysis_port = new("mon_analysis_port", this);

    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
       `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
  endfunction

  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
  endtask   
endclass

class sdram_monitor_w extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_w)

  /*********************************/
  /*--------- Constructor ---------*/
  /*********************************/
  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  /*********************************/
  /*---------- Run Phase ----------*/
  /*********************************/
  virtual task run_phase (uvm_phase phase);
    sdram_item data_obj = sdram_item::type_id::create("data_obj", this);

    forever begin
      @(posedge vif.sys_clk);
      if (vif.wb_stb_i == 1 && vif.wb_cyc_i == 1 && vif.wb_we_i == 1 && vif.wb_ack_o == 1'b1) begin
        data_obj = sdram_item::type_id::create("data_obj", this);
        data_obj.Address = vif.wb_addr_i;
        data_obj.writte = vif.wb_dat_i;
        data_obj.command = 1;
        data_obj.wb_mask = vif.wb_sel_i;
        mon_analysis_port.write(data_obj);
      end
    end
  endtask
endclass

class sdram_monitor_r extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_r)

  /*********************************/
  /*--------- Constructor ---------*/
  /*********************************/
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
  endfunction

  /*********************************/
  /*---------- Run Phase ----------*/
  /*********************************/
  virtual task run_phase (uvm_phase phase);
    sdram_item data_obj = sdram_item::type_id::create("data_obj", this);
    forever begin
      @(posedge vif.sys_clk);
      if (vif.wb_stb_i == 1 && vif.wb_cyc_i == 1 && vif.wb_we_i == 0 && vif.wb_ack_o == 1'b1) begin
        data_obj = sdram_item::type_id::create("data_obj", this);
        data_obj.Address = vif.wb_addr_i;
        data_obj.writte = vif.wb_dat_o;
        data_obj.command = 0;
        mon_analysis_port.write(data_obj);
      end
    end
  endtask
endclass


class sdram_monitor_autorefresh extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_autorefresh)

  /*********************************/
  /*--------- Constructor ---------*/
  /*********************************/
  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  /*********************************/
  /*---------- Run Phase ----------*/
  /*********************************/
  virtual task run_phase(uvm_phase phase);
    int cycle_count_tRP;
    int cycle_count_tRC;
    int cycle_count_tRFSH;
    int total_command_count;
    bit command_detected_tRP;
    bit command_detected_tRC;
    bit command_detected_tRFSH;
    sdram_item data_obj = sdram_item::type_id::create("data_obj", this);

    cycle_count_tRP = 0;
    cycle_count_tRC = 0;
    cycle_count_tRFSH = 0;
    total_command_count = 0;
    command_detected_tRP = 0;
    command_detected_tRC = 0;
    command_detected_tRFSH = 0;

    super.run_phase(phase);

    forever begin
      @(posedge vif.sdram_clk);

      // tRP: Ciclos entre `vif.sdr_we_n == 0 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 1` y `vif.sdr_we_n == 1 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 0`
      if (vif.sdr_we_n == 0 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 1) begin
        command_detected_tRP = 1;
        cycle_count_tRP = 0;
      end else if (command_detected_tRP && vif.sdr_we_n == 1 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 0) begin
        data_obj = sdram_item::type_id::create("data_obj", this);
        data_obj.cycle_count_tRP = cycle_count_tRP;
        data_obj.total_command_count = -1;
        data_obj.cycle_count_tRC = -1;
        data_obj.active_found = -1;
        data_obj.cfg_sdr_trp_d = vif.cfg_sdr_trp_d;
        data_obj.cfg_sdr_trcar_d = vif.cfg_sdr_trcar_d;
        data_obj.cfg_sdr_rfmax = vif.cfg_sdr_rfmax;
        mon_analysis_port.write(data_obj);
        command_detected_tRP = 0;
      end else if (command_detected_tRP) begin
        cycle_count_tRP++;
      end

      // tRC: Ciclos entre activaciones consecutivas de `vif.sdr_we_n == 1 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 0`
      if (vif.sdr_we_n == 1 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 0) begin
        if (command_detected_tRC) begin
          data_obj = sdram_item::type_id::create("data_obj", this);
          data_obj.cycle_count_tRC = cycle_count_tRC;
          data_obj.cycle_count_tRP = -1;
          data_obj.total_command_count = -1;
          data_obj.active_found = -1;
          data_obj.cfg_sdr_trp_d = vif.cfg_sdr_trp_d;
          data_obj.cfg_sdr_trcar_d = vif.cfg_sdr_trcar_d;
          data_obj.cfg_sdr_rfmax = vif.cfg_sdr_rfmax;
          mon_analysis_port.write(data_obj);
          cycle_count_tRC = 0;
        end else begin
          command_detected_tRC = 1;
          cycle_count_tRC = 0;
        end
      end else if (command_detected_tRC) begin
        cycle_count_tRC++;
      end

      // tRFSH: Ciclos desde `vif.sdr_we_n == 0 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 1` hasta `vif.sdr_we_n == 1 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 1`
      if (!command_detected_tRFSH && vif.sdr_we_n == 0 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 1) begin
        command_detected_tRFSH = 1;
        total_command_count = 0;
      end else if (command_detected_tRFSH && vif.sdr_we_n == 1 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 1) begin
        data_obj = sdram_item::type_id::create("data_obj", this);
        data_obj.cycle_count_tRC = total_command_count;
        data_obj.active_found = 1;
        data_obj.cycle_count_tRP = -1;
        data_obj.cycle_count_tRC = -1;
        data_obj.cfg_sdr_trp_d = vif.cfg_sdr_trp_d;
        data_obj.cfg_sdr_trcar_d = vif.cfg_sdr_trcar_d;
        data_obj.cfg_sdr_rfmax = vif.cfg_sdr_rfmax;
        mon_analysis_port.write(data_obj);
        command_detected_tRFSH = 0;
      end else if (command_detected_tRFSH && vif.sdr_we_n == 0 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 1) begin
        data_obj.cycle_count_tRC = -1;
        data_obj.active_found = 0;
        data_obj.cycle_count_tRP = -1;
        data_obj.cycle_count_tRC = -1;
        mon_analysis_port.write(data_obj);
        command_detected_tRP = 0;
        command_detected_tRC = 0;
        command_detected_tRFSH = 0;
      end

      if (command_detected_tRFSH && vif.sdr_we_n == 1 && vif.sdr_ras_n == 0 && vif.sdr_cas_n == 0) begin
        total_command_count++;
      end
    end
  endtask
endclass
