/**
 * Authors: initkfs
 */
module os.core.thread.task;

import os.core.io.cstdio;

import Syslog = os.core.log.syslog;

enum taskMaxCount = 16;
enum taskStacksSize = 1024;

__gshared
{
    ubyte[taskStacksSize][taskMaxCount] taskStacks;
    RegContext[taskMaxCount] tasks;

    RegContext contextOs;
    RegContext* contextCurrent;

    size_t taskCount;
}

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

size_t taskCreate(void function() t)
{
    auto i = taskCount;
    tasks[i].ra = cast(reg_t) t;
    tasks[i].sp = cast(reg_t)&taskStacks[i][taskStacksSize - 1];
    taskCount++;

    return i;
}

void switchOsToTask(size_t i)
{
    contextCurrent = &tasks[i];
    context_switch(&contextOs, contextCurrent);
}

void switchTaskToOs()
{
    auto oldTask = contextCurrent;
    contextCurrent = &contextOs;
    context_switch(oldTask, contextCurrent);
}

private
{
    extern (C) void context_switch(RegContext* oldContext, RegContext* newContext);
}
