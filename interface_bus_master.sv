/*********************************/
/*-------- General Signals ------*/
/*********************************/
interface interface_bus_master(input logic sys_clk, input logic sdram_clk);

  logic RESETN;
  logic wb_clk_i;

  /*********************************/
  /*------ Wishbone Signals -------*/
  /*********************************/
  logic wb_stb_i;
  logic wb_ack_o;
  logic wb_we_i;
  logic [31:0] wb_addr_i;
  logic [31:0] wb_dat_i;
  logic [31:0] wb_dat_o;
  logic [3:0] wb_sel_i;
  logic wb_cyc_i;
  logic [2:0] wb_cti_i;

  /******************************************/
  /*-- Configuration Cas Latency Signals ---*/
  /******************************************/
  logic [11:0] cfg_sdr_mode_reg;
  logic [2:0]  cfg_sdr_cas;
  
  /******************************************/
  /*----- Automatic controlled refresh -----*/
  /******************************************/
  logic [3:0]     cfg_sdr_trp_d;
  logic [3:0]     cfg_sdr_trcar_d;
  logic [2:0]     cfg_sdr_rfmax;

  /******************************************/
  /*----- Configuration Bank Signals -------*/
  /******************************************/
  logic [1:0] cfg_col_bits;

  /******************************************/
  /*------ SDRAM External Signals ----------*/
  /******************************************/
  logic sdr_ras_n;
  logic sdr_cas_n;
  logic sdr_we_n;
  logic sdr_cs_n;

endinterface : interface_bus_master
