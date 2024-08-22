/**
 * Authors: initkfs
 */
module api.core.arch.riscv.harts;

import Externs = api.core.arch.riscv.externs;

size_t mhartId() @trusted
{
    return Externs.m_get_hart_id;
}
