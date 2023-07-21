/**
 * Authors: initkfs
 */
module task;

enum taskMaxCount = 10;
enum taskStacksSize = 1024;

__gshared ubyte[taskStacksSize][taskMaxCount] taskStacks;
__gshared RegContext[taskMaxCount] tasks;

__gshared RegContext contextOs;
__gshared RegContext* contextCurrent;

__gshared size_t taskCount=0;

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
	auto i=taskCount++;
	tasks[i].ra = cast(reg_t) t;
	tasks[i].sp = cast(reg_t) &taskStacks[i][taskStacksSize-1];
	return i;
}

void switchContextToTask(size_t i) {
	contextCurrent = &tasks[i];
	contextSwitch(&contextOs, contextCurrent);
}

void switchContextToOs() {
    //back to os
    import uart;
    println("Switch context to os");
	RegContext* ctx = contextCurrent;
	contextCurrent = &contextOs;
	contextSwitch(ctx, &contextOs);
}

private {
    extern (C) void contextSwitch(RegContext* oldContext, RegContext* newContext);
}

