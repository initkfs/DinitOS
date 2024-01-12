/**
 * Authors: initkfs
 */
module os.core.object;

extern (C) void __assert(const(char)* msg, const(char)* file, int line)
{
    import Str = os.core.cstd.strings.str;

    string smsg = cast(string) msg[0 .. Str.strlen(msg)];
    string sfile = cast(string) file[0 .. Str.strlen(file)];

    import os.core.cstd.io.cstdio;

    char[64] buff = 0;

    println("Assert error: ", sfile, ": ", smsg, ":", Str.atoa(line, buff));
    while (1)
    {
    }
}

extern (C) void _d_array_slice_copy(void* dst, size_t dstlen, void* src, size_t srclen, size_t elemsz)
{
    import ldc.intrinsics : llvm_memcpy;

    llvm_memcpy!size_t(dst, src, dstlen * elemsz, 0);
}
