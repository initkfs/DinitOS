/**
 * Authors: initkfs
 */
module os.core.thread.task;

import os.core.io.cstdio;;

enum taskMaxCount = 16;
enum taskStacksSize = 1024;

__gshared ubyte[taskStacksSize][taskMaxCount] taskStacks;
__gshared RegContext[taskMaxCount] tasks;

__gshared RegContext contextOs;
__gshared RegContext* contextCurrent;

__gshared size_t taskCount;
__gshared size_t currentTaskIndex;

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

    // if(!contextCurrent){
    //     contextCurrent = &tasks[i];
    // }

    return i;
}

void switchContextToTask(size_t i)
{
    contextCurrent = &tasks[i];
    context_switch(&contextOs, contextCurrent);
}

void switchTasks()
{
    println("Switch tasks");
    if (currentTaskIndex >= taskCount)
    {
        currentTaskIndex = 0;
    }

    auto oldTask = contextCurrent;
    auto newTask = &tasks[currentTaskIndex];

    contextCurrent = newTask;

    currentTaskIndex++;

    context_switch(oldTask, newTask);
}

private
{
    extern (C) void context_switch(RegContext* oldContext, RegContext* newContext);
}
