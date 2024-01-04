/**
 * Authors: initkfs
 */
module os.core.uart;

import Ns16650a = os.core.dev.ns16550a;

void print(char c) @nogc nothrow
{
    Ns16650a.writeTx(c);
}

void print(string s) @nogc nothrow
{
    foreach (c; s)
    {
        print(c);
    }
}

void printa(Args...)(Args args) @nogc nothrow
{
    foreach (arg; args)
    {
        print(arg);
    }
}

void println(Args...)(Args args) @nogc nothrow
{
    printa(args, '\n');
}
