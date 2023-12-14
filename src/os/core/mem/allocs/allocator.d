/**
 * Authors: initkfs
 */
module os.core.mem.allocs.allocator;

import os.core.mem.unique_ptr: UniqPtr;

private __gshared
{
    void* _heapStartAddr;
    void* _heapEndAddr;
}

__gshared
{
    void* function(size_t num, size_t size) calloc;
    void* function(size_t num) alloc;
    bool function(void*) @nogc nothrow free;
}

UniqPtr!T uptr(T)(size_t capacity = 1)
{
    assert(alloc);
    assert(free);
    assert(capacity > 0, "Pointer capacity must be positive number");

    immutable sizeInBytes = capacity * T.sizeof;
    void* newPtr = alloc(sizeInBytes);

    assert(newPtr, "Allocated pointer is null");

    return UniqPtr!T(cast(T*) newPtr, sizeInBytes, capacity, free);
}

void heapStartAddr(void* ptr)
{
    assert(ptr, "Heap start address must not be null");
    _heapStartAddr = ptr;
}

void* heapStartAddr()
{
    assert(_heapStartAddr, "Heap start address is null");
    return _heapStartAddr;
}

void heapEndAddr(void* ptr)
{
    assert(ptr, "Heap end address must not be null");
    _heapEndAddr = ptr;
}

void* heapEndAddr()
{
    assert(_heapEndAddr, "Heap end address is null");
    return _heapEndAddr;
}
