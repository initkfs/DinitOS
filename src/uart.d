/**
 * Authors: initkfs
 */
module uart;

import Ns16650a = os.core.io.ns16550a;

void print(char c) {
    Ns16650a.writeTx(c);
}

void print(string s) {
    foreach (c; s) {
        print(c);
    }
}

void printa(Args...)(Args args) {
    foreach (arg; args) {
        print(arg);
    }
}

void println(Args...)(Args args) {
    printa(args, '\n');
}