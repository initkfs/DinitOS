/**
 * Authors: initkfs
 */
module os.core.thread.atomic;

import Externs = os.core.thread.externs;

bool cas(int* ptr, int expected, int desired)
{
    return cast(bool) Externs.cas_lrsc(ptr, expected, desired);
}

unittest {
    int v = 12;
    auto res = cas(&v, 12, 22);
    assert(res);
    assert(v == 22);

    int v1 = 12;
    assert(!cas(&v1, 24, 22));
}
