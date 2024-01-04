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

        println("Panic! ", message, ": ", file);
        //TODO halt
        while (true)
        {
        }
    }
}
