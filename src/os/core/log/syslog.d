/**
 * Authors: initkfs
 */
module os.core.log.syslog;

import Inspector = os.core.support.inspector;
import os.core.log.logger_core;

import std.traits;

private __gshared
{
    LogLevel logLevel;
    bool load;
}

//TODO versions
protected
{
    import Ns16650a = os.core.dev.ns16550a;

    void logWrite(ubyte b)
    {
        Ns16650a.writeTx(b);
    }

    void logWrite(string s)
    {
        foreach (ch; s)
        {
            logWrite(ch);
        }
    }
}

void setLoad(bool isLoad) @nogc nothrow
{
    load = isLoad;
}

bool isLoad() @nogc nothrow
{
    return load;
}

void setLogLevel(LogLevel level = LogLevel.all) @nogc nothrow
{
    logLevel = level;
}

string getLogLevelName() @nogc nothrow
{
    return getLevelName(logLevel);
}

bool isErrorLevel() @nogc nothrow
{
    return isForSyslogLevel(LogLevel.error);
}

bool isWarnLevel() @nogc nothrow
{
    return isForSyslogLevel(LogLevel.warn);
}

bool isInfoLevel() @nogc nothrow
{
    return isForSyslogLevel(LogLevel.info);
}

bool isTraceLevel() @nogc nothrow
{
    return isForSyslogLevel(LogLevel.trace);
}

bool isForSyslogLevel(LogLevel level) @nogc nothrow
{
    return isForLogLevel(level, logLevel);
}

private void log(LogLevel level, string message, string file, int line)
{
    if (level == LogLevel.error && !Inspector.isErrors)
    {
        Inspector.setErrors;
    }

    if (!isForLogLevel(level, logLevel))
    {
        return;
    }

    immutable levelName = getLevelName(level);
    immutable spaceChar = ' ';

    logWrite(levelName);
    logWrite(":");
    logWrite(spaceChar);
    logWrite(message);
    logWrite(spaceChar);
    logWrite(file);
    logWrite('\n');

    //TODO line;
}

private void logf(T)(LogLevel level, string pattern, T[] args,
    string file, int line)
{
    if (!isForLogLevel(level, logLevel))
    {
        return;
    }

    //TODO format
    log(level, pattern, file, line);
}

void tracef(T)(string pattern, T[] args, const string file = __FILE__, const int line = __LINE__)
{
    logf(LogLevel.trace, pattern, args, file, line);
}

void trace(string message, const string file = __FILE__, const int line = __LINE__)
{
    log(LogLevel.trace, message, file, line);
}

// void trace(char* message, const string file = __FILE__, const int line = __LINE__)
// {
//     trace(Strings.toString(message), file, line);
// }

void infof(T)(string pattern, T[] args, const string file = __FILE__, const int line = __LINE__)
{
    logf(LogLevel.info, pattern, args, file, line);
}

void info(string message, const string file = __FILE__, const int line = __LINE__)
{
    log(LogLevel.info, message, file, line);
}

// void info(char* message, const string file = __FILE__, const int line = __LINE__)
// {
//     info(Strings.toString(message), file, line);
// }

void warnf(T)(string pattern, T[] args, const string file = __FILE__, const int line = __LINE__)
{
    logf(LogLevel.warn, pattern, args, file, line);
}

void warn(string message, const string file = __FILE__, const int line = __LINE__)
{
    log(LogLevel.warn, message, file, line);
}

// void warn(char* message, const string file = __FILE__, const int line = __LINE__)
// {
//     warn(Strings.toString(message), file, line);
// }

void errorf(T)(string pattern, T[] args, const string file = __FILE__, const int line = __LINE__)
{
    logf(LogLevel.error, pattern, args, file, line);
}

void error(string message, const string file = __FILE__, const int line = __LINE__)
{
    log(LogLevel.error, message, file, line);
}

// void error(char* message, const string file = __FILE__, const int line = __LINE__)
// {
//     error(Strings.toString(message), file, line);
// }
