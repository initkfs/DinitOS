/**
 * Authors: initkfs
 */
module os.core.mem.unique_ptr;

import os.core.errors;

struct UniqPtr(T, F = bool function(void*) @nogc nothrow)
{
    private
    {
        T* _ptr;
        size_t _sizeInBytes;
        size_t _capacity;
        bool _freed;
        F freeFunPtr;
    }

    bool isCheckBounds;
    bool isAutoFree;

    this(T* t, size_t sizeBytes, size_t capacity, F freeFunPtr = null, bool isAutoFree = true, bool isCheckBounds = true) @nogc nothrow pure
    {
        static assert(T.sizeof > 0);
        assert(sizeBytes > 0);
        assert(sizeBytes >= T.sizeof);
        assert(capacity > 0);
        assert(sizeBytes >= capacity * T.sizeof);

        _ptr = t;
        _sizeInBytes = sizeBytes;
        _capacity = capacity;
        this.freeFunPtr = freeFunPtr;
        this.isAutoFree = isAutoFree;
        this.isCheckBounds = isCheckBounds;
    }

    alias value this;

@nogc nothrow:

    @disable this(ref return scope UniqPtr!T rhs)
    {
    }

    ~this()
    {
        if (isAutoFree)
        {
            free;
        }
    }

    bool isFreed() const pure @safe
    {
        return _freed;
    }

    void free()
    {
        assert(!_freed, "Memory pointer has already been freed");
        _freed = true;
        _sizeInBytes = 0;
        _capacity = 0;
        if (freeFunPtr)
        {
            bool isFreed = freeFunPtr(cast(void*) _ptr);
            assert(isFreed, "Memory pointer not deallocated correctly");
        }
        _ptr = null;
    }

    protected inout(T*) index(size_t i) inout
    in(!isFreed)
    {
        if (isCheckBounds)
        {
            //TODO
            assert(i < capacity, "Index is out of bounds");
        }
        return &_ptr[i];
    }

    inout(T) opIndex(size_t i) inout
    in(!isFreed)
    {
        return *(index(i));
    }

    inout(T) value() inout
    in(!isFreed)
    {
        return opIndex(0);
    }

    void value(T newValue)
    in(!isFreed)
    {
        *index(0) = newValue;
    }

    inout(T*) get() inout
    in(!isFreed)
    {
        return _ptr;
    }

    // a[i] = v
    void opIndexAssign(T value, size_t i)
    in(!isFreed)
    {
        *(index(i)) = value;
    }

    private void opAssign(UniqPtr);

    size_t size() const
    {
        return _sizeInBytes;
    }

    size_t capacity() const
    {
        return _capacity;
    }
}

unittest
{
    int value = 45;
    auto ptr = UniqPtr!(int)(&value, value.sizeof, 1, null, false, true);

    assert(!ptr.isFreed, "Pointer freed");
    assert(ptr.size == value.sizeof, "Pointer invalid size");

    assert(ptr.value == value, "Pointer value incorrect");
    assert(ptr[0] == value, "Pointer first index incorrect");
    assert(ptr.get == &value, "Invalid raw pointer");

    enum newValue = 2324;
    ptr.value = newValue;
    assert(ptr.value == newValue, "Pointer invalid new value");
}
