/**
 * Authors: initkfs
 */
module trap;

import interrupt;
import uart;
import task;
import timer;

extern (C) void setMInterruptVectorTrap();

void trapInit()
{
    setMInterruptVectorTrap();

    setMStatus(getMStatus() | MSTATUS_MIE);
}

extern (C) size_t trapHandler(size_t epc, size_t cause)
{
    auto retPc = epc;
    auto cause_code = cause & 0xfff;

    if (cause & 0x80000000)
    {
        /* Asynchronous trap - interrupt */
        switch (cause_code)
        {
        case 3:
            println("Software interruption.");
            break;
        case 7:
            println("Timer interruption.");

            // disable timer interrupts.
            setMInterruptEnable(~((~getMInterruptEnable) | (1 << 7)));
            timerHandler(epc, cause);
            retPc = cast(size_t) &switchContextToOs;
            // enable timer interrupts.
            setMInterruptEnable(getMInterruptEnable | MIE_MTIE);
            break;
        case 11:
            println("External interruption.");
            break;
        default:
            println("Unknown asynchronous exception.");
            break;
        }
    }
    else
    {
        println("Synchronous exception.");
        while (true)
        {
        }
    }
    return retPc;
}
