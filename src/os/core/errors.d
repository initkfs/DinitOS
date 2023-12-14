/**
 * Authors: initkfs
 */
module os.core.errors;

void panic(lazy bool expression, const string message = "Assertion failure", const string file = __FILE__, const int line = __LINE__)
{
    if (!expression())
    {
        import uart;

        println("Panic! ", message, ": ", file);
        //TODO halt
        while (true)
        {
        }
    }
}
