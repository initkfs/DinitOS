/**
 * Authors: initkfs
 */
module os.core.errors;

void panic(const string message = "Assertion failure", const string file = __FILE__, const int line = __LINE__)
{
    panic(false, message, file, line);
}

void panic(lazy bool expression, const string message = "Assertion failure", const string file = __FILE__, const int line = __LINE__)
{
    if (!expression())
    {
        import os.core.cstd.io.cstdio;
        import Str = os.core.cstd.strings.str;

        char[64] buff = 0;
        const buffPtr = Str.atoa(line, buff);
        println("Panic! ", message, ": ", file, ":", buffPtr);
        //TODO halt
        while (true)
        {
        }
    }
}
