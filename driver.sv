//*************************************************
//------ Transactional Item Class (sdram_item) ------
//*************************************************
class sdram_item extends uvm_sequence_item;
  `uvm_object_utils_begin(sdram_item)
  `uvm_field_int(writte, UVM_ALL_ON)
  `uvm_field_int(bl, UVM_ALL_ON)
  `uvm_field_int(amount_times, UVM_ALL_ON)
  `uvm_field_int(Address, UVM_ALL_ON)
  `uvm_field_int(Address_for_verify_bank, UVM_ALL_ON)
  `uvm_field_int(command, UVM_ALL_ON)
  `uvm_field_int(cas, UVM_ALL_ON)
  `uvm_field_int(delay, UVM_ALL_ON)
  `uvm_field_int(iterations, UVM_ALL_ON)
  `uvm_field_int(iteration_write, UVM_ALL_ON)
  `uvm_field_int(iteration_read, UVM_ALL_ON)
  `uvm_field_int(bank, UVM_ALL_ON)
  `uvm_field_int(row, UVM_ALL_ON)
  `uvm_field_int(column1, UVM_ALL_ON)
  `uvm_field_int(column2, UVM_ALL_ON)
  `uvm_field_int(column3, UVM_ALL_ON)
  `uvm_field_int(column4, UVM_ALL_ON)
  `uvm_field_sarray_int(address_history, UVM_ALL_ON)
  `uvm_field_int(predicted_address, UVM_ALL_ON)
  `uvm_field_int(cycle_count_tRP, UVM_ALL_ON)
  `uvm_field_int(cycle_count_tRC, UVM_ALL_ON)
  `uvm_field_int(total_command_count, UVM_ALL_ON)
  `uvm_field_int(active_found, UVM_ALL_ON)
  `uvm_field_int(wb_mask, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "sdram_item");
    super.new(name);
  endfunction

  /**********************************/
  /*-------- Member Variables -------*/
  /**********************************/
  bit active_found;
  int cycle_count_tRP = 0;
  int cycle_count_tRC = 0;
  int total_command_count = 0;

  randc bit [31:0] writte;
  rand bit [7:0] bl;
  randc bit [7:0] amount_times;
  rand bit [31:0] Address;
  rand bit [31:0] Address_for_verify_bank;
  rand bit [1:0] command;
  rand bit [1:0] cas;
  rand bit [7:0] delay;
  rand bit [3:0] iterations;
  rand bit [2:0] iteration_write;
  rand bit [2:0] iteration_read;
  rand bit [1:0] bank;
  rand bit [11:0] row;
  rand bit [7:0] column1;
  rand bit [8:0] column2;
  rand bit [9:0] column3;
  rand bit [10:0] column4;
  rand bit [3:0] cfg_sdr_trp_d;
  rand bit [3:0] cfg_sdr_trcar_d;
  rand bit [2:0] cfg_sdr_rfmax;
  rand bit [3:0] wb_mask;

  bit [31:0] address_history [0:31];
  bit [31:0] predicted_address;

  /**********************************/
  /*-------- Constraints -----------*/
  /**********************************/
  constraint bl_c { bl >= 8 && bl <= 15; }
  constraint amount_times_c { amount_times inside {[1:255]}; }
  constraint command_c { command inside {0, 1, 2}; }
  constraint cas_c {cas inside {0, 1};}
  constraint delay_c { delay inside {[1:255]}; }
  constraint iterations_c { iterations inside {1, 2, 3, 4}; }
  constraint address_c {
    Address inside {
      [32'h00000000 : 32'h000000C7], // Primeras 200 direcciones
      [32'h1FFFFF38 : 32'h200000BF], // Direcciones en la mitad de la memoria (rango de 200 direcciones)
      [32'h3FFFFF38 : 32'h400000BF], // Direcciones al 75% de la memoria (rango de 200 direcciones)
      [32'h7FFFFF38 : 32'h800000BF]  // Últimas 200 direcciones
    };
  }
  constraint address_for_verify_bank_c { Address_for_verify_bank inside {[32'h00000000 : 32'hFFFFFFFF]}; }
  constraint bank_c { bank inside {[0:3]}; }
  constraint row_c { row inside {[0:4095]}; }
  constraint column1_c { column1 inside {[0:255]}; }
  constraint column2_c { column2 inside {[0:511]}; }
  constraint column3_c { column3 inside {[0:1023]}; }
  constraint column4_c { column4 inside {[0:2047]}; }
  constraint cfg_sdr_trp_d_c { cfg_sdr_trp_d inside {[1:15]}; }
  constraint cfg_sdr_trcar_d_c { cfg_sdr_trcar_d inside {[1:15]}; }
  constraint cfg_sdr_rfmax_c { cfg_sdr_rfmax inside {[1:7]}; }
  constraint mask_c { wb_mask inside {[0:15]}; }
endclass

//****************************************/
//----- Sequence Class (gen_item_seq) ----/
//****************************************/
class gen_item_seq extends uvm_sequence #(sdram_item);
  `uvm_object_utils(gen_item_seq)

  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  /***********************************/
  /*-------- Random Variables -------*/
  /***********************************/
  rand int num;
  constraint c1 { num inside {[2:5]}; }

  /**********************************/
  /*----------- Body Task ----------*/
  /**********************************/
  virtual task body();
    for (int i = 0; i < num; i++) begin
      sdram_item f_item = sdram_item::type_id::create("f_item");

      start_item(f_item);
      f_item.randomize();
      `uvm_info("SEQ", $sformatf("Generate new item: command = %0d, address = %h", f_item.command, f_item.Address), UVM_LOW)
      f_item.print();
      finish_item(f_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass

//****************************************/
//--------- Driver Class (sdram_driver) ----/
//****************************************/
class sdram_driver extends uvm_driver #(sdram_item);
  `uvm_component_utils(sdram_driver)

  uvm_analysis_port #(sdram_item) analysis_port;

  function new (string name = "sdram_driver", uvm_component parent = null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  virtual interface_bus_master vif;

  /**********************************/
  /*-------- Build Phase -----------*/
  /**********************************/
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif)) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  /**********************************/
  /*-------- Run Phase -------------*/
  /**********************************/
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      sdram_item f_item;
      `uvm_info("DRV", $sformatf("Esperando ítem del secuenciador"), UVM_LOW)
      seq_item_port.get_next_item(f_item);
      auto_refresh(f_item);
      cas_latency(f_item.cas);
      reset();

      if (f_item.command == 0) begin
        burst_write(f_item);
      end else if (f_item.command == 1) begin
        burst_read(f_item.Address);
      end else if (f_item.command == 2) begin
        mask_burst(f_item);
      end

      analysis_port.write(f_item);
      seq_item_port.item_done();
    end
  endtask

  /**********************************/
  /*--------- Tasks ----------------*/
  /**********************************/	
  virtual task reset();
    vif.cfg_col_bits   = 2'b00;
    vif.sdr_cs_n       = 0;
    vif.wb_addr_i      = 0;
    vif.wb_dat_i       = 0;
    vif.wb_sel_i       = 4'h0;
    vif.wb_we_i        = 1;
    vif.wb_stb_i       = 0;
    vif.wb_cyc_i       = 0;
    vif.RESETN         = 1'h1;
    #100
    vif.RESETN         = 1'h0;
    #10000;
    vif.RESETN         = 1'h1;
    #1000;
    wait(top_hdl.u_dut.sdr_init_done == 1);
    #1000;
    `uvm_info("DRV", "Se aplicó el RESET", UVM_LOW)
  endtask

  virtual task burst_write(sdram_item f_item);
    int i;
    int timeout_counter;
    $display("Inicio de la tarea burst_write");
    @ (negedge vif.sys_clk);
    for (i = 0; i < f_item.bl; i++) begin
      vif.cfg_col_bits = 2'b00;
      vif.wb_stb_i = 1;
      vif.wb_cyc_i = 1;
      vif.wb_we_i = 1;
      vif.wb_sel_i = 4'b1111;
      vif.wb_addr_i = {f_item.Address[31:2] + i, 2'b00};
      $display("Activadas las señales del bus.");
      vif.wb_dat_i = f_item.writte;
      f_item.writte += 100;
      do begin
        @(posedge vif.sys_clk);
        timeout_counter++;
        if (timeout_counter > 100) begin
          `uvm_fatal("ACK_TIMEOUT", "Timeout waiting for burst_write to go high");
          break;
        end
      end while (vif.wb_ack_o == 1'b0);
      @(negedge vif.sys_clk);
      $display("Número de ráfaga: %d, Dirección de escritura: %h, Dato escrito: %h", i, vif.wb_addr_i, vif.wb_dat_i);
      timeout_counter = 0;
    end
    vif.wb_stb_i = 0;
    vif.wb_cyc_i = 0;
    vif.wb_we_i = 'hx;
    vif.wb_sel_i = 'hx;
    vif.wb_addr_i = 'hx;
    vif.wb_dat_i = 'hx;
    $display("Finalizado el proceso de escritura.");
  endtask

  virtual task burst_read(bit[31:0] address);
    int j;
    int timeout_counter;
    $display("Inicio de la tarea burst_read.");
    for (j = 0; j < 16; j++) begin
      vif.cfg_col_bits = 2'b00;
      vif.wb_stb_i = 1;
      vif.wb_cyc_i = 1;
      vif.wb_we_i = 0;
      vif.wb_addr_i = address + (j * 4);
      $display("Activadas las señales del bus.");
      do begin
        @(posedge vif.sys_clk);
        timeout_counter++;
        if (timeout_counter > 100) begin
          `uvm_fatal("ACK_TIMEOUT", "Timeout waiting for burst_read to go high");
          break;
        end
      end while (vif.wb_ack_o == 1'b0);
      $display("Número de ráfaga: %d, ACK recibido para dirección %h, Dato recibido: %h", j, vif.wb_addr_i, vif.wb_dat_o);
      @(negedge vif.sys_clk);
      timeout_counter = 0;
    end
    vif.wb_stb_i = 0;
    vif.wb_cyc_i = 0;
    vif.wb_we_i = 'hx;
    vif.wb_addr_i = 'hx;
    $display("Finalizado el proceso de lectura.");
  endtask
  
virtual task print_memory_contents();
    int address;
    bit [31:0] address_ranges[4][2] = '{ // Definición de los rangos de direcciones
      '{32'h00000000, 32'h000000C7}, // Primeras 63 direcciones
      '{32'h1FFFFF38, 32'h200000BF}, // Direcciones en la mitad de la memoria
      '{32'h3FFFFF38, 32'h400000BF}, // Direcciones al 75% de la memoria
      '{32'h7FFFFF38, 32'h800000BF}  // Últimas 63 direcciones
    };
    $display("Inicio de la tarea print_memory_contents."); // Registrar el inicio de la tarea de impresión de la memoria.

    // Iterar sobre los rangos de direcciones
    for (int range = 0; range < 4; range++) begin
        $display("Leyendo rango: %h a %h", address_ranges[range][0], address_ranges[range][1]);
        for (address = address_ranges[range][0]; address <= address_ranges[range][1]; address += 4) begin
            vif.cfg_col_bits = 2'b00; // Configurar col_bits, si es necesario
            vif.wb_stb_i = 1; // Afirmar el strobe.
            vif.wb_cyc_i = 1; // Afirmar el ciclo.
            vif.wb_we_i = 0; // Habilitador de escritura en bajo para lectura.
            vif.wb_addr_i = address; // Establecer la dirección.

            do begin
                @ (posedge vif.sys_clk);
            end while (vif.wb_ack_o == 1'b0); // Esperar por la confirmación.

            // Imprimir siempre el dato leído
            $display("Dirección: %h, Dato leído: %h", address, vif.wb_dat_o);

            @(negedge vif.sdram_clk);
        end
    end

    vif.wb_stb_i = 0; // Desafirmar el strobe.
    vif.wb_cyc_i = 0; // Desafirmar el ciclo.
    vif.wb_we_i = 'hx; // Estado de alta impedancia.
    vif.wb_addr_i = 'hx; // Estado de alta impedancia.

    $display("Finalizado el proceso de lectura de la memoria.");
  endtask

  virtual task cas_latency(input bit[1:0] cas);
    if (cas == 0) begin
      vif.cfg_sdr_mode_reg = 13'h023;
      vif.cfg_sdr_cas = 3'h2;
      uvm_report_info("CAS_LATENCY", $sformatf("CAS latency configured to 2. Mode register: %h, CAS: %h", vif.cfg_sdr_mode_reg, vif.cfg_sdr_cas), UVM_LOW);
    end else begin
      vif.cfg_sdr_mode_reg = 13'h033;
      vif.cfg_sdr_cas = 3'h3;
      uvm_report_info("CAS_LATENCY", $sformatf("CAS latency configured to 3. Mode register: %h, CAS: %h", vif.cfg_sdr_mode_reg, vif.cfg_sdr_cas), UVM_LOW);
    end
  endtask

  virtual task verify_sdram_four_bank_support();
    int write_count;
    int read_count;
    int i;
    bit [31:0] address_history1 [0:31];
    bit [31:0] predicted_address1 [0:31];
    sdram_item f_item;

  $display("----------------------------------------VERIFY: Iniciando la verificación de soporte de SDRAM con cuatro bancos.----------------------------------------");
    for (int cfg = 0; cfg < 4; cfg++) begin
      vif.cfg_col_bits = cfg;
      $display("CONFIG: cfg_col_bits = %02b", vif.cfg_col_bits);
      write_count = 0;
      read_count = 0;

      for (i = 0; i < 32; i++) begin
        f_item = sdram_item::type_id::create("f_item");
        assert(f_item.randomize());
        case (vif.cfg_col_bits)
          2'b00: f_item.predicted_address = {f_item.row, f_item.bank, 4'h0, f_item.column1};
          2'b01: f_item.predicted_address = {f_item.row, f_item.bank, 3'h0, f_item.column2};
          2'b10: f_item.predicted_address = {f_item.row, f_item.bank, 2'h0, f_item.column3};
          2'b11: f_item.predicted_address = {f_item.row, f_item.bank, 1'h0, f_item.column4};
          default: f_item.predicted_address = 32'h0;
        endcase
       
        if (write_count < 16) begin
          $display("WRITE: Escribiendo en dirección: %h", f_item.predicted_address);
          write(f_item);
          address_history1[write_count] = f_item.predicted_address;
          predicted_address1[write_count] = f_item.predicted_address;
          write_count++;
        end else if (read_count < 16) begin
          $display("READ: Leyendo de dirección: %h", address_history1[read_count]);
          read(address_history1[read_count]);
          read_count++;
        end
      end

      for (i = 0; i < 16; i++) begin
        if (address_history1[i] !== predicted_address1[i]) begin
          $display("ERROR: Error en la dirección DDR: Predicha %h, Actual %h", predicted_address1[i], address_history1[i]);
        end else begin
          $display("DDR_ADDR: Dirección DDR verificada correctamente: %h vs %h", address_history1[i], predicted_address1[i]);
        end
      end
    end
  endtask

  virtual task write(sdram_item f_item);
    int i;
    $display("Inicio de la tarea burst_write");
    @ (negedge vif.sys_clk);
    for (i = 0; i < 1; i++) begin
      vif.wb_stb_i = 1;
      vif.wb_cyc_i = 1;
      vif.wb_we_i = 1;
      vif.wb_sel_i = 4'b1111;
      vif.wb_addr_i = f_item.predicted_address;
      vif.wb_dat_i = f_item.writte;
      f_item.writte += 100;
      do begin
        @(posedge vif.sys_clk);
      end while (vif.wb_ack_o == 1'b0);
      @(negedge vif.sys_clk);
    end
    vif.wb_stb_i = 0;
    vif.wb_cyc_i = 0;
    vif.wb_we_i = 'hx;
    vif.wb_sel_i = 'hx;
    vif.wb_addr_i = 'hx;
    vif.wb_dat_i = 'hx;
    $display("Finalizado el proceso de escritura.");
  endtask

  virtual task read(bit[31:0] address);
    int j;
    $display("Inicio de la tarea burst_read.");
    for (j = 0; j < 1; j++) begin
      vif.wb_stb_i = 1;
      vif.wb_cyc_i = 1;
      vif.wb_we_i = 0;
      vif.wb_addr_i = address;
      do begin
        @ (posedge vif.sys_clk);
      end while (vif.wb_ack_o == 1'b0);
      @(negedge vif.sdram_clk);
    end
    vif.wb_stb_i = 0;
    vif.wb_cyc_i = 0;
    vif.wb_we_i = 'hx;
    vif.wb_addr_i = 'hx;
    $display("Finalizado el proceso de lectura.");
  endtask

  virtual task auto_refresh(sdram_item f_item);
    vif.cfg_sdr_trp_d = f_item.cfg_sdr_trp_d;
    vif.cfg_sdr_trcar_d = f_item.cfg_sdr_trcar_d;
    $display(f_item.cfg_sdr_rfmax);
    if (f_item.cfg_sdr_rfmax == 0) begin
      vif.cfg_sdr_rfmax = 1;
    end else begin
      vif.cfg_sdr_rfmax = f_item.cfg_sdr_rfmax;
    end
    `uvm_info("AUTO_REFRESH", $sformatf("Auto-refresh configurations set: cfg_sdr_trp_d = %0d, cfg_sdr_trcar_d = %0d, cfg_sdr_rfmax = %0d", 
               vif.cfg_sdr_trp_d, vif.cfg_sdr_trcar_d, vif.cfg_sdr_rfmax), UVM_LOW)
  endtask

  virtual task mask_burst(sdram_item f_item);
    int i;
    int timeout_counter = 0;
    $display("Inicio de la tarea burst_write mask");
    @ (negedge vif.sys_clk);
    for (i = 0; i < f_item.bl; i++) begin
      vif.wb_stb_i = 1;
      vif.wb_cyc_i = 1;
      vif.wb_we_i = 1;
      vif.wb_sel_i = f_item.wb_mask;
      `uvm_info("WB_SEL", $sformatf("wb_sel_i: %b", vif.wb_sel_i), UVM_LOW)
      vif.wb_addr_i = {f_item.Address[31:2] + i, 2'b00};
      vif.wb_dat_i = f_item.writte;
      f_item.writte += 100;
      do begin
        @(posedge vif.sys_clk);
        timeout_counter++;
        if (timeout_counter > 100) begin
          `uvm_fatal("ACK_TIMEOUT", "Timeout waiting for wb_ack_o to go high");
          break;
        end
      end while (vif.wb_ack_o == 1'b0);
      @(negedge vif.sys_clk);
      $display("Número de ráfaga: %d, Dirección de escritura: %h, Dato escrito: %h", i, vif.wb_addr_i, vif.wb_dat_i);
      timeout_counter = 0;
    end
    vif.wb_stb_i = 0;
    vif.wb_cyc_i = 0;
    vif.wb_we_i = 'hx;
    vif.wb_sel_i = 'hx;
    vif.wb_addr_i = 'hx;
    vif.wb_dat_i = 'hx;
    $display("Finalizado el proceso de escritura con mask.");
  endtask
  
  
  
  virtual task write1();
    int address;
    int writte;
   
    
    bit [31:0] address_ranges[4][2] = '{ // Definición de los rangos de direcciones
      '{32'h00000000, 32'h000000C7}, // Primeras 63 direcciones
      '{32'h1FFFFF38, 32'h200000BF}, // Direcciones en la mitad de la memoria
      '{32'h3FFFFF38, 32'h400000BF}, // Direcciones al 75% de la memoria
      '{32'h7FFFFF38, 32'h800000BF}  // Últimas 63 direcciones
    };
    $display("Write in  memory."); // Registrar el inicio de la tarea de impresión de la memoria.

    // Iterar sobre los rangos de direcciones
    writte=0;
    for (int range = 0; range < 4; range++) begin
      $display("Escribiendo rango: %h a %h", address_ranges[range][0], address_ranges[range][1]);
        for (address = address_ranges[range][0]; address <= address_ranges[range][1]; address += 4) begin
            vif.cfg_col_bits = 2'b00; // Configurar col_bits, si es necesario
            vif.wb_stb_i = 1; // Afirmar el strobe.
            vif.wb_cyc_i = 1; // Afirmar el ciclo.
            vif.wb_we_i = 1; // Habilitador de escritura en bajo para lectura.
            vif.wb_addr_i = address; // Establecer la dirección.
          
            vif.wb_dat_i = writte;
            writte += 100;

            do begin
                @ (posedge vif.sys_clk);
            end while (vif.wb_ack_o == 1'b0); // Esperar por la confirmación.

            // Imprimir siempre el dato leído
          $display("Dirección: %h, Dato escrito: %h", address, vif.wb_dat_i);

            @(negedge vif.sdram_clk);
        end
    end

    vif.wb_stb_i = 0; // Desafirmar el strobe.
    vif.wb_cyc_i = 0; // Desafirmar el ciclo.
    vif.wb_we_i = 'hx; // Estado de alta impedancia.
    vif.wb_addr_i = 'hx; // Estado de alta impedancia.

    $display("Finalizado el proceso de escritura de la memoria.");
  endtask

endclass
