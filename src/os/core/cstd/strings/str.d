/**
 * Authors: initkfs
 */
module os.core.cstd.strings.str;

import os.core.errors;

immutable
{
    string strEmpty = "";
    string strFormatError = "_formaterror_";
    char strNullByte = '\0';
    size_t strBuffSize = 256;
}

import std.traits : isSomeChar;

bool isEquals(T)(const(T)[] s1, const(T)[] s2) if (isSomeChar!T)
{
    import MemCore = os.core.mem.mem_core;

    return MemCore.memeqs(s1, s2);
}

unittest
{
    assert(isEquals("", ""));
    assert(isEquals(" ", " "));
    assert(!isEquals("", " "));
    assert(!isEquals(" ", ""));
    assert(!isEquals(null, ""));
    assert(!isEquals("", null));
    assert(!(isEquals!char(null, null)));

    assert(isEquals("a", "a"));
    assert(isEquals("foo bar", "foo bar"));
    assert(!isEquals("a", "A"));

    assert(isEquals(cast(string)['a'], cast(string)['a']));
}

size_t strlen(T)(const T* str) if (isSomeChar!T)
{
    if (!str)
    {
        return 0;
    }

    //TODO add length limit
    size_t lengthIndex;
    while (str[lengthIndex] != strNullByte)
    {
        if (lengthIndex == size_t.max)
        {
            import os.core.errors;

            panic("Overflow string length");
        }

        lengthIndex++;
    }

    return lengthIndex;
}

unittest
{
    assert(strlen!char(null) == 0);
    assert(strlen("".ptr) == 0);
    assert(strlen(" ".ptr) == 1);
    assert(strlen("a".ptr) == 1);
    assert(strlen("aaa".ptr) == 3);
    assert(strlen("a b c".ptr) == 5);
}

char[] ttoa(T)(T targetValue, char[] buff, const size_t base = 10)
{
    if (buff.length < 2)
    {
        panic("Buffer size must be equal or greater than 2 to convert any number to string ");
    }

    if (base == 0)
    {
        panic("Number base must not be 0");
    }

    if (targetValue == 0)
    {
        buff[0] = '0';
        return buff[0 .. 1];
    }

    //TODO hex min value, etc
    if (targetValue == T.min)
    {
        enum minStr = T.min.stringof;
        if (minStr.length <= buff.length)
        {
            buff[] = minStr;
            return buff[0 .. minStr.length];
        }
        else
        {
            enum minDefault = "-0";
            buff[] = minDefault;
            return buff[0 .. minDefault.length];
        }
    }

    immutable char[16] alphabet = "0123456789ABCDEF";

    auto value = targetValue;
    immutable isNeg = value < 0;
    if (isNeg)
    {
        value = -value;
    }

    size_t index = buff.length - 1;
    while (value && index)
    {
        buff[index] = alphabet[value % base];
        value /= base;
        --index;
    }

    if (isNeg)
    {
        buff[index] = '-';
    }
    else
    {
        index++;
    }
    //TODO it would be useful to reset the buffer in case of insufficient capacity
    return buff[index .. $];
}

char[] atoa(int value, char[] buff, const size_t base = 10)
{
    return ttoa(value, buff, base);
}

//TODO compiler-rt
static if (size_t.sizeof >= long.sizeof)
{
    char[] ltoa(long value, char[] buff, const size_t base = 10)
    {
        return ttoa(value, buff, base);
    }
}

unittest
{
    import os.core.cstd.io.cstdio;

    char[64] buff = 0;

    //Decimal
    auto sd = atoa(0, buff);
    assert(isEquals(sd, "0"));
    assert(sd.length == 1);

    auto negZero = atoa(-0, buff);
    assert(isEquals(negZero, "0"));
    assert(negZero.length == 1);

    auto sd1 = atoa(1, buff);
    assert(isEquals(sd1, "1"));
    assert(sd1.length == 1);

    auto sdneg1 = atoa(-1, buff);
    assert(isEquals(sdneg1, "-1"));

    auto sd101 = atoa(101, buff);
    assert(isEquals(sd101, "101"));

    auto sd101neg = atoa(-101, buff);
    assert(isEquals(sd101neg, "-101"));

    auto sd100x = atoa(10_000_000, buff);
    assert(isEquals(sd100x, "10000000"));

    auto sd64x = atoa(648_356, buff);
    assert(isEquals(sd64x, "648356"));

    auto sdmax = atoa(int.max, buff);
    assert(isEquals(sdmax, "2147483647"));

    auto sdmin = atoa(int.min, buff);
    assert(isEquals(sdmin, "-2147483648"));

    //Negative tests
    char[2] minBuff = 0;
    auto minMin = atoa(int.min, minBuff);
    assert(isEquals(minMin, "-0"));

    auto numOverflow = atoa(1234, minBuff);
    assert(isEquals(numOverflow, "4"));

    auto numNegOverflow = atoa(-1234, minBuff);
    assert(isEquals(numNegOverflow, "-4"));

    //Bin
    enum binBase = 2;
    auto binZero = atoa(0, buff, binBase);
    assert(isEquals(binZero, "0"));

    auto binOne = atoa(1, buff, binBase);
    assert(isEquals(binOne, "1"));

    auto bin2 = atoa(2, buff, binBase);
    assert(isEquals(bin2, "10"));

    auto bin10 = atoa(10, buff, binBase);
    assert(isEquals(bin10, "1010"));

    auto bin10neg = atoa(-10, buff, binBase);
    assert(isEquals(bin10neg, "-1010"));

    auto bin64x = atoa(648356, buff, binBase);
    assert(isEquals(bin64x, "10011110010010100100"));

    //Hex
    enum hexBase = 16;
    auto hZero = atoa(0, buff, hexBase);
    assert(isEquals(hZero, "0"));

    auto hOne = atoa(1, buff, hexBase);
    assert(isEquals(hOne, "1"));

    auto hOneNeg = atoa(-1, buff, hexBase);
    assert(isEquals(hOneNeg, "-1"));

    auto h10 = atoa(10, buff, hexBase);
    assert(isEquals(h10, "A"));

    auto h4573 = atoa(4573, buff, hexBase);
    assert(isEquals(h4573, "11DD"));

    auto h0x7f = atoa(int.max, buff, hexBase);
    assert(isEquals(h0x7f, "7FFFFFFF"));

    auto h0x7fMin = atoa(int.min, buff, hexBase);
    //TODO correct hex min value
    assert(isEquals(h0x7fMin, "-2147483648"));

    //Long
    static if (size_t.sizeof >= long.sizeof)
    {
        auto lMax = ltoa(long.max, buff);
        assert(isEquals(lMax, "9223372036854775807"));

        auto lMin = ltoa(long.min, buff);
        //TODO cast
        assert(isEquals(lMin, "cast(long)-9223372036854775808"));
    }
}
