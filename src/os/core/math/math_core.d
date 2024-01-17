/**
 * Authors: initkfs
 */
module os.core.math.math_core;

T abs(T)(T x) if (__traits(isArithmetic, T))
{
    static if (__traits(isIntegral, T))
    {
        if (x == T.min)
        {
            return T.max;
        }
    }

    return x < 0 ? -x : x;
}

unittest
{
    assert(abs(0) == 0);
    assert(abs(-1) == 1);
    assert(abs(-2345) == 2345);
    assert(abs(3 - 9) == 6);
    assert(abs(int.min) == int.max);
}

T max(T)(T a, T b) if (__traits(isArithmetic, T))
{
    static if (__traits(isFloating, T))
    {
        import MathFloat = os.core.math.math_float;

        if (MathFloat.isNaN(a) || MathFloat.isNan(b))
        {
            return T.nan;
        }
    }

    //TODO rough equivalence
    return (a >= b) ? a : b;
}

unittest
{
    assert(max(10, 1) == 10);
    assert(max(-10, 1) == 1);
    assert(max(-1, 0) == 0);
    assert(max(1, 0) == 1);
    assert(max(10, 5) == 10);
}

T min(T)(T a, T b) if (__traits(isArithmetic, T))
{
    static if (__traits(isFloating, T))
    {
        import MathFloat = os.core.math.math_float;

        if (MathFloat.isNaN(a) || MathFloat.isNan(b))
        {
            return T.nan;
        }
    }

    return (a <= b) ? a : b;
}

unittest
{
    assert(min(1, 0) == 0);
    assert(min(-1, 0) == -1);
    assert(min(10, 5) == 5);
    assert(min(345, 400) == 345);
}

//[min..max]
T clamp(T)(T value, T minValue, T maxValue) if (__traits(isArithmetic, T))
{
    return max!T(minValue, min!T(maxValue, value));
}

unittest
{
    assert(clamp(-2, -1, 2) == -1);
    assert(clamp(-1, -1, 2) == -1);
    assert(clamp(0, -1, 2) == 0);
    assert(clamp(1, -1, 2) == 1);
    assert(clamp(2, -1, 2) == 2);
    assert(clamp(3, -1, 2) == 2);
}
