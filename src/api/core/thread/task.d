/**
 * Authors: initkfs
 */
module api.core.thread.task;

import api.core.io.cstdio;

import Syslog = api.core.log.syslog;
import Critical = api.core.thread.critical;

alias SignalSet = uint;

enum taskMaxCount = 16;
enum taskStacksSize = 2048;

alias reg_t = size_t;

struct RegContext
{
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

static assert(RegContext.sizeof == (14 * size_t.sizeof), "Wrong context size");

enum TaskState
{
    none,
    ready,
    running,
    sleep,
    waitSignal,
    //need reset
    killed,
    completed
}

struct Task
{
    TaskState state;
    string name;
    size_t sheduleCount;
    uint signals;
    int eventFlags;
    int waitEvents;
    uint yieldСount;

    RegContext context;

    SignalSet pendingSignals;
    SignalSet waitingMask;
    SignalSet handledSignals;
    void function()[uint.sizeof * 8] signalHandlers;
}

__gshared
{
    ubyte[taskStacksSize][taskMaxCount] taskStacks;
    Task[taskMaxCount] tasks;

    Task osTask;
    bool isInitOsTask;
    Task* currentTask;
    size_t taskIndex;

    size_t taskCount;
}

private
{
    extern (C) void context_switch(RegContext* oldContext, RegContext* newContext);
    extern (C) void context_save_task(RegContext* context);
    extern (C) void context_load_task(RegContext* context);
    extern (C) void m_wait();
}

void initSheduler()
{
    osTask.name = "IDLE";
}

//TODO first call
bool isOsTask() => currentTask is &osTask;

void checkOsTask()
{
    assert(isOsTask, "The current task is not an IDLE task.");
}

size_t taskCreate(void function() t, string name)
{
    auto i = taskCount;
    assert(i < tasks.length);

    Task* taskPtr = &tasks[i];
    assert(taskPtr.state == TaskState.none);

    taskPtr.name= name;

    assert(taskPtr.context.ra == 0);
    assert(taskPtr.context.sp == 0);

    taskPtr.state = TaskState.ready;
    taskPtr.context.ra = cast(reg_t) t;
    taskPtr.context.sp = cast(reg_t)&(taskStacks[i][taskStacksSize - 16]);
    taskPtr.context.sp = taskPtr.context.sp & ~0xF;

    signalsInit(taskPtr);

    taskCount++;

    return i;
}

void switchToTask(Task* task)
{
    assert(task);

    Critical.startCritical;

    currentTask = task;
    assert(currentTask.state != TaskState.running);
    currentTask.state = TaskState.running;
    osTask.state = TaskState.sleep;

    Critical.endCritical;

    context_switch(&(osTask.context), &(currentTask.context));
}

bool hasStateTask(TaskState state)
{
    Critical.startCritical;
    scope (exit)
    {
        Critical.endCritical;
    }

    foreach (ti; 0 .. taskCount)
    {
        Task* task = &tasks[ti];
        if (task == currentTask)
        {
            continue;
        }

        if (task.state == state)
        {
            return true;
        }
    }
    return false;
}

bool hasReadyTasks() => hasStateTask(TaskState.ready);

protected void roundrobin()
{
    Task* next;
    size_t attempts;

    while (attempts < taskCount)
    {
        if(taskIndex >= taskCount){
            taskIndex = 0;
        }

        Task* mustBeNext = &tasks[taskIndex];
        taskIndex++;

        if ((mustBeNext.state == TaskState.waitSignal) &&
            (mustBeNext.pendingSignals & mustBeNext.waitingMask))
        {
            mustBeNext.state = TaskState.ready;
        }

        if (mustBeNext.state == TaskState.ready)
        {
            next = mustBeNext;
            break;
        }
        attempts++;
    }

    if (next)
    {
        switchToTask(next);
        return;
    }

    m_wait();
}

extern(C) void roundrobinChoose()
{
    Task* next;
    size_t attempts;

    while (attempts < taskCount)
    {
        if(taskIndex >= taskCount){
            taskIndex = 0;
        }

        Task* mustBeNext = &tasks[taskIndex];
        taskIndex++;

        if ((mustBeNext.state == TaskState.waitSignal) &&
            (mustBeNext.pendingSignals & mustBeNext.waitingMask))
        {
            mustBeNext.state = TaskState.ready;
        }

        if (mustBeNext.state == TaskState.ready)
        {
            next = mustBeNext;
            break;
        }
        attempts++;
    }

    if (next)
    {
        currentTask = next;
    }
}

void step()
{
    Syslog.trace("Run sheduler step");
    roundrobin;
}

void yield()
{
    switchToOs;
}

extern(C) void saveCurrentTask(){
    context_save_task(&currentTask.context);
}

extern(C) void loadCurrentTask(){
    context_load_task(&currentTask.context);
}

extern(C) void switchToOs()
{
    // if(isOsTask){
    //     return;
    // }

    //Critical.startCritical;

    auto oldTask = currentTask;
    if (oldTask.state == TaskState.running)
    {
        oldTask.state = TaskState.ready;
    }

    currentTask = &osTask;
    assert(currentTask.state == TaskState.sleep);
    currentTask.state = TaskState.running;
    currentTask.yieldСount++;

    context_switch(&(oldTask.context), &(currentTask.context));
}

SignalSet signalWait(SignalSet waitmask)
{
    assert(currentTask);

    Critical.startCritical;

    if (currentTask.pendingSignals & waitmask)
    {
        SignalSet received = currentTask.pendingSignals & waitmask;
        currentTask.pendingSignals &= ~received;
        return received;
    }

    currentTask.state = TaskState.waitSignal;
    currentTask.waitingMask = waitmask;

    Critical.endCritical;

    yield;

    SignalSet received = currentTask.pendingSignals & waitmask;
    currentTask.pendingSignals &= ~received;

    callSignalHandlers(received);

    return received;
}

void addSignalHandler(void function() handler, uint mask)
{
    assert(currentTask);
    assert(mask > 0);
    assert((mask & (mask - 1)) == 0, "Invalid mask");

    Critical.startCritical;
    scope (exit)
    {
        Critical.endCritical;
    }

    //TODO more optimal
    foreach (hi; 0 .. currentTask.signalHandlers.length)
    {
        if (mask & (1u << hi))
        {
            currentTask.signalHandlers[hi] = handler;
            break;
        }
    }
}

protected void callSignalHandlers(uint mask)
{
    Critical.startCritical;
    scope (exit)
    {
        Critical.endCritical;
    }

    foreach (si; 0 .. currentTask.signalHandlers.length)
    {
        if ((mask & (1UL << si)) && currentTask.signalHandlers[si])
        {
            currentTask.signalHandlers[si]();
        }
    }
}

protected bool signalsInit(Task* task)
{
    assert(task);
    task.pendingSignals = 0;
    task.waitingMask = 0;
    task.handledSignals = 0;
    task.signalHandlers[] = null;
    return true;
}

bool signalSend(size_t tid, ubyte signal)
{
    Critical.startCritical;
    scope (exit)
    {
        Critical.endCritical;
    }

    assert(tid < taskCount);

    Task* targetTask = &tasks[tid];
    if (!targetTask || targetTask == currentTask)
    {
        return false;
    }

    targetTask.pendingSignals |= (1u << signal);
    return true;
}
