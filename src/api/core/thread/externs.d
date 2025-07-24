/**
 * Authors: initkfs
 */
module api.core.thread.externs;

extern (C) @trusted:

version (Riscv32)
{
    //if(*ptr == expected){
    //  *ptr = desired;
    //  return true;
    //} 
    //return false
    size_t cas_lrsc(scope int* addr, int expectedInAddr, int newValueIfAddrEqvExpected);

    size_t swap_acquire(scope int* lockPtr);
    size_t swap_release(scope int* lockPtr);
}

version (Riscv64)
{
    size_t cas_lrsc(scope size_t* addr, size_t expected, size_t desired);

    size_t swap_acquire(scope size_t* lockPtr);
    size_t swap_release(scope size_t* lockPtr);
}
