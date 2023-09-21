/**
 * Authors: initkfs
 */
module interrupt;

enum size_t maxCpu = 8;
enum clintBase = 0x2000000;
enum clintCompareRegHurtOffset = 0x4000;
enum clintTimerRegOffset = 0xBFF8;
enum numCores = 2;

ulong mtimecmpForHart(size_t hartid)
{
    return clintBase + clintCompareRegHurtOffset + numCores * (hartid);
}

ulong mtime()
{
    return clintBase + clintTimerRegOffset;
}

extern (C) size_t get_hart_id();

enum MSTATUS_MPP_MASK = (3 << 11);
enum MSTATUS_MPP_M = (3 << 11);
enum MSTATUS_MPP_S = (1 << 11);
enum MSTATUS_MPP_U = (0 << 11);
enum MSTATUS_MIE = (1 << 3);

extern (C) size_t get_mstatus();
extern (C) void set_mstatus(size_t);

extern (C) void set_exception_counter(size_t);
extern (C) size_t get_exception_counter();

extern (C) void set_mscratch(size_t);
extern (C) void set_minterrupt_vector(size_t);

// external
enum MIE_MEIE = (1 << 11);
// timer
enum MIE_MTIE = (1 << 7);
// software
enum MIE_MSIE = (1 << 3);

extern (C) size_t get_minterrupt_enable();
extern (C) void set_minterrupt_enable(size_t);

extern (C) void set_minterrupt_vector_timer();

void disableInterrupts()
{
    set_minterrupt_enable(~((~get_minterrupt_enable) | (1 << 7)));
}

void enableInterrupts()
{
    set_minterrupt_enable(get_minterrupt_enable | MIE_MTIE);
}
