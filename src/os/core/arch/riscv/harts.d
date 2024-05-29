/**
 * Authors: initkfs
 */
module os.core.arch.riscv.harts;

import Externs = os.core.arch.riscv.externs;

size_t mhartId()
{
    return Externs.m_get_hart_id;
}
