/**
 * Authors: initkfs
 */
module os.core.sync.spinlock;

import Interrupts = os.core.arch.riscv.minterrupts;

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
    Interrupts.status(Interrupts.status & ~Interrupts.MSTATUS_MIE );
}

void nativeUnlock()
{
    Interrupts.status(Interrupts.status | Interrupts.MSTATUS_MIE );
}
