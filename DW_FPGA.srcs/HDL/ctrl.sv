// Module to control the 16 runs

module ctrl
  (sys,	  
   pcie_ctrl_wr,
   ctrl_rnd,
   ctrl_coef,
   ctrl_pick
   );

`include "params.svh"
`include "structs.svh"
      
   input   sys_s     sys;
   input   pcie_wr_s pcie_ctrl_wr;
   
   output  ctrl_rnd_s  ctrl_rnd;
   output  ctrl_coef_s ctrl_coef;
   output  ctrl_pick_s ctrl_pick;
   
   reg [MAX_RUN_BITS:0] run;
   reg [MAX_RUN:0]      step;
 
   reg [MAX_RUN:0]    ram_we;
   reg [MAX_CTRL_WORD_S:0] ram_data;
   reg [9:0] 		   ram_addr;
   

   wire[MAX_RUN:0]      ctrl_busy;

   ctrl_word_s          ctrl_word [0:MAX_RUN];
   pcie_ctrl_data_s     pcie_ctrl_data;
   
   
   integer              i;
   genvar 		gi;
   
   always@(posedge sys.clk or posedge sys.reset) begin
      if (sys.reset) begin
	 ram_we         <= 'b0;
	 ram_addr       <= 'b0;
	 ram_data       <= 'b0;
	 pcie_ctrl_data <= 'b0;
	 
      end else begin
	 if (pcie_ctrl_wr.vld) begin
	    if (pcie_ctrl_wr.addr[MAX_RUN_BITS+11] == 1'b0) begin
	       if (MAX_CTRL_WORD_S > 63) begin
		  if (pcie_ctrl_wr.addr[0] == 1'b1) begin
		     ram_data[MAX_CTRL_WORD_S:64] 
			   <= pcie_ctrl_wr.data[MAX_CTRL_WORD_S-64:0];
		  end else begin
		     ram_data[63:0] 
			   <= pcie_ctrl_wr.data[63:0];
		  end
	       end else begin
		  ram_data  <= pcie_ctrl_wr.data[MAX_CTRL_WORD_S:0];
	       end // else: !if((MAX_CTRL_WORD_S > 63))
	       ram_addr  <= pcie_ctrl_wr.addr[9:0];
	       ram_we[pcie_ctrl_wr.addr[MAX_RUN_BITS+10:10]] <= 1'b1;
	    end else begin
	       ram_we   <= 'b0;
	       pcie_ctrl_data <= pcie_ctrl_wr.data[MAX_PCIE_CTRL_DATA:0];
	    end // else: !if(pcie_ctrl_wr.addr[MAX_RUN_BITS+11] == 1'b0)
	 end else begin // if (pcie_ctrl_wr.vld)
	    ram_we <= 1'b0;
	    pcie_ctrl_data.start  <= pcie_ctrl_data.start & ~ctrl_busy;
	    pcie_ctrl_data.stop   <= 'b0;
	 end // else: !if(pcie_ctrl_wr.vld)
      end // else: !if(sys.reset)
   end // always@ (posedge sys.clk or posedge sys.reset)
      
   always@(posedge sys.clk or posedge sys.reset) begin
      if (sys.reset) begin
	 run   <= 'b0;
	 step <= 'b0;
      end else begin
	 if (run == MAX_RUN) begin
	    run   <= 'b0;
	    step <= 'b1;
	 end else begin
	    run   <= run + 1;
	    step <= step << 1'b1;
	 end
      end
   end // always@ (posedge sys.clk or posedge sys.reset)

generate
   for (gi=0;gi<=MAX_RUN;gi=gi+1) begin : CTRL_RAM
      
      ctrl_onerun ctrl_onerun_0
	  (
	   .sys(sys),
	   .ram_we(ram_we[gi]),
	   .ram_addr(ram_addr),
	   .ram_data(ram_data),
	   .start(pcie_ctrl_data.start[gi]),
	   .stop(pcie_ctrl_data.stop[gi]),
	   .step(step[gi]),
	   
	   .ctrl_word(ctrl_word[gi]),
	   .ctrl_busy(ctrl_busy[gi])
	   );
   end
endgenerate

   always@(posedge sys.clk or posedge sys.reset) begin
      if (sys.reset) begin
	 ctrl_rnd  <= 'b0;
	 ctrl_pick <= 'b0;
      end else begin
	 ctrl_rnd.init <= pcie_ctrl_data.init;
	 ctrl_rnd.en   <= ctrl_busy[run];
	 ctrl_rnd.run  <= run;
	 ctrl_rnd.flips <= ctrl_word[run].flips;

	 ctrl_pick.init             <= pcie_ctrl_data.init;
	 ctrl_pick.temperature[run] <= ctrl_word[run].temperature;
	 ctrl_pick.offset[run]      <= ctrl_word[run].offset;

	 ctrl_coef.init             <= pcie_ctrl_data.init;
	 ctrl_coef.en               <= ctrl_busy[run];
	 ctrl_coef.active           <= ((|pcie_ctrl_data.start) | 
					(|ctrl_busy));
	 
      end // else: !if(sys.reset)
   end // always@ (posedge sys.clk or posedge sys.reset)
   	 
endmodule // ctrl


   
 
 