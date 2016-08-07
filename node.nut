class node
{
	item = null;
	next = null;
	constructor(i)
	{
		item = i;
		next = null;
	}
}

function node::GetNext()
{
	return next;
}

function node::SetNext(n)
{
	if (!(n instanceof node))
	{
		AILog.Warning("Error, Item must be a node");
		return;
	}
	next = n;
}

function node::GetItem()
{
	return item;
}

function node::SetItem(i)
{
	item = i;
}