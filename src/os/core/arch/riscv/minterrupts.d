/**
 * Authors: initkfs
 */
module os.core.arch.riscv.minterrupts;

import ldc.llvmasm;

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
    size_t id = __asm!size_t("csrr a0, mstatus", "=r");
    return id;
}

void status(size_t status)
{
    __asm("csrw mstatus, a0", "r", status);
}

void exceptionCounter(size_t c)
{
    __asm("csrw mepc, $0", "r", c);
}

size_t exceptionCounter()
{
    size_t counter = __asm!size_t("csrr $0, mepc", "=r");
    return counter;
}

void scratch(size_t value)
{
    __asm("csrw mscratch, $0", "r", value);
}

void interruptVector(size_t value)
{
    __asm("csrw mtvec, $0", "r", value);
}

size_t interruptIsEnable()
{
    return __asm!size_t("csrr $0, mie", "=r");
}

void interruptIsEnable(size_t value)
{
    __asm("csrw mie, $0", "r", value);
}

void disableMInterrupts()
{
    interruptIsEnable(~((~interruptIsEnable) | MIE_MTIE));
}

void enableMInterrupts()
{
    interruptIsEnable(interruptIsEnable | MIE_MTIE);
}
