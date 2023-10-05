/**
 * Authors: initkfs
 */
module os.core.arch.riscv.interrupts;

version (Riscv32)
    version = Riscv;
else version (Riscv64)
    version = Riscv;

//dfmt off
version (Riscv): 
//dfmt on

import ldc.llvmasm;

version (Qemu)
{
    import Qemu = os.core.dev.qemu;

    enum clintBase = Qemu.clintBase;
    enum clintCompareRegHurtOffset = Qemu.clintCompareRegHurtOffset;
    enum clintTimerRegOffset = Qemu.clintTimerRegOffset;
    enum numCores = Qemu.numCores;
}

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

ulong mtimecmpForHart(size_t hartid)
{
    return clintBase + clintCompareRegHurtOffset + numCores * (hartid);
}

ulong mtime()
{
    return clintBase + clintTimerRegOffset;
}

size_t getMStatus()
{
    size_t id = __asm!size_t("csrr a0, mstatus", "=r");
    return id;
}

void setMStatus(size_t status)
{
    __asm("csrw mstatus, a0", "r", status);
}

void setExceptionCounter(size_t c)
{
    __asm("csrw mepc, $0", "r", c);
}

size_t getExceptionCounter()
{
    size_t counter = __asm!size_t("csrr $0, mepc", "=r");
    return counter;
}

void setMscratch(size_t value)
{
    __asm("csrw mscratch, $0", "r", value);
}

void setMinterruptVector(size_t value)
{
    __asm("csrw mtvec, $0", "r", value);
}

size_t getMinterruptEnable()
{
    return __asm!size_t("csrr $0, mie", "=r");
}

void setMinterruptEnable(size_t value)
{
    __asm("csrw mie, $0", "r", value);
}

extern (C) void set_minterrupt_vector_timer();

void disableInterrupts()
{
    setMinterruptEnable(~((~getMinterruptEnable) | MIE_MTIE));
}

void enableInterrupts()
{
    setMinterruptEnable(getMinterruptEnable | MIE_MTIE);
}
