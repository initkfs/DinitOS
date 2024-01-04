/**
 * Authors: initkfs
 */
module os.core.arch.riscv.harts;

import ldc.llvmasm;

size_t hartId()
{
    size_t id = __asm!size_t("csrr $0, mhartid", "=r");
    return id;
}
