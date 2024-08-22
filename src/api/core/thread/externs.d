/**
 * Authors: initkfs
 */
module api.core.thread.externs;

extern(C) @trusted:

size_t cas_lrsc(scope int* addr, int expected, int desired);
size_t swap_acquire(scope int* lockPtr);
size_t swap_release(scope int* lockPtr);