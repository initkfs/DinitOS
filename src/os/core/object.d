/**
 * Authors: initkfs
 */
module os.core.object;

alias string = immutable(char)[];
alias size_t = typeof(int.sizeof);
alias ptrdiff_t = typeof(cast(void*) 0 - cast(void*) 0);

alias noreturn = typeof(*null);

static if ((void*).sizeof == 8)
{
    alias uintptr = ulong;
}
else static if ((void*).sizeof == 4)
{
    alias uintptr = uint;
}
else
{
    static assert(0, "Pointer size must be 4 or 8 bytes");
}

size_t strlen(const(char)* s)
{
    size_t n;
    for (n = 0; *s != '\0'; ++s)
    {
        ++n;
    }
    return n;
}

extern (C) noreturn __assert(const(char)* msg, const(char)* file, int line)
{
    string smsg = cast(string) msg[0 .. strlen(msg)];
    string sfile = cast(string) file[0 .. strlen(file)];

    import os.core.uart;

    println("Assert error: ", sfile, ": ", smsg);
    while (1)
    {
    }
}

extern (C) void _d_array_slice_copy(void* dst, size_t dstlen, void* src, size_t srclen, size_t elemsz)
{
    import ldc.intrinsics : llvm_memcpy;

    llvm_memcpy!size_t(dst, src, dstlen * elemsz, 0);
}
