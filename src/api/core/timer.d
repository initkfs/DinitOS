/**
 * Authors: initkfs
 */
module api.core.timer;

import api.core.io.cstdio;

version (RiscvGeneric)
{
    import Harts = api.arch.riscv.hal.harts;
    import Interrupts = api.arch.riscv.hal.interrupts;
}
else
{
    static assert(false, "Not supported platform");
}

import Syslog = api.core.log.syslog;

enum interval = 20000000;
__gshared TimerScratch[Interrupts.numCores] timerMscratchs;

struct TimerScratch
{
align(1):
    //timervec
    size_t[3] saveRegisters;
    size_t clintCmpRegister;
    size_t interval;
}

void timerInit()
{
    size_t id = Harts.mhartId();

    writeIntevalToTimer(id);

    TimerScratch* mScratch = &timerMscratchs[id];
    //TODO or 64-bit timer register?
    mScratch.clintCmpRegister = cast(size_t) Interrupts.mTimeRegCmpAddr(id);
    mScratch.interval = interval;
    Interrupts.mScratch(cast(size_t) mScratch.saveRegisters.ptr);

    Interrupts.mInterruptIsEnable(Interrupts.mInterruptIsEnable | Interrupts.MIE_MTIE);
}

extern (C) size_t timer_handler(size_t epc, size_t cause)
{
    Interrupts.mInterruptsDisable;

    auto id = Harts.mhartId();
    writeIntevalToTimer(id);

    Interrupts.mInterruptsEnable;

    Syslog.trace("Call timer handler");

    return epc;
}

private void writeIntevalToTimer(size_t mhartId)
{
    ulong* mtimeCmpPtr = cast(ulong*) Interrupts.mTimeRegCmpAddr(mhartId);
    ulong currTimeValue = *(cast(ulong*) Interrupts.mTime());
    *mtimeCmpPtr = currTimeValue + interval;
}
