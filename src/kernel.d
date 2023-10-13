/**
 * Authors: initkfs
 */
module dstart;

import Syslog = os.core.logger.syslog;

__gshared extern (C)
{
    size_t _bss_start;
    size_t _bss_end;
}

import Spinlock = os.core.sync.spinlock;

import uart;
import task;
import timer;
import trap;

__gshared
{
    int sharedCounter;
    Spinlock.Lock lock;
}

extern (C) void dstart()
{
    auto bss = &_bss_start;
    auto bss_end = &_bss_end;
    while (bss < bss_end)
    {
        *bss++ = 0;
    }

    Syslog.setLoad(true);

    Syslog.info("Os start");

    trapInit;
    Syslog.info("Init traps");
    timerInit;
    Syslog.info("Init timers");

   // Spinlock.initLock(&lock);

    taskCreate(&task0);
    // taskCreate(&task1);

    // size_t currentTask = 0;
    // while (true)
    // {
    //     Syslog.trace("Run next task.");
    //     switchContextToTask(currentTask);
    //     Syslog.trace("Back to OS");
    //     currentTask = (currentTask + 1) % taskCount;
    // }
}

void task0()
{
    Syslog.trace("Task0 created.");
    while (true)
    {
        // Syslog.trace("Task0: running...");
        // foreach (i; 0 .. 50)
        // {
        //     Spinlock.acquire(&lock);
        //     sharedCounter++;
        //     Spinlock.free(&lock);
        //     delayTicks(100);
        // }
        // delayTicks;
    }
}

void task1()
{
    Syslog.trace("Task1 created.");
    while (true)
    {
        Syslog.trace("Task1: running...");
        delayTicks;
    }
}

void delayTicks(int count = 1000)
{
    long counter = count * 50000;
    while (counter--)
    {
    }
}
