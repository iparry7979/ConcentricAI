require("node.nut");

class linkedList
{
	headNode = null;
	size = 0;
	currentItem = null;
	constructor()
	{
		headNode = null;
		size = 0;
	}
}

function linkedList::Add(item)
{
	local n = node(item);
	if (headNode == null)
	{
		headNode = n;
	}
	else
	{
		local currentNode = headNode;
		local previousNode = null;
		while (currentNode != null)
		{
			previousNode = currentNode;
			currentNode = currentNode.GetNext();
		}
		previousNode.SetNext(n);
	}
}

function linkedList::IsEnd()
{
	if (currentItem == null) return true;
	return currentItem.GetNext() == null;
	//return false;
}

function linkedList::Start()
{
	currentItem = headNode;
	local rtn = null;
	if (headNode != null)
	{
		rtn = headNode.GetItem();
	}
	return rtn;
}

function linkedList::Next()
{
	currentItem = currentItem.GetNext();
	local rtn = null;
	if (currentItem != null)
	{
		rtn = currentItem.GetItem();
	}
	return rtn;
}

function linkedList::AppendList(list)
{
	local cur = list.Start();
	while (!list.IsEnd())
	{
		this.Add(cur);
		cur = list.Next();
	}
}

