/**
 * Authors: initkfs
 */
module os.core.mem.unique_ptr;

import os.core.errors;

struct UniqPtr(T, F = bool function(scope T*) @nogc nothrow @safe)
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

    this(T* t, size_t sizeBytes, size_t capacity, F freeFunPtr = null, bool isAutoFree = true, bool isCheckBounds = true) @nogc nothrow pure @safe
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

    @disable this(ref return scope UniqPtr!T rhs) pure
    {
    }

    ~this() @safe
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

    void free() @safe
    {
        assert(!_freed, "Memory pointer has already been freed");
        if (freeFunPtr)
        {
            bool isFreed = freeFunPtr(_ptr);
            assert(isFreed, "Memory pointer not deallocated correctly");
        }

        release;
    }

    void release() @safe
    {
        _freed = true;

        _sizeInBytes = 0;
        _capacity = 0;
        _ptr = null;
    }

    protected inout(T*) index(size_t i) inout
    in (!isFreed)
    {
        if (isCheckBounds)
        {
            //TODO
            assert(i < capacity, "Index is out of bounds");
        }
        return &_ptr[i];
    }

    inout(T) opIndex(size_t i) inout
    in (!isFreed)
    {
        return *(index(i));
    }

    inout(T) value() inout
    in (!isFreed)
    {
        return opIndex(0);
    }

    void value(T newValue)
    in (!isFreed)
    {
        *index(0) = newValue;
    }

    inout(T*) get() inout return @safe
    in (!isFreed)
    {
        return _ptr;
    }

    // a[i] = v
    void opIndexAssign(T value, size_t i)
    in (!isFreed)
    {
        *(index(i)) = value;
    }

    // a[i1, i2] = v
    void opIndexAssign(T value, size_t i1, size_t i2)
    in (!isFreed)
    {

        opSlice(i1, i2)[] = value;
    }

    void opIndexAssign(T[] value, size_t i1, size_t i2)
    in (!isFreed)
    {
        opSlice(i1, i2)[] = value;
    }

    inout(T[]) opSlice(size_t i, size_t j) inout
    in (!isFreed)
    {
        assert(i < j);
        assert(j <= capacity);
        return _ptr[i .. j];
    }

    private void opAssign(UniqPtr);

    size_t size() const @safe
    {
        return _sizeInBytes;
    }

    size_t capacity() const @safe
    {
        return _capacity;
    }

    auto range() return @safe
    {
        static struct PtrRange
        {
            private
            {
                T* ptr;
                size_t capacity;
                size_t currentIndex;
            }

            this(T* newPtr, size_t capacity)
            {
                this.ptr = newPtr;
                this.capacity = capacity;
            }

            bool empty() const
            {
                return currentIndex >= capacity;
            }

            inout(T) front() inout
            {
                return ptr[currentIndex];
            }

            void popFront()
            {
                currentIndex++;
            }
        }

        return PtrRange(_ptr, capacity);
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

    int[2] arr = [54, 65];
    auto ptr2 = UniqPtr!(int)(arr.ptr, arr.sizeof, 2, null, false, true);

    auto ptr2Slice = ptr2[0 .. 2];
    assert(ptr2Slice == arr);

    int[2] arrZero = [0, 0];
    ptr2[0 .. 2][] = 0;
    assert(ptr2[0 .. 2] == arrZero);

    int[2] arr3 = [43, 43];
    ptr2[0, 2] = 43;
    assert(ptr2[0 .. 2] == arr3);

    int[2] arr34 = [23, 34];
    ptr2[0, 2] = arr34[];
    assert(ptr2[0 .. 2] == arr34);

    size_t iters;
    foreach (v; ptr2.range)
    {
        switch (iters)
        {
            case 0:
                assert(v == 23);
                break;
            case 1:
                assert(v == 34);
                break;
            default:
                break;
        }
        iters++;
    }
    assert(iters == 2);
}
