module os.core.mem.mem_core;

struct Ptr(T, F = bool function(void*) @nogc nothrow)
{
    private
    {
        T* _ptr;
        size_t _size;
        bool _freed;
        F freeFunPtr;
    }

    bool isCheckBounds;
    bool isAutoFree;

    this(T* t, size_t size, F freeFunPtr = null, bool isAutoFree = true, bool isCheckBounds = true) @nogc nothrow pure
    {
        assert(size > 0);
        _ptr = t;
        _size = size;
        this.freeFunPtr = freeFunPtr;
        this.isAutoFree = isAutoFree;
        this.isCheckBounds = isCheckBounds;
    }

    alias value this;

    @disable this(ref return scope Ptr!T rhs)
    {
    }

    ~this() @nogc nothrow
    {
        if (isAutoFree)
        {
            free;
        }
    }

    protected void free() @nogc nothrow
    {
        assert(!_freed, "Memory pointer has already been freed");
        _freed = true;
        _size = 0;
        if (freeFunPtr)
        {
            bool isFreed = freeFunPtr(cast(void*) _ptr);
            assert(isFreed, "Memory pointer not deallocated correctly");
        }
        _ptr = null;
    }

    size_t base() @nogc nothrow
    {
        return cast(size_t) _ptr;
    }

    size_t end() @nogc nothrow
    {
        return base + _size;
    }

    protected T* index(size_t i) @nogc nothrow
    {
        if (isCheckBounds)
        {
            const endAddr = base + T.sizeof * i;
            if (endAddr >= end)
            {
                //TODO
                assert(false, "Index is out of bounds");
            }
        }
        return &_ptr[i];
    }

    T opIndex(size_t i) @nogc nothrow
    {
        return *(index(i));
    }

    T value()
    {
        return opIndex(0);
    }

    T* get()
    {
        return _ptr;
    }

    // a[i] = v
    void opIndexAssign(T value, size_t i) @nogc nothrow
    {
        *(index(i)) = value;
    }

    private void opAssign(Ptr);

    size_t size() @nogc nothrow
    {
        return _size;
    }
}
