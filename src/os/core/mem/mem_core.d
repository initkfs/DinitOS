module os.core.mem.mem_core;

struct Ptr(T, F = bool function(void*) @nogc nothrow)
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

    bool isFreed() @nogc nothrow
    {
        return _freed;
    }

    protected void free() @nogc nothrow
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

    protected T* index(size_t i) @nogc nothrow
    {
        if (isCheckBounds)
        {
            //TODO
            assert(i < capacity, "Index is out of bounds");
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

    size_t sizeBytes() @nogc nothrow
    {
        return _sizeInBytes;
    }

    size_t capacity() @nogc nothrow
    {
        return _capacity;
    }
}
