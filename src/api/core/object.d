/**
 * Authors: initkfs
 */
module api.core.object;

extern (C) void __assert(const(char)* msg, const(char)* file, int line)
{
    import Str = api.core.strings.str;

    string smsg = cast(string) msg[0 .. Str.strlenz(msg)];
    string sfile = cast(string) file[0 .. Str.strlenz(file)];

    import api.core.io.cstdio;

    char[64] buff = 0;

    println("Assert error: ", sfile, ":", Str.atoa(line, buff), ": ", smsg, );

    import Interrupts = api.core.arch.riscv.interrupts;

    Interrupts.mInterruptsDisable;

    while (true)
    {
    }
}

extern (C) void _d_array_slice_copy(void* dst, size_t dstlen, void* src, size_t srclen, size_t elemsz)
{
    import ldc.intrinsics : llvm_memcpy;

    llvm_memcpy!size_t(dst, src, dstlen * elemsz, 0);
}
