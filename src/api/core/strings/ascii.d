/**
 * Authors: initkfs
 */
module api.core.strings.ascii;

enum : char
{
	NUL = '\0',
	BEL = '\a',
	BS = '\b',
	TAB = '\t',
	LF = '\n',
	VT = '\v',
	FF = '\f',
	CR = '\r',
	SPACE = ' '
}

bool isDecimalDigit(const char c) @nogc pure @safe
{
	return c >= '0' && c <= '9';
}

bool isAlpha(const char c) @nogc pure @safe
{
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

bool isSpace(const char c) @nogc pure @safe
{
	return c == SPACE || c == TAB || c == LF || c == VT || c == FF || c == CR;
}
