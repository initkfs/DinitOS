/**
 * Authors: initkfs
 */
module os.core.arch.riscv.platform;

version (Qemu)
{
    enum clintBase = 0x2000000;
    enum clintCompareRegHurtOffset = 0x4000;
    enum clintTimerRegOffset = 0xBFF8;
    enum numCores = 2;
}
