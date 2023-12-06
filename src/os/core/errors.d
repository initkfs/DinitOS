/**
 * Authors: initkfs
 */
module os.core.errors;

void panic(const string message, const string file = __FILE__, const int line = __LINE__)
{
    import uart;

    //TODO line
    println("Panic: ", message, ": ", file);
    while (1)
    {
    }
}
