/**
 * Authors: initkfs
 */
module os.core.dev.ns16550a;

import Volatile = os.core.volatile;

__gshared ubyte* uartAddr = cast(ubyte*) 0x10000000;

void writeTx(ubyte b) @nogc nothrow
{
    Volatile.save(uartAddr, b);
}
