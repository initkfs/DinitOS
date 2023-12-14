/**
 * Authors: initkfs
 */
module os.core.support.inspector;

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
