/**
 * Authors: initkfs
 */
module dstart;

__gshared extern (C)
{
    size_t _bss_start;
    size_t _bss_end;
}

import uart;
import task;

extern (C) void dstart()
{
    auto bss = &_bss_start;
    auto bss_end = &_bss_end;
    while (bss < bss_end)
    {
        *bss++ = 0;
    }

    println("Os start");

    taskCreate(&task0);
    taskCreate(&task1);

    size_t currentTask = 0;
    while (1)
    {
        println("Run next task.");
        switchContextToTask(currentTask);
        println("Back to OS");
        currentTask = (currentTask + 1) % taskCount;
        println("---");
    }

    //println("Os end");
}

void task0()
{
    println("Task0 created.");
    println("Task0: return to kernel mode.");
    switchContextToOs();
    while (true)
    {
        println("Task0: running...");
        delayTicks;
        switchContextToOs();
    }
}

void task1()
{
    println("Task1 created.");
    println("Task1: return to kernel mode.");
    switchContextToOs();
    while (true)
    {
        println("Task1: running...");
        delayTicks;
        switchContextToOs();
    }
}

void delayTicks(int count = 5000)
{
    while (count--)
    {
    }
}
