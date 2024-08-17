//****************************************
//-------- Environment Class (sdram_env) ---
//****************************************
class sdram_env extends uvm_env;
  `uvm_component_utils(sdram_env)

  /**********************************/
  /*--------- Constructor ----------*/
  /**********************************/
  function new (string name = "sdram_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  /**********************************/
  /*------ Member Variables --------*/
  /**********************************/
  virtual interface_bus_master vif;
  sdram_agent_active sdram_ag_active;
  sdram_agent_passive sdram_ag_passive;
  sdram_scoreboard sb;
  funct_coverage cov;

  /**********************************/
  /*------- Build Phase ------------*/
  /**********************************/
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end

    sdram_ag_active = sdram_agent_active::type_id::create("sdram_ag_active", this);
    sdram_ag_passive = sdram_agent_passive::type_id::create("sdram_ag_passive", this);
    sb = sdram_scoreboard::type_id::create("sb", this);
    cov = funct_coverage::type_id::create("cov", this);

    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
    print();
  endfunction

  /**********************************/
  /*------- Connect Phase ----------*/
  /**********************************/
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    sdram_ag_passive.sdram_mntr_r.mon_analysis_port.connect(sb.sb_mon);
    sdram_ag_active.sdram_mntr_w.mon_analysis_port.connect(sb.sb_drv);
    sdram_ag_passive.sdram_mntr_autrorfrsh.mon_analysis_port.connect(sb.sb_autorfs_mon);
  endfunction

endclass
