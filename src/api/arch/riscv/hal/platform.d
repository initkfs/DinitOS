/**
 * Authors: initkfs
 */
module api.arch.riscv.hal.platform;

version (Qemu)
{
    enum clintBase = 0x2000000;
    enum clintCompareRegHurtOffset = 0x4000;
    enum clintTimerRegOffset = 0xBFF8;
    enum clintMtimecmpSize = 8;
    enum numCores = 2;
    enum mTimerHz = 10_000_000;
}
