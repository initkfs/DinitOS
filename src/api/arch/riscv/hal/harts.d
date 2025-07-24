/**
 * Authors: initkfs
 */
module api.arch.riscv.hal.harts;

import Externs = api.arch.riscv.hal.externs;

size_t mhartId() @trusted
{
    return Externs.m_get_hart_id;
}
