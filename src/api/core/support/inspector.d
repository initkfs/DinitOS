/**
 * Authors: initkfs
 */
module api.core.support.inspector;

private __gshared
{
    //TODO messages
	bool errors;
}

bool isErrors()
{
	return errors;
}

void setErrors()
{
	errors = true;
}
