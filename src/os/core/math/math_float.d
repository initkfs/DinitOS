/**
 * Authors: initkfs
 */
module os.core.math.math_float;

import os.core.errors;

import MathCore = os.core.math.math_core;
import MathFloatExterns = os.core.math.math_float_externs;

import ldc.llvmasm;

bool isPositiveInf(T)(T x) if (__traits(isFloating, T))
{
    return x == x.infinity;
}

unittest
{
    assert(!isPositiveInf(0.0f));
    assert(isPositiveInf(float.infinity));
    assert(!isPositiveInf(-float.infinity));
}

bool isNegativeInf(T)(T x) if (__traits(isFloating, T))
{
    return x == -x.infinity;
}

unittest
{
    assert(!isNegativeInf(0.0f));
    assert(isNegativeInf(-float.infinity));
    assert(!isNegativeInf(float.infinity));
}

bool isInf(T)(T x) if (__traits(isFloating, T))
{
    return isPositiveInf(x) || isNegativeInf(x);
}

unittest
{
    assert(!isInf(0.0f));
    assert(isInf(float.infinity));
    assert(isInf(3.4f / 0f));
}

bool isNaN(T)(T value) if (__traits(isFloating, T))
{
    return value != value;
}

unittest
{
    assert(!isNaN(0.0f));
    assert(!isNaN(1.0f));
    assert(!isNaN(float.infinity));
    assert(!isNaN(-float.infinity));
    assert(isNaN(float.nan));
}

bool isFinite(T)(T x) if (__traits(isFloating, T))
{
    return !isNaN(x) && !isInf(x);
}

unittest
{
    assert(isFinite(0.0f));
    assert(isFinite(0.00000000001f));
    assert(!isFinite(float.nan));
    assert(!isFinite(float.infinity));
    assert(!isFinite(-float.infinity));
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
    assert(!isEqual(0.3, 0.3000004));
    assert(isEqual(0.3, 0.30000004));
}

auto sqrt(T)(T value) if (__traits(isArithmetic, T))
{
    //or NaN?
    if (value == 0)
    {
        return 0;
    }

    static if (__traits(isFloating, T))
    {
        if (value < 0)
        {
            return T.nan;
        }
    }

    static if (T.sizeof <= 4)
    {
        return MathFloatExterns._sqrt(cast(float) value);
    }
    else static if (T.sizeof <= 8)
    {
        return MathFloatExterns._sqrt(cast(double) value);
    }
    else
    {
        static assert(false, "Not supported float type for square root: " ~ T.stringof);
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

    assert(sqrt(4) == 2);
}

auto pow(T)(T base, int exponent)
{
    //0^0 must be an error
    if (base == 0)
    {
        return 0;
    }

    if (exponent == 0)
    {
        return 1;
    }

    if (exponent == 1)
    {
        return base;
    }

    static if (__traits(isIntegral, T))
    {
        if (exponent < 0)
        {
            panic("Cannot raise integral value to a negative power.");
        }
    }

    immutable result = pow(base, exponent / 2);
    immutable mod2Exp = exponent % 2;
    if (mod2Exp < 0)
    {
        return result * result / base;
    }

    else if (mod2Exp > 0)
    {
        return result * result * base;
    }

    return result * result;
}

unittest
{
    assert(pow(0, 0) == 0);
    assert(pow(1, 1) == 1);
    assert(pow(2, 2) == 4);
    assert(pow(2, 3) == 8);
    assert(isEqual(pow(2.5f, 3), 15.625f));
    assert(isEqual(pow(10f, -1), 0.1f));
    assert(isEqual(pow(10f, -2), 0.01f));
    assert(isEqual(pow(10f, -3), 0.001f));
}

//TODO e-notation
T parse(T = float, C = char)(const(C)[] str, const char separator = '.')
        if (__traits(isFloating, T))
{
    if (str.length == 0)
    {
        return T.nan;
    }

    import Strings = os.core.strings.str;
    import Ascii = os.core.strings.ascii;

    if (Strings.isEqual(str, "NaN"))
    {
        return T.nan;
    }

    if (Strings.isEqual(str, "inf") || Strings.isEqual(str, "+Infinity"))
    {
        return T.infinity;
    }

    if (Strings.isEqual(str, "-inf") || Strings.isEqual(str, "-Infinity"))
    {
        return -T.infinity;
    }

    T result = 0;
    int e = 0;
    size_t currentCharIndex;
    const isNeg = (str[0] == '-');
    if (isNeg)
    {
        currentCharIndex++;
    }

    foreach (i; currentCharIndex .. (str.length))
    {
        const ch = str[i];
        if (!Ascii.isDecimalDigit(ch))
        {
            break;
        }
        currentCharIndex++;
        result = result * 10 + (ch - '0');
    }

    const mustBeSep = str[currentCharIndex];
    if (mustBeSep == separator)
    {
        const fromSepToEnd = currentCharIndex + 1;
        foreach (i; fromSepToEnd .. (str.length))
        {
            const ch = str[i];
            if (!Ascii.isDecimalDigit(ch))
            {
                break;
            }
            result = result * 10 + (ch - '0');
            e = e - 1;
            currentCharIndex++;
        }
    }

    while (e > 0)
    {
        result *= 10;
        e--;
    }

    immutable dt = cast(T) 0.1;
    while (e < 0)
    {
        result *= dt;
        e++;
    }

    return isNeg ? -result : result;
}

unittest
{
    assert(isNaN(parse("NaN")));
    assert(isPositiveInf(parse!float("+Infinity")));
    assert(isNegativeInf(parse!float("-Infinity")));
    assert(isEqual(parse("0.0"), 0.0f));
    //FIXME
    // assert(isEqual(parse("3.556"), 3.556f));
    // assert(isEqual(parse!float("564.63333"), 564.63333000f));
}
