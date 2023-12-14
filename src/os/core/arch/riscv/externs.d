/**
 * Authors: initkfs
 */
module os.core.arch.riscv.externs;

version (Riscv32)
    version = Riscv;
else version (Riscv64)
    version = Riscv;

//dfmt off
version (Riscv): 
//dfmt on

extern (C) void set_minterrupt_vector_timer();