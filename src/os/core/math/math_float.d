/**
 * Authors: initkfs
 */
module os.core.math.math_float;

import ldc.llvmasm;

import MathCore = os.core.math.math_core;

bool isNaN(T)(T value) if (__traits(isFloating, T))
{
    return value != value;
}

bool isEqualEps(T)(T x, T y, T epsilon = T.epsilon) if (__traits(isArithmetic, T))
{
    if (MathCore.abs(x - y) < epsilon)
    {
        return true;
    }
    return false;
}

bool isEqual(float x, float y)
{
    return isEqualEps(x, y);
}

static if (size_t.sizeof >= double.sizeof)
{
    bool isEqual(double x, double y)
    {
        return isEqualEps(x, y);
    }
}

unittest
{
    assert(isEqual(0.0, 0.0));
    assert(!isEqual(0.0, 0.1));
    assert(isEqual(0.3, 0.3));
    assert(!isEqual(0.3, 0.3000000000000004));
    assert(isEqual(0.3, 0.30000000000000004));
}

private
{
    version (LDC)
    {
        pragma(LDC_intrinsic, "llvm.sqrt.f32")
        float sqrtf32(float);

        pragma(LDC_intrinsic, "llvm.sqrt.f64")
        double sqrtf64(double);
    }
    else
    {
        static assert(false, "Not supported square root");
    }
}

T sqrt(T)(T value) if (__traits(isFloating, T))
{
    //or NaN?
    if (value == 0)
    {
        return 0;
    }

    if (value < 0)
    {
        return T.nan;
    }

    static if (is(T == float))
    {
        return sqrtf32(value);
    }
    else static if (is(T == double))
    {
        return sqrtf64(value);
    }
    else
    {
        static assert(false, "Not supported float type for square root");
    }
}

unittest
{
    assert(isEqual(sqrt(0.0f), 0f));
    assert(isNaN(sqrt(-1.0f)));
    assert(isEqual(sqrt(1.0f), 1.0f));
    assert(isEqual(sqrt(4f), 2f));
    assert(isEqual(sqrt(16f), 4f));
    assert(isEqual(sqrt(169f), 13f));
    assert(isEqual(sqrt(0.0004f), 0.02f));
    assert(isEqual(sqrt(9.6f), 3.0983866769659336f));
}
