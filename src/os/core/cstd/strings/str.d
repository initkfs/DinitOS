/**
 * Authors: initkfs
 */
module os.core.cstd.strings.str;

immutable
{
    string EMPTY = "";
    string FORMAT_ERROR = "_formaterror_";
    char NULL_BYTE = '\0';
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

size_t lenz(T)(const T* str) if (isSomeChar!T)
{
    if (!str)
    {
        return 0;
    }

    //TODO add length limit
    size_t lengthIndex;
    while (str[lengthIndex] != NULL_BYTE)
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
    assert(lenz!char(null) == 0);
    assert(lenz("".ptr) == 0);
    assert(lenz(" ".ptr) == 1);
    assert(lenz("a".ptr) == 1);
    assert(lenz("aaa".ptr) == 3);
    assert(lenz("a b c".ptr) == 5);
}
