/**
 * Authors: initkfs
 */
module dstart;

__gshared extern (C) {
    uint _bss_start;
    uint _bss_end;
}

extern (C) void dstart()
{
    uint* bss = &_bss_start;
    uint* bss_end = &_bss_end;
    while (bss < bss_end)
    {
        *bss++ = 0;
    }

    import uart;

    println("Hello world!");
}
