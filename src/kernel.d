/**
 * Authors: initkfs
 */
module dstart;

__gshared extern (C)
{
    size_t _bss_start;
    size_t _bss_end;
}

enum taskStackSize = 1024;
__gshared reg_t[taskStackSize] taskStack;

__gshared RegContext contextCurrent;
__gshared RegContext contextTask;

import uart;

alias reg_t = size_t;

struct RegContext
{
align(1):
    reg_t ra;
    reg_t sp;

    //saved
    reg_t s0;
    reg_t s1;
    reg_t s2;
    reg_t s3;
    reg_t s4;
    reg_t s5;
    reg_t s6;
    reg_t s7;
    reg_t s8;
    reg_t s9;
    reg_t s10;
    reg_t s11;
}

extern (C) void dstart()
{
    auto bss = &_bss_start;
    auto bss_end = &_bss_end;
    while (bss < bss_end)
    {
        *bss++ = 0;
    }

    println("Os start");

    contextTask.ra = cast(reg_t) &userTask;
    contextTask.sp = cast(reg_t) &taskStack[taskStackSize - 1];

    contextSwitch(&contextCurrent, &contextTask);

    println("Os end");
}

extern (C) void contextSwitch(RegContext* oldContext, RegContext* newContext);

void userTask()
{
    println("User task: context switch.");
    while (1)
    {
    }
}

void delay(int count = 5000)
{
    while (count--)
    {
    }
}
