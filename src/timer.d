/**
 * Authors: initkfs
 */
module timer;

import interrupt;
import uart;

import Harts = os.core.arch.riscv.harts;
import Interrupts = os.core.arch.riscv.interrupts;

enum interval = 20000000;
__gshared TimerScratch[numCores] timerMscratchs;

struct TimerScratch {
    align(1):
    //timervec
    size_t[3] saveRegisters;
    size_t clintCmpRegister;
    size_t interval;
}

void timerInit()
{
    size_t id = Harts.getHartId();

    writeIntevalToTimer(id);

    TimerScratch* scratch = &timerMscratchs[id];
    //TODO or 64-bit timer register?
    scratch.clintCmpRegister = cast(size_t) mtimecmpForHart(id);
    scratch.interval = interval;
    Interrupts.setMscratch(cast(size_t) scratch.saveRegisters.ptr);

    Interrupts.setMinterruptEnable(Interrupts.getMinterruptEnable | MIE_MTIE);
}

extern(C) size_t timer_handler(size_t epc, size_t cause)
{
    Interrupts.disableInterrupts;

    auto id = Harts.getHartId();
    writeIntevalToTimer(id);

    Interrupts.enableInterrupts;

    println("Timer handler");

    return epc;
}

private void writeIntevalToTimer(size_t hartId)
{
    ulong* mtimeCmpPtr = cast(ulong*) mtimecmpForHart(hartId);
    ulong currTimeValue = *(cast(ulong*) mtime());
    *mtimeCmpPtr = currTimeValue + interval;
}
