/**
 * Authors: initkfs
 */
module api.core.thread.sync.spinlock;

import Externs = api.core.thread.externs;

struct Lock
{
    enum Status
    {
        unlock = 0,
        lock = 1
    }

    private
    {
        int lockStatus = Status.unlock;
    }

    alias checkIsLocked this;

    protected bool checkIsLocked()
    {
        if (isLocked)
        {
            return true;
        }
        return false;
    }

    bool isLocked() const pure @safe
    {
        return lockStatus == Status.lock;
    }

    bool isUnlocked() const pure @safe
    {
        return lockStatus == Status.unlock;
    }

    void acquire() @safe
    {
        //TODO halt if locked
        const ret = Externs.swap_acquire(&lockStatus);
        assert(ret);
    }

    void release() @safe
    {
        const ret = Externs.swap_release(&lockStatus);
        assert(!ret);
    }
}

unittest
{
    Lock lock;
    assert(lock.isUnlocked);
    assert(!lock.isLocked);

    lock.acquire;
    assert(lock.isLocked);
    assert(!lock.isUnlocked);

    lock.release;
    assert(lock.isUnlocked);
    assert(!lock.isLocked);
}
