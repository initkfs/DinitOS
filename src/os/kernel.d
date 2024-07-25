/**
 * Authors: initkfs
 */
module os.kernel;

import Tests = os.core.tests;
import Syslog = os.core.log.syslog;
import BlockAllocator = os.core.mem.allocs.block_allocator;
import MemCore = os.core.mem.mem_core;
import UPtr = os.core.mem.unique_ptr;
import StackStrMod = os.cstd.strings.stack_str;
import Allocator = os.core.mem.allocs.allocator;
import Str = os.core.strings.str;
import Hash = os.core.strings.hash;
import MathCore = os.core.math.math_core;
import MathStrict = os.core.math.math_strict;
import MathRandom = os.core.math.math_random;
import Units = os.core.util.units;
import Bits = os.core.bits;
import Atomic = os.core.thread.atomic;
import Spinlock = os.core.thread.sync.spinlock;

version (FeatureFloatPoint)
{
    import MathFloat = os.core.math.math_float;
}
else
{
    //TODO placeholder
    import MathFloat = os.core.math.math_core;
}

__gshared extern (C)
{
    size_t _bss_start;
    size_t _bss_end;

    size_t _heap_start;
    size_t _heap_end;
}

import os.core.io.cstdio;
import os.core.thread.task;
import os.core.timer;
import os.core.trap;

__gshared
{
    int sharedCounter;
    Spinlock.Lock lock;

    bool isTimer = true;
}

private void runTests()
{
    if (Syslog.isTraceLevel)
    {
        Syslog.trace("Start testing modules");
    }

    import std.meta : AliasSeq;

    alias testModules = AliasSeq!(
        MemCore,
        UPtr,
        Str,
        Hash,
        StackStrMod,
        MathCore,
        MathStrict,
        MathFloat,
        MathRandom,
        Bits,
        Units,
        Atomic,
        Spinlock
    );

    foreach (m; testModules)
    {
        Tests.runTest!(m);
    }

    if (Syslog.isTraceLevel)
    {
        Syslog.trace("End of testing modules");
    }
}

extern (C) void dstart()
{
    auto bss = cast(ubyte*)&_bss_start;
    auto bss_end = cast(ubyte*)&_bss_end;
    while (bss < bss_end)
    {
        //TODO volatile
        *bss++ = 0;
    }

    Syslog.setLoad(true);

    Syslog.info("Os start");

    trapInit;
    Syslog.info("Init traps");

    auto heapStartAddr = cast(void*)(&_heap_start);
    auto heapEndAddr = cast(void*)(&_heap_end - 16);

    Allocator.heapStartAddr = heapStartAddr;
    Allocator.heapEndAddr = heapEndAddr;

    BlockAllocator.initialize(heapStartAddr, heapEndAddr);
    Allocator.allocFunc = &BlockAllocator.alloc;
    Allocator.callocFunc = &BlockAllocator.calloc;
    Allocator.freeFunc = &BlockAllocator.free;

    runTests;

    if (isTimer)
    {
        timerInit;
        Syslog.info("Init timers");
    }

    auto tid = taskCreate(&task0);
    auto tid2 = taskCreate(&task1);
    switchContextToTask(tid);
}

void task0()
{
    Syslog.trace("Enable LED1.");
    while (true)
    {
        Syslog.trace("LED1 ON");
        // foreach (i; 0 .. 50)
        // {
        //     Spinlock.acquire(&lock);
        //     sharedCounter++;
        //     Spinlock.free(&lock);
        //     delayTicks(100);
        // }
        delayTicks;
    }
}

void task1()
{
    Syslog.trace("Enable LED2.");
    while (true)
    {
        Syslog.trace("LED2 ON");
        delayTicks;
    }
}

void delayTicks(int count = 1000)
{
    long counter = count * 5000000;
    while (counter--)
    {
    }
}
