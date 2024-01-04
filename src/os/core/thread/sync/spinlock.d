/**
 * Authors: initkfs
 */
module os.core.thread.sync.spinlock;

struct Lock
{
    bool locked;
}

extern (C) int swap_atomic(Lock*);

void initLock(scope Lock* lock) @safe
{
    lock.locked = false;
}

void acquire(Lock* lock)
{
    while (true)
    {
        if (!swap_atomic(lock))
        {
            break;
        }
    }
}

void free(scope Lock* lock) @safe
{
    initLock(lock);
}
