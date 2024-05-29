/**
 * Authors: initkfs
 */
module os.core.timer;

import os.core.io.cstdio;

import Harts = os.core.arch.riscv.harts;
import Interrupts = os.core.arch.riscv.interrupts;
import Syslog = os.core.log.syslog;

enum interval = 20000000;
__gshared TimerScratch[Interrupts.numCores] timerMscratchs;

struct TimerScratch {
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

    TimerScratch* scratch = &timerMscratchs[id];
    //TODO or 64-bit timer register?
    scratch.clintCmpRegister = cast(size_t) Interrupts.timeRegCmpAddr(id);
    scratch.interval = interval;
    Interrupts.scratch(cast(size_t) scratch.saveRegisters.ptr);

    Interrupts.interruptIsEnable(Interrupts.interruptIsEnable | Interrupts.MIE_MTIE);
}

extern(C) size_t timer_handler(size_t epc, size_t cause)
{
    Interrupts.disableMInterrupts;

    auto id = Harts.mhartId();
    writeIntevalToTimer(id);

    Interrupts.enableMInterrupts;

    Syslog.trace("Call timer handler");

    return epc;
}

private void writeIntevalToTimer(size_t mhartId)
{
    ulong* mtimeCmpPtr = cast(ulong*) Interrupts.timeRegCmpAddr(mhartId);
    ulong currTimeValue = *(cast(ulong*) Interrupts.time());
    *mtimeCmpPtr = currTimeValue + interval;
}
