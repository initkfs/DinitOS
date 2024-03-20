/**
 * Authors: initkfs
 */
module os.core.trap;

import Interrupts = os.core.arch.riscv.minterrupts;

import os.core.io.cstdio;
import os.core.thread.task;
import os.core.timer;

import Syslog = os.core.log.syslog;

extern (C) void set_minterrupt_vector_trap();

void trapInit()
{
    set_minterrupt_vector_trap();

    Interrupts.status(Interrupts.status | Interrupts.MSTATUS_MIE);
}

extern (C) size_t trap_handler(size_t epc, size_t cause)
{
    auto retPc = epc;
    auto causeCode = cause & 0x7f_ff_ff_ff;

    enum exceptionBitMask = 1uL << (size_t.sizeof * 8 - 1);

    const isInterrupt = cause & exceptionBitMask;
    if (isInterrupt)
    {
        //Asynchronous handler
        switch (causeCode)
        {
            case 0:
                Syslog.trace("User software interrupt");
                break;
            case 1:
                Syslog.trace("Supervisor software interrupt");
                break;
            case 3:
                Syslog.trace("Machine software interrupt.");
                break;
            case 4:
                Syslog.trace("User timer interrupt.");
                break;
            case 5:
                Syslog.trace("Supervisor timer interrupt.");
                break;
            case 7:
                Syslog.trace("Machine timer interrupt.");

                // disable timer interrupts.
                Interrupts.interruptIsEnable(
                    ~((~Interrupts.interruptIsEnable) | Interrupts.MIE_MTIE));
                timer_handler(epc, cause);
                retPc = cast(size_t)&switchTasks;
                // enable timer interrupts.
                Interrupts.interruptIsEnable(Interrupts.interruptIsEnable | Interrupts.MIE_MTIE);
                break;
            case 8:
                Syslog.trace("User external interrupt.");
                break;
            case 9:
                Syslog.trace("Supervisor external interrupt.");
                break;
            case 11:
                Syslog.trace("Machine external interrupt.");
                break;
            default:
                Syslog.trace("Unknown interrupt.");
                break;
        }
    }
    else
    {
        switch (causeCode)
        {
            case 0:
                println("Instruction address misaligned.");
                break;
            case 1:
                println("Instruction access fault.");
                break;
            case 2:
                println("Illegal instruction.");
                break;
            case 3:
                println("Breakpoint.");
                break;
            case 4:
                println("Load address misaligned.");
                break;
            case 5:
                println("Load access fault.");
                break;
            case 6:
                println("Store/AMO address misaligned.");
                break;
            case 7:
                println("Store/AMO access fault.");
                break;
            case 8:
                println("Environment call from U-mode.");
                break;
            case 9:
                println("Environment call from S-mode.");
                break;
            case 11:
                println("Environment call from M-mode.");
                break;
            case 12:
                println("Instruction page fault.");
                break;
            case 13:
                println("Load page fault.");
                break;
            case 15:
                println("Store/AMO page fault.");
                break;
            default:
                println("Unknown synchronous exception.");
                break;
        }

        // while (true)
        // {
        // }
    }
    return retPc;
}
