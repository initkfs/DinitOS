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
    ubyte volatileLoad(ubyte* ptr);

    pragma(LDC_intrinsic, ldcLoadIntrName)
    ushort volatileLoad(ushort* ptr);

    pragma(LDC_intrinsic, ldcLoadIntrName)
    uint volatileLoad(uint* ptr);

    pragma(LDC_intrinsic, ldcLoadIntrName)
    ulong volatileLoad(ulong* ptr);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void volatileStore(ubyte* ptr, ubyte value);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void volatileStore(ushort* ptr, ushort value);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void volatileStore(uint* ptr, uint value);

    pragma(LDC_intrinsic, ldcSaveIntrName)
    void volatileStore(ulong* ptr, ulong value);

    unittest
    {
        import std.meta : AliasSeq;

        foreach (Type; AliasSeq!(ubyte, ushort, uint, ulong))
        {
            Type t;
            Type* tptr = &t;
            volatileStore(tptr, 147);
            Type result = volatileLoad(tptr);
            assert(t == result);
        }
    }
}
