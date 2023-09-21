/**
 * Authors: initkfs
 */
module os.core.sync.spinlock;

import interrupt;

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

void free(scope Lock* lock)
{
    initLock(lock);
}

void nativeLock()
{
    set_mstatus(get_mstatus & ~MSTATUS_MIE );
}

void nativeUnlock()
{
    set_mstatus(get_mstatus | MSTATUS_MIE );
}
