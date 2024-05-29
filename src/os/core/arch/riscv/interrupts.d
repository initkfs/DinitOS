/**
 * Authors: initkfs
 */
module os.core.arch.riscv.interrupts;

import Externs = os.core.arch.riscv.externs;
import Platform = os.core.arch.riscv.platform;

enum clintBase = Platform.clintBase;
enum clintCompareRegHurtOffset = Platform.clintCompareRegHurtOffset;
enum clintTimerRegOffset = Platform.clintTimerRegOffset;
enum numCores = Platform.numCores;

enum MSTATUS_MPP_MASK = (3 << 11);
enum MSTATUS_MPP_M = (3 << 11);
enum MSTATUS_MPP_S = (1 << 11);
enum MSTATUS_MPP_U = (0 << 11);
enum MSTATUS_MIE = (1 << 3);

// external
enum MIE_MEIE = (1 << 11);
// timer
enum MIE_MTIE = (1 << 7);
// software
enum MIE_MSIE = (1 << 3);

ulong mTimeRegCmpAddr(size_t hartid) @trusted
{
    return clintBase + clintCompareRegHurtOffset + numCores * hartid;
}

ulong mTime() @trusted
{
    return clintBase + clintTimerRegOffset;
}

size_t mStatus() @trusted
{
    return Externs.m_get_status;
}

void mStatus(size_t status) @trusted
{
    Externs.m_set_status(status);
}

void mExceptionCounter(size_t c) @trusted
{
    Externs.m_set_exception_counter(c);
}

size_t mExceptionCounter() @trusted
{
    return Externs.m_get_exception_counter;
}

void mScratch(size_t value) @trusted
{
    Externs.m_set_scratch(value);
}

void mInterruptVector(size_t value) @trusted
{
    return Externs.m_set_interrupt_vector(value);
}

size_t mInterruptIsEnable() @trusted
{
    return Externs.m_get_interrupt_enable;
}

void mInterruptIsEnable(size_t value) @trusted
{
    Externs.m_set_interrupt_enable(value);
}

void mInterruptsDisable() @trusted
{
    mInterruptIsEnable(~((~mInterruptIsEnable) | MIE_MTIE));
}

void mInterruptsEnable() @trusted
{
    mInterruptIsEnable(mInterruptIsEnable | MIE_MTIE);
}
