/**
 * Authors: initkfs
 */
module api.core.trap;

version (RiscvGeneric)
{
    import Interrupts = api.arch.riscv.hal.interrupts;
}
else
{
    static assert(false, "Not supported platform");
}

import api.core.io.cstdio;
import api.core.thread.task;
import api.core.timer;

import Syslog = api.core.log.syslog;

extern (C) void set_minterrupt_vector_trap();

void trapInit()
{
    set_minterrupt_vector_trap();

    Interrupts.mStatus(Interrupts.mStatus | Interrupts.MSTATUS_MIE);
}

extern (C) size_t trap_handler(size_t epc, size_t cause, size_t mtval)
{
    auto retPc = epc;

    //enum exceptionBitMask = 1uL << (size_t.sizeof * 8 - 1);

    //bool isAlignEpc = (epc & 0x3) == 0;
    //(epc) & (__riscv_xlen / 8 - 1)) == 0)

    const isInterrupt = (cause >> (size_t.sizeof * 8 - 1)) & 1;
    const causeCode = cause & ~(1uL << (size_t.sizeof * 8 - 1));
    //(epc >= FLASH_START && epc <= FLASH_END) || (epc >= RAM_START && epc <= RAM_END)

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
                Interrupts.mLocalInterruptIsEnable(
                    ~((~Interrupts.mLocalInterruptIsEnable) | Interrupts.MIE_MTIE));
                timer_handler(epc, cause);
                retPc = cast(size_t)&switchTaskToOs;
                // enable timer interrupts.
                Interrupts.mLocalInterruptIsEnable(Interrupts.mLocalInterruptIsEnable | Interrupts.MIE_MTIE);
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
