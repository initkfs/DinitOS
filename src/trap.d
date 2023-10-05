/**
 * Authors: initkfs
 */
module trap;

import interrupt;
import uart;
import task;
import timer;

extern (C) void set_minterrupt_vector_trap();

void trapInit()
{
    set_minterrupt_vector_trap();

    set_mstatus(get_mstatus() | MSTATUS_MIE);
}

extern (C) size_t trap_handler(size_t epc, size_t cause)
{
    auto retPc = epc;
    auto cause_code = cause & 0xfff;

    if (cause << (size_t.sizeof * 8 - 1))
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
            set_minterrupt_enable(~((~get_minterrupt_enable) | (1 << 7)));
            timer_handler(epc, cause);
            retPc = cast(size_t) &switchContextToOs;
            // enable timer interrupts.
            set_minterrupt_enable(get_minterrupt_enable | MIE_MTIE);
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
        println("Synchronous exception. Stopping the system.");
        while (true)
        {
        }
    }
    return retPc;
}
