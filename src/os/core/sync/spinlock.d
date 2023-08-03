/**
 * Authors: initkfs
 */
module os.core.sync.spinlock;

import interrupt;

struct Lock
{
    bool locked;
}

extern (C) int swapAtomic(Lock*);

void initLock(Lock* lock)
{
    lock.locked = false;
}

void acquire(Lock* lock)
{
    while (true)
    {
        if (!swapAtomic(lock))
        {
            break;
        }
    }
}

void free(Lock* lock)
{
    initLock(lock);
}

void nativeLock()
{
    setMStatus(getMStatus & ~MSTATUS_MIE );
}

void nativeUnlock()
{
    setMStatus(getMStatus | MSTATUS_MIE );
}
