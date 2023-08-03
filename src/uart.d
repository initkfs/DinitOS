/**
 * Authors: initkfs
 */
module uart;

import Ns16650a = os.core.io.ns16550a;

void printElem(char c) {
    Ns16650a.writeTx(c);
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