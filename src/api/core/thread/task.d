/**
 * Authors: initkfs
 */
module api.core.thread.task;

import api.core.io.cstdio;

import Syslog = api.core.log.syslog;

enum taskMaxCount = 16;
enum taskStacksSize = 2048;

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

enum TaskState {
    none,
    created,
    running,
    sleep
}

struct Task
{
    TaskState state;
    RegContext context;
}

__gshared
{
    ubyte[taskStacksSize][taskMaxCount] taskStacks;
    Task[taskMaxCount] tasks;

    Task osTask;
    Task* currentTask;

    size_t taskCount;
}

size_t taskCreate(void function() t)
{
    auto i = taskCount;
    Task* taskPtr = &tasks[i];
    assert(taskPtr.state == TaskState.none);
    taskPtr.state = TaskState.created;
    taskPtr.context.ra = cast(reg_t) t;
    taskPtr.context.sp = cast(reg_t)&(taskStacks[i][taskStacksSize - 1]);
    
    taskCount++;

    return i;
}

void switchOsToTask(size_t i)
{
    currentTask = &tasks[i];
    assert(currentTask.state != TaskState.running);
    currentTask.state = TaskState.running;
    osTask.state = TaskState.sleep;
    context_switch(&(osTask.context), &(currentTask.context));
}

void switchTaskToOs()
{
    auto oldTask = currentTask;
    assert(oldTask.state == TaskState.running);
    oldTask.state = TaskState.sleep;
   
    currentTask = &osTask;
    assert(currentTask.state == TaskState.sleep);
    currentTask.state = TaskState.running;
    
    context_switch(&(oldTask.context), &(currentTask.context));
}

private
{
    extern (C) void context_switch(RegContext* oldContext, RegContext* newContext);
}
