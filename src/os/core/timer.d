/**
 * Authors: initkfs
 */
module os.core.timer;

import os.core.cstd.io.cstdio;

import Harts = os.core.arch.riscv.harts;
import Interrupts = os.core.arch.riscv.minterrupts;

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
    size_t id = Harts.hartId();

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

    auto id = Harts.hartId();
    writeIntevalToTimer(id);

    Interrupts.enableMInterrupts;

    println("Timer handler");

    return epc;
}

private void writeIntevalToTimer(size_t hartId)
{
    ulong* mtimeCmpPtr = cast(ulong*) Interrupts.timeRegCmpAddr(hartId);
    ulong currTimeValue = *(cast(ulong*) Interrupts.time());
    *mtimeCmpPtr = currTimeValue + interval;
}
