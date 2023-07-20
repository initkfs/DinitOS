/**
 * Authors: initkfs
 */
module timer;

import interrupt;

enum interval = 10_000_000;

void timerInit()
{
    size_t id = getHartId();

    writeIntevalToTimer(id);

    setMInterruptVectorTimer();

    setMStatus(getMStatus() | MSTATUS_MIE);
    setMInterruptEnable(getMInterruptEnable | MIE_MTIE);
}

extern (C) size_t timerHandler(size_t epc, size_t cause)
{
    //disable interrupts.
    setMInterruptEnable(~((~getMInterruptEnable) | (1 << 7)));

    import uart;

    auto id = getHartId();
    writeIntevalToTimer(id);

    // enable interrupts.
    setMInterruptEnable(getMInterruptEnable | MIE_MTIE);

    println("Timer handler");

    return epc;
}

private void writeIntevalToTimer(size_t hartId){
    ulong* mtimeCmpPtr = cast(ulong*) mtimecmpForHart(hartId);
    ulong currTimeValue = *(cast(ulong*) mtime());
    *mtimeCmpPtr = currTimeValue + interval;
}
