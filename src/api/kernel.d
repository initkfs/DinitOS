/**
 * Authors: initkfs
 */
module api.kernel;

import Tests = api.core.tests;
import Syslog = api.core.log.syslog;
import BlockAllocator = api.core.mem.allocs.block_allocator;
import MemCore = api.core.mem.mem_core;
import UPtr = api.core.mem.unique_ptr;
import StackStrMod = api.cstd.strings.stack_str;
import Allocator = api.core.mem.allocs.allocator;
import Str = api.core.strings.str;
import Hash = api.core.strings.hash;
import MathCore = api.core.math.math_core;
import MathStrict = api.core.math.math_strict;
import MathRandom = api.core.math.math_random;
import Units = api.core.util.units;
import Bits = api.core.bits;
import Atomic = api.core.thread.atomic;
import Spinlock = api.core.thread.sync.spinlock;

version (FeatureFloatPoint)
{
    import MathFloat = api.core.math.math_float;
}
else
{
    //TODO placeholder
    import MathFloat = api.core.math.math_core;
}

extern(C){
    size_t get_bss_start();
    size_t get_bss_end();
    size_t get_heap_start();
    size_t get_heap_end();
}

import api.core.io.cstdio;
import api.core.thread.task;
import api.core.timer;
import api.core.trap;

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
    import Interrupts = api.arch.riscv.hal.interrupts;

    Interrupts.mGlobalInterruptDisable;

    Syslog.setLoad(true);

    ubyte* bssStart = cast(ubyte*) get_bss_start;
    ubyte* bssEnd = cast(ubyte*) get_bss_end;

    while (bssStart < bssEnd)
    {
        //TODO volatile
        *bssStart++ = 0;
    }

    Syslog.info("Os start");

    trapInit;
    Syslog.info("Init traps");

    auto heapStartAddr = cast(void*)(get_heap_start);
    auto heapEndAddr = cast(void*)(get_heap_end);

    Allocator.heapStartAddr = heapStartAddr;
    Allocator.heapEndAddr = heapEndAddr;

    BlockAllocator.initialize(heapStartAddr, heapEndAddr);
    Allocator.allocFunc = &BlockAllocator.alloc;
    Allocator.callocFunc = &BlockAllocator.calloc;
    Allocator.freeFunc = &BlockAllocator.free;

    runTests;

    Interrupts.mGlobalInterruptEnable;

    if (isTimer)
    {
        timerInit;
        Syslog.info("Init timers");
    }

    auto tid = taskCreate(&task0);
    auto tid1 = taskCreate(&task1);
    auto tid2 = taskCreate(&task2);

    size_t taskIndex;
    while (true)
    {
        Syslog.trace("Switch tasks");
        switchOsToTask(taskIndex);
        Syslog.trace("Switch to OS");
        taskIndex = (taskIndex + 1) % taskCount;
    }
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

void task2()
{
    Syslog.trace("Enable LED3.");
    while (true)
    {
        Syslog.trace("LED3 ON");
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
