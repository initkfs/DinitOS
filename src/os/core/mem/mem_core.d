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