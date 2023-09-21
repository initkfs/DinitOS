/**
 * Authors: initkfs
 */
module timer;

import interrupt;
import uart;

enum interval = 20000000;
__gshared TimerScratch[maxCpu] timerMscratchs;

struct TimerScratch {
    align(1):
    //timervec
    size_t[3] saveRegisters;
    size_t clintCmpRegister;
    size_t interval;
}

void timerInit()
{
    size_t id = get_hart_id();

    writeIntevalToTimer(id);

    TimerScratch* scratch = &timerMscratchs[id];
    //TODO or 64-bit timer register?
    scratch.clintCmpRegister = cast(size_t) mtimecmpForHart(id);
    scratch.interval = interval;
    set_mscratch(cast(size_t) scratch.saveRegisters.ptr);

    set_minterrupt_enable(get_minterrupt_enable | MIE_MTIE);
}

extern(C) size_t timer_handler(size_t epc, size_t cause)
{
    //disable interrupts.
    //setMInterruptEnable(~((~getMInterruptEnable) | (1 << 7)));

    auto id = get_hart_id();
    writeIntevalToTimer(id);

    // enable interrupts.
    //setMInterruptEnable(getMInterruptEnable | MIE_MTIE);

    println("Timer handler");

    return epc;
}

private void writeIntevalToTimer(size_t hartId)
{
    ulong* mtimeCmpPtr = cast(ulong*) mtimecmpForHart(hartId);
    ulong currTimeValue = *(cast(ulong*) mtime());
    *mtimeCmpPtr = currTimeValue + interval;
}
