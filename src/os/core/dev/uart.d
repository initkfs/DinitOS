/**
 * Authors: initkfs
 */
module os.core.dev.uart;

import Ns16650a = os.core.dev.ns16550a;

void print(char c) @nogc nothrow
{
    Ns16650a.writeTx(c);
}

void print(const(char)[] s) @nogc nothrow
{
    foreach (c; s)
    {
        print(c);
    }
}

