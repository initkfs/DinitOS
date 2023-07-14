/**
 * Authors: initkfs
 */
module object;

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

pragma(LDC_intrinsic, "ldc.bitop.vld") ubyte volatileLoad(ubyte* ptr);
pragma(LDC_intrinsic, "ldc.bitop.vld") ushort volatileLoad(ushort* ptr);
pragma(LDC_intrinsic, "ldc.bitop.vld") uint volatileLoad(uint* ptr);
pragma(LDC_intrinsic, "ldc.bitop.vld") ulong volatileLoad(ulong* ptr);
pragma(LDC_intrinsic, "ldc.bitop.vst") void volatileStore(ubyte* ptr, ubyte value);
pragma(LDC_intrinsic, "ldc.bitop.vst") void volatileStore(ushort* ptr, ushort value);
pragma(LDC_intrinsic, "ldc.bitop.vst") void volatileStore(uint* ptr, uint value);
pragma(LDC_intrinsic, "ldc.bitop.vst") void volatileStore(ulong* ptr, ulong value);

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

    import uart;

    println("Assert error: ", sfile, ": ", smsg);
    while (1)
    {
    }
}
