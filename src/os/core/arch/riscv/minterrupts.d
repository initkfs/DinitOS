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

ulong timeRegCmpAddr(size_t hartid)
{
    return clintBase + clintCompareRegHurtOffset + numCores * hartid;
}

ulong time()
{
    return clintBase + clintTimerRegOffset;
}

size_t status()
{
    return Externs.m_get_status;
}

void status(size_t status)
{
    Externs.m_set_status(status);
}

void exceptionCounter(size_t c)
{
    Externs.m_set_exception_counter(c);
}

size_t exceptionCounter()
{
    return Externs.m_get_exception_counter;
}

void scratch(size_t value)
{
    Externs.m_set_scratch(value);
}

void interruptVector(size_t value)
{
    return Externs.m_set_interrupt_vector(value);
}

size_t interruptIsEnable()
{
    return Externs.m_get_interrupt_enable;
}

void interruptIsEnable(size_t value)
{
    Externs.m_set_interrupt_enable(value);
}

void disableMInterrupts()
{
    interruptIsEnable(~((~interruptIsEnable) | MIE_MTIE));
}

void enableMInterrupts()
{
    interruptIsEnable(interruptIsEnable | MIE_MTIE);
}
