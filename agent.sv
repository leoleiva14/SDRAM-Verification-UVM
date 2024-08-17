//****************************************
//----- Active SDRAM Agent Class --------
//****************************************
class sdram_agent_active extends uvm_agent;
  `uvm_component_utils(sdram_agent_active)

  /**********************************/
  /*--------- Constructor ----------*/
  /**********************************/
  function new(string name = "sdram_agent_active", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  /**********************************/
  /*------ Member Variables --------*/
  /**********************************/
  virtual interface_bus_master vif;
  sdram_driver sdram_drv;
  uvm_sequencer #(sdram_item) sdram_seqr;
  sdram_monitor_w sdram_mntr_w;
  sdram_scoreboard sb;

  /**********************************/
  /*------- Build Phase ------------*/
  /**********************************/
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end

    sdram_drv = sdram_driver::type_id::create("sdram_drv", this);
    sdram_seqr = uvm_sequencer#(sdram_item)::type_id::create("sdram_seqr", this);
    sdram_mntr_w = sdram_monitor_w::type_id::create("sdram_mntr_w", this);
    sb = sdram_scoreboard::type_id::create("sb", this);

    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.sdram_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  /**********************************/
  /*------- Connect Phase ----------*/
  /**********************************/
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    sdram_drv.seq_item_port.connect(sdram_seqr.seq_item_export);
    sdram_drv.vif = vif;
    sdram_mntr_w.vif = vif;
  endfunction

endclass

//****************************************/
//----- Passive SDRAM Agent Class --------/
//****************************************/
class sdram_agent_passive extends uvm_agent;
  `uvm_component_utils(sdram_agent_passive)

  /**********************************/
  /*--------- Constructor ----------*/
  /**********************************/
  function new(string name="sdram_agent_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  /**********************************/
  /*------ Member Variables --------*/
  /**********************************/
  virtual interface_bus_master vif;
  sdram_monitor_r sdram_mntr_r;
  sdram_monitor_autorefresh sdram_mntr_autrorfrsh;

  /**********************************/
  /*------- Build Phase ------------*/
  /**********************************/
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end

    sdram_mntr_r = sdram_monitor_r::type_id::create("sdram_mntr_r", this);
    sdram_mntr_autrorfrsh = sdram_monitor_autorefresh::type_id::create("sdram_mntr_autrorfrsh", this);

    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.sdram_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  /**********************************/
  /*------- Connect Phase ----------*/
  /**********************************/
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass
