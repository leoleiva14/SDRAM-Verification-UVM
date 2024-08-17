`define DUV_PATH top_hdl

module whitebox();
 
  /*****************************************/
  /*----- Property Check Read Command -----*/
  /*****************************************/
  property check_read_command;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.sdr_init_done)
    (`DUV_PATH.vif.sdr_cas_n == 0 && `DUV_PATH.vif.sdr_ras_n == 1 && `DUV_PATH.vif.sdr_we_n == 1) |-> (
      (`DUV_PATH.vif.cfg_sdr_mode_reg == 13'h023 && `DUV_PATH.vif.cfg_sdr_cas == 3'h2) ##1 (`DUV_PATH.Dq !== 'hzzzzzzzz) or
      (`DUV_PATH.vif.cfg_sdr_mode_reg == 13'h033 && `DUV_PATH.vif.cfg_sdr_cas == 3'h3) ##2 (`DUV_PATH.Dq !== 'hzzzzzzzz)
    );
  endproperty
  
  /*******************************************/
  /*--- Property Check Chip Select Signal ---*/
  /*******************************************/
  property check_chip_select_signal;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.sdr_init_done)
      (`DUV_PATH.vif.sdr_cs_n == 1) |-> (`DUV_PATH.vif.sdr_cas_n == 1 && `DUV_PATH.vif.sdr_ras_n == 1 && `DUV_PATH.vif.sdr_we_n == 1);
  endproperty
  
  /********************************************/
  /*- Property Check Reset and Init Done ----*/
  /********************************************/
  property check_resetn_sdr_init_done;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.sdr_init_done)
      (`DUV_PATH.vif.RESETN == 0 && `DUV_PATH.sdr_init_done == 1) |-> 0;
  endproperty

  /********************************************/
  /*--------------- Assertions ---------------*/
  /********************************************/
  assert_check_read_command: assert property (check_read_command)
    else begin
      $display("Error: No se recibió dato en Dq después de los ciclos de espera");
      $display("Valores de señales en el fallo:");
      $display("cfg_sdr_mode_reg: %h", `DUV_PATH.vif.cfg_sdr_mode_reg);
      $display("cfg_sdr_cas: %h", `DUV_PATH.vif.cfg_sdr_cas);
      $display("Dq: %h", `DUV_PATH.Dq);
            $fatal("Error fatal: No se recibió dato en Dq después de los ciclos de espera");
    end

  assert_check_chip_select_signal: assert property (check_chip_select_signal)
  	else begin
      $display("Error: Señal de selección de chip (sdr_cs_n) no se activó correctamente");
      $display("Valores de señales en el fallo:");
      $display("sdr_cs_n: %b", `DUV_PATH.vif.sdr_cs_n);
      $display("sdr_cas_n: %b", `DUV_PATH.vif.sdr_cas_n);
      $display("sdr_ras_n: %b", `DUV_PATH.vif.sdr_ras_n);
      $display("sdr_we_n: %b", `DUV_PATH.vif.sdr_we_n);
          $fatal("Error fatal: Señal de selección de chip (sdr_cs_n) no se activó correctamente");
    end
    
  assert_check_resetn_sdr_init_done: assert property (check_resetn_sdr_init_done)
    else begin
      $display("Error: RESETN es 0 y sdr_init_done es 1, lo cual es un estado inválido.");
      $fatal("Error fatal: RESETN es 0 y sdr_init_done es 1.");
  end
endmodule