/**
 * Authors: initkfs
 */
module os.core.mem.mem_core;

T* memcpy(T)(T* dest, const T* src, size_t lenBytes)
{
    foreach (i; 0 .. lenBytes)
    {
        (cast(ubyte*) dest)[i] = (cast(ubyte*) src)[i];
    }
    return dest;
}

//not int c
T* memset(T)(T* dest, ubyte c, size_t lenBytes)
{
    foreach (i; 0 .. lenBytes)
    {
        ubyte* ptr = cast(ubyte*) dest;
        ptr[i] = c;
    }
    return dest;
}

bool memeqs(T)(const(T)[] s1, const(T)[] s2)
{
    if (!s1 || !s2 || (s1.length != s2.length))
    {
        return false;
    }

    if (s1.length == 0 && s2.length == 0)
    {
        return true;
    }

    foreach (i, v1; s1)
    {
        auto v2 = s2[i];
        if (v1 != v2)
        {
            return false;
        }
    }

    return true;
}
