/**
 * Authors: initkfs
 */
module uart;

import object;

struct Ns16650a(ubyte* base) {
    static void tx(ubyte b) {
        volatileStore(base, b);
    }
}

alias Uart = Ns16650a!(cast(ubyte*) 0x10000000);

void printElem(char c) {
    Uart.tx(c);
}

void printElem(string s) {
    foreach (c; s) {
        printElem(c);
    }
}

void print(Args...)(Args args) {
    foreach (arg; args) {
        printElem(arg);
    }
}

void println(Args...)(Args args) {
    print(args, '\n');
}