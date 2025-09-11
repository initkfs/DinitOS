/**
 * Authors: initkfs
 */
module api.core.thread.atomic;

import Externs = api.core.thread.externs;

version (Riscv32)
{
    bool cas(uint* ptr, int expected, int desired)
    {
        return cast(bool) Externs.cas_lrsc(ptr, expected, desired);
    }
}

version (Riscv64)
{
    bool cas(size_t* ptr, size_t expected, size_t desired)
    {
        return cast(bool) Externs.cas_lrsc(ptr, expected, desired);
    }
}

unittest
{
    size_t v = 12;
    auto res = cas(&v, 12, 22);
    assert(res);
    assert(v == 22);

    size_t v1 = 12;
    assert(!cas(&v1, 24, 22));
}
