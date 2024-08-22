/**
 * Authors: initkfs
 */
module api.core.errors;

void panic(const string message = "Assertion failure", const string file = __FILE__, const int line = __LINE__)
{
    panic(false, message, file, line);
}

void panic(lazy bool expression, const string message = "Assertion failure", const string file = __FILE__, const int line = __LINE__)
{
    if (!expression())
    {
        import api.core.io.cstdio;
        import Str = api.core.strings.str;

        char[64] buff = 0;
        const buffPtr = Str.atoa(line, buff);
        println("Panic! ", message, ": ", file, ":", buffPtr);
        //TODO halt
        import Interrupts = api.core.arch.riscv.interrupts;

        Interrupts.mInterruptsDisable;

        while (true)
        {
        }
    }
}
