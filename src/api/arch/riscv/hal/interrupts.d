/**
 * Authors: initkfs
 */
module api.arch.riscv.hal.interrupts;

import Externs = api.arch.riscv.hal.externs;
import Platform = api.arch.riscv.hal.platform;

enum clintBase = Platform.clintBase;
enum clintCompareRegHurtOffset = Platform.clintCompareRegHurtOffset;
enum clintTimerRegOffset = Platform.clintTimerRegOffset;
enum clintMtimecmpSize = Platform.clintMtimecmpSize;
enum numCores = Platform.numCores;

//MPP (Machine Previous Privilege)
enum MSTATUS_MPP_MASK = (3 << 11);
enum MSTATUS_MPP_M = (3 << 11); //Machine mode
enum MSTATUS_MPP_S = (1 << 11); //Supervisor mode.
enum MSTATUS_MPP_U = (0 << 11); //User mode

enum MSTATUS_MPRV  = (1 << 17);  // Modify Privilege
enum MSTATUS_TW    = (1 << 21);  // Trap WFI: ban WFI в S/U-mode
enum MSTATUS_TVM   = (1 << 20);  // Trap Virtual Memory

//FPU
enum MSTATUS_FS    = (3 << 13);  // Floating-Point Status (0=off, 1=initial, 2=clean, 3=dirty)
enum MSTATUS_XS    = (3 << 15);  // Extension Status (custom extensions)

//Machine Interrupt Enable
enum MSTATUS_MIE = (1 << 3);

// External Interrupt
enum MIE_MEIE = (1 << 11);
// Timer Interrupt
enum MIE_MTIE = (1 << 7);
// Software Interrupt
enum MIE_MSIE = (1 << 3);

enum MIE_SSIE = (1 << 1);  // Software Interrupt (local)
enum MIE_STIE = (1 << 5);  // Timer Interrupt (local)
//MIE_FastInt0 = (1 << 16);  //Fast interrupts in SiFive

ulong mTimeRegCmpAddr(size_t hartid) @trusted
{
    return clintBase + clintCompareRegHurtOffset + clintMtimecmpSize * hartid;
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
    // uint64_t value;
    //#if __riscv_xlen == 32
    //    value = csr_read("mstatus");
    //    value |= ((uint64_t)csr_read("mstatush")) << 32;
    //#else
    //    value = csr_read("mstatus");
    //#endif
    //return value;
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
