#Assigns each memory coef mem location to an array
#so it is easier to acess


set rootDir [get_property DIRECTORY [current_project]]
set hdlDir $rootDir/[lindex [file split $rootDir] end].srcs/SIM

set f1 [open "$hdlDir/poke_cmem.svh" w]
puts $f1 "// Assign ram poke locations for easy access"
puts $f1 "// Generated by ../tcl/gen_pokes.tcl\n"
puts $f1 "// Run in vivado (tcl console (source /your/path/to/tcl/gen_poke.tcl))\n"
puts $f1 "task automatic poke_cmem ("
puts $f1 "   input reg \[CMEM_DATA_W:0\] coef_mem \[0:NCMEMS-1\] \[0:NCMEM_ADDRS-1\]\);\n"

puts $f1 "   for (i=0;i<NCMEM_ADDRS;i++) begin : poke_cmem"
for {set i 0} {$i<512} {set i [expr $i+1]} {
    puts $f1 "      sim_top.top_0.coef_0.\\cmem\[$i\].coef_mem_0 .inst.\\native_mem_module.blk_mem_gen_v8_3_3_inst .memory\[i\]"
    puts $f1 "              = coef_mem\[$i\] \[i\];"
}

puts $f1 "   end"
puts $f1 "endtask"

close $f1
