/**
 * Authors: initkfs
 */
module interrupt;

enum maxCpu = 8;
enum clintBase = 0x2000000;
enum clintCompareRegHurtOffset = 0x4000;
enum clintTimerRegOffset = 0xBFF8;

ulong mtimecmpForHart(size_t hartid)
{
    return clintBase + clintCompareRegHurtOffset + 4 * (hartid);
}

ulong mtime()
{
    return clintBase + clintTimerRegOffset;
}

extern (C) size_t getHartId();

enum MSTATUS_MPP_MASK = (3 << 11);
enum MSTATUS_MPP_M = (3 << 11);
enum MSTATUS_MPP_S = (1 << 11);
enum MSTATUS_MPP_U = (0 << 11);
enum MSTATUS_MIE = (1 << 3);

extern (C) size_t getMStatus();
extern (C) void setMStatus(size_t);

extern (C) void setExceptionCounter(size_t);
extern (C) size_t getExceptionCounter();

extern (C) void setMScratch(size_t);
extern (C) void setMInterruptVector(size_t);

// external
enum MIE_MEIE = (1 << 11);
// timer
enum MIE_MTIE = (1 << 7);
// software
enum MIE_MSIE = (1 << 3);

extern (C) size_t getMInterruptEnable();
extern (C) void setMInterruptEnable(size_t);

extern (C) void setMInterruptVectorTimer();
