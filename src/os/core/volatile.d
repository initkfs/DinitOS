/**
 * Authors: initkfs
 */
module os.core.volatile;

version (LDC)
{
    private
    {
        enum ldcLoadIntrName = "ldc.bitop.vld";
        enum ldcSaveIntrName = "ldc.bitop.vst";
    }

    pragma(LDC_intrinsic, ldcLoadIntrName)
    ubyte load(ubyte* ptr);

    pragma(LDC_intrinsic, ldcLoadIntrName)
    ushort load(ushort* ptr);

    pragma(LDC_intrinsic, ldcLoadIntrName)
    uint load(uint* ptr);

    pragma(LDC_intrinsic, ldcLoadIntrName)
    ulong load(ulong* ptr);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void save(ubyte* ptr, ubyte value);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void save(ushort* ptr, ushort value);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void save(uint* ptr, uint value);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void save(ulong* ptr, ulong value);

    unittest
    {
        import std.meta : AliasSeq;

        foreach (Type; AliasSeq!(ubyte, ushort, uint, ulong))
        {
            Type t;
            Type* tptr = &t;
            safe(tptr, 147);
            Type result = load(tptr);
            assert(t == result);
        }
    }
}
