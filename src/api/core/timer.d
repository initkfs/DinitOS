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

__gshared size_t interval;

version (RiscvGenericSMP)
{
    __gshared size_t isProcessUpdate;
}

//Round-Robin. 1-10ms
//RTOS. 100 mcs - 1 ms
enum startIntervalSec = 5;

__gshared TimerScratch[Interrupts.numCores] timerMscratchs;

struct TimerScratch
{
align(1):
    //timervec
    size_t[3] saveRegisters;
    size_t clintCmpRegister;
    size_t interval;
}

size_t ticksFromSec(size_t sec, size_t freqHz) => sec * freqHz;

void timerInit()
{
    size_t id = Harts.mhartId();

    import Platform = api.arch.riscv.hal.platform;

    interval = ticksFromSec(startIntervalSec, Platform.mTimerHz);
    assert(interval > 0);

    writeIntevalToTimer(id);

    TimerScratch* mScratch = &timerMscratchs[id];
    //TODO or 64-bit timer register?
    mScratch.clintCmpRegister = cast(size_t) Interrupts.mTimeRegCmpAddr(id);
    mScratch.interval = interval;
    Interrupts.mScratch(cast(size_t) mScratch.saveRegisters.ptr);

    Interrupts.mInterruptIsEnable(Interrupts.mInterruptIsEnable | Interrupts.MIE_MTIE);

    // uint64_t read_mtime()
    // {
    //     uint32_t lo, hi;
    //     do
    //     {
    //         hi = read_reg(MTIME_HI);
    //         lo = read_reg(MTIME_LO);
    //     }
    //     while (hi != read_reg(MTIME_HI));
    //     return ((uint64_t) hi << 32) | lo;
    // }
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
    import Volatile = api.core.volatile;

    //*mtimeCmpPtr = currTimeValue + interval;

    ulong* mtimeCmpPtr = cast(ulong*) Interrupts.mTimeRegCmpAddr(mhartId);

    ulong currTimeValue = Volatile.load(cast(ulong*) Interrupts.mTime());
    const timeValue = currTimeValue + interval;

    version (RiscvGeneric)
    {
        version (Riscv32)
        {
            version (RiscvGenericSMP)
            {
                import MemCore = api.core.mem.mem_core;

                //Interrupts.mInterruptsDisable;

                import Atomic = api.core.thread.atomic;
                import ldc.llvmasm : __asm;

                uint spinCount = 0;
                while (!Atomic.cas(&isProcessUpdate, 0, 1))
                {
                    //2^spin_count
                    for (uint i = 0; i < (1 << spinCount); i++)
                    {
                        __asm("nop", "");
                    }
                    if (spinCount < 10)
                    {
                        spinCount++;
                    }
                }

                MemCore.memoryFenceWW;

                mtimeCmpPtr[0] = timeValue & 0xFFFF_FFFF;
                MemCore.memoryFenceWW;
                mtimeCmpPtr[1] = timeValue >> 32;

                while (Atomic.cas(&isProcessUpdate, 1, 0))
                {

                }

                //TODO restory status
                //Interrupts.mInterruptsEnable;
            }
            else
            {
                mtimeCmpPtr[0] = timeValue & 0xFFFF_FFFF;
                mtimeCmpPtr[1] = timeValue >> 32;
            }

        }

        version (Riscv64)
        {
            Volatile.save(mtimeCmpPtr, timeValue);
        }
    }
    else
    {
        static assert(false, "Not supported platform");
    }
}
