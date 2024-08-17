`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_autorfs_mon)

class sdram_scoreboard extends uvm_component;
  `uvm_component_utils(sdram_scoreboard)

  /*********************************/
  /*--------- Constructor ---------*/
  /*********************************/
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  /*********************************/
  /*----- Analysis Ports -----------*/
  /*********************************/
  uvm_analysis_imp_drv #(sdram_item, sdram_scoreboard) sb_drv;
  uvm_analysis_imp_mon #(sdram_item, sdram_scoreboard) sb_mon;
  uvm_analysis_imp_autorfs_mon #(sdram_item, sdram_scoreboard) sb_autorfs_mon;

  /*********************************/
  /*------- Build Phase -----------*/
  /*********************************/
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_drv = new("sb_drv", this);
    sb_mon = new("sb_mon", this);
    sb_autorfs_mon = new("sb_autorfs_mon", this);
  endfunction

  /*********************************/
  /*------- Data Structure --------*/
  /*********************************/
  typedef struct {
    bit [31:0] address;
    bit [31:0] data;
    bit write_enable;
    bit [3:0] wb_sel_i;
  } data_t;

  data_t dict[bit[31:0]];

  /*********************************/
  /*----- Entry Management --------*/
  /*********************************/
  function void add_entry(bit[31:0] id, bit[31:0] address, bit [31:0] data, bit write_enable, bit [3:0] wb_sel_i);
    data_t new_data;
    new_data.address = address;
    new_data.data = data;
    new_data.write_enable = write_enable;
    new_data.wb_sel_i = wb_sel_i;
    dict[id] = new_data;
    `uvm_info("SCOREBOARD", $sformatf("Adding Entry - ID %h: Address: %h, Data: %h, Write Enable: %b, wb_sel_i: %b", id, address, new_data.data, write_enable, wb_sel_i), UVM_LOW)
  endfunction

  function bit find_entry(bit[31:0] id, output bit[31:0] address, output bit[31:0] data, output bit write_enable, output bit [3:0] wb_sel_i);
    if (dict.exists(id)) begin
      address = dict[id].address;
      data = dict[id].data;
      write_enable = dict[id].write_enable;
      wb_sel_i = dict[id].wb_sel_i;
      return 1;
    end else begin
      return 0;
    end
  endfunction

  /***********************************/
  /*------- Utility Functions -------*/
  /***********************************/
  function bit [31:0] apply_mask(bit [31:0] data, bit [3:0] wb_sel_i);
    bit [31:0] masked_data;
    int i;
    masked_data = 32'bx;
    for (i = 0; i < 4; i++) begin
      if (wb_sel_i[i] == 1) begin
        masked_data[(i*8) +: 8] = data[(i*8) +: 8];
      end else begin
        masked_data[(i*8) +: 8] = 8'bx;
      end
    end
    return masked_data;
  endfunction

  function void iterate();
    foreach(dict[id]) begin
      `uvm_info("SCOREBOARD", $sformatf("ID: %h, Address: %h, Data: %h, Write Enable: %b", id, dict[id].address, dict[id].data, dict[id].write_enable), UVM_LOW)
    end
  endfunction

  /*********************************/
  /*------ Write Functions --------*/
  /*********************************/
  function void write_drv(sdram_item t);
    add_entry(t.Address, t.Address, t.writte, t.command, t.wb_mask);
    //iterate();
  endfunction

  function void write_mon(sdram_item t);
    bit [31:0] addr;
    bit [31:0] dat;
    bit        we;
    bit [3:0] wb_sel_i;
    bit [31:0] masked_data;

    if (find_entry(t.Address, addr, dat, we, wb_sel_i)) begin
      masked_data = apply_mask(dat, wb_sel_i);

      if (wb_sel_i == 4'b1111) begin
        if (addr == t.Address && dat == t.writte) begin
          `uvm_info("SCOREBOARD", $sformatf("Entry matches - Passed - Address: %h, Data: %h", addr, dat), UVM_LOW)
        end else begin
          `uvm_error("SCOREBOARD", $sformatf("Entry does not match - Failed - Address: %h, Expected Data: %h, Actual Data: %h", addr, t.writte, dat))
        end
      end else begin
        if (addr == t.Address && masked_data == t.writte) begin
          `uvm_info("SCOREBOARD", $sformatf("Mask applied correctly - Passed"), UVM_LOW)
        end else begin
          `uvm_error("SCOREBOARD", $sformatf("Mask not applied correctly - Failed"))
        end
      end
    end else if (t.writte != 32'hXXXXXXXX) begin
      `uvm_error("SCOREBOARD", $sformatf("Entry not found and entry_no does not match expected value - Failed - entry_no: %h", t.writte))
    end
  endfunction
  
  function void write_autorfs_mon(sdram_item t);
    // Verify cycle_count_tRP
    if (t.cycle_count_tRP != -1) begin
      if (t.cycle_count_tRP >= t.cfg_sdr_trp_d && t.cycle_count_tRP <= t.cfg_sdr_trp_d + 3) begin
        `uvm_info("SCOREBOARD", $sformatf("PASS - cycle_count_tRP: Recibido: %0d, Esperado: %0d a %0d", t.cycle_count_tRP, t.cfg_sdr_trp_d, t.cfg_sdr_trp_d + 3), UVM_LOW)
      end else begin
        `uvm_warning("SCOREBOARD", $sformatf("FAIL - cycle_count_tRP: Recibido: %0d, Esperado: %0d a %0d", t.cycle_count_tRP, t.cfg_sdr_trp_d, t.cfg_sdr_trp_d + 3))
      end
    end

    // Verify cycle_count_tRC
    if (t.cycle_count_tRC != -1) begin
      if (t.cycle_count_tRC >= t.cfg_sdr_trcar_d && t.cycle_count_tRC <= t.cfg_sdr_trcar_d + 3) begin
        `uvm_info("SCOREBOARD", $sformatf("PASS - cycle_count_tRC: Recibido: %0d, Esperado: %0d a %0d", t.cycle_count_tRC, t.cfg_sdr_trcar_d, t.cfg_sdr_trcar_d + 3), UVM_LOW)
      end else begin
        `uvm_warning("SCOREBOARD", $sformatf("FAIL - cycle_count_tRC: Recibido: %0d, Esperado: %0d a %0d", t.cycle_count_tRC, t.cfg_sdr_trcar_d, t.cfg_sdr_trcar_d + 3))
      end
    end

    // Verify total_command_count only if active_found is 1
    if (t.active_found == 1 && t.total_command_count != -1 && t.total_command_count != 0) begin
      if (t.total_command_count == t.cfg_sdr_rfmax) begin
        `uvm_info("SCOREBOARD", $sformatf("PASS - total_command_count: Recibido: %0d, Esperado: %0d", t.total_command_count, t.cfg_sdr_rfmax), UVM_LOW)
      end else begin
        `uvm_warning("SCOREBOARD", $sformatf("FAIL - total_command_count: Recibido: %0d, Esperado: %0d", t.total_command_count, t.cfg_sdr_rfmax))
      end
    end else if (t.active_found == 0) begin
      `uvm_warning("SCOREBOARD", "FAIL - active_found is not set to 1, indicating a logic failure.")
    end
  endfunction
endclass
