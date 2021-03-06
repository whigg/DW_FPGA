//Test a single coef memory write/read

pcie_coef_addr      = 'h0;
pcie_coef_addr.sel  = 'h45;
pcie_coef_addr.addr = 'h123;
test_data_wr        = 64'h321;


pcie_write(COEF_BAR_START,
	   pcie_coef_addr,
	   test_data_wr,
	   clk_input,
	   bus_pcie_wr);

pcie_read (COEF_BAR_START,
	   pcie_coef_addr,
	   test_data_rd,
	   clk_input,
	   bus_pcie_req,
	   pcie_bus_rd);

if (test_data_rd !== test_data_wr) begin
   $error("***** :( TEST FAILED :( *****\n Read does not match write at addr %0x\n expect %0x got %0x",
	  pcie_coef_addr,test_data_wr,test_data_rd);
	  bad_fail = bad_fail + 1;
end else begin
   $display("***:) YES! PASSED coef_wrrd :)***");
end




