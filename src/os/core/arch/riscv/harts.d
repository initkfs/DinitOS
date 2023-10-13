/**
 * Authors: initkfs
 */
module os.core.arch.riscv.harts;

version (Riscv32)
    version = Riscv;
else version (Riscv64)
    version = Riscv;

//dfmt off
version (Riscv): 
//dfmt on

import ldc.llvmasm;

size_t hartId()
{
    size_t id = __asm!size_t("csrr $0, mhartid", "=r");
    return id;
}
