require("utilities.nut");
require ("linkedList.nut");

class pathSearcher
{
	fromTile = null;
	toTile = null;
	startDirection = "";
	firstSide = true;
	constructor(from, to)
	{
		fromTile = from;
		toTile = to;
		firstSide = true;
		if (AIMap.GetTileY(fromTile) <= AIMap.GetTileY(toTile))
		{
			startDirection = "N";
		}
		else
		{
			startDirection = "S";
		}
	}
}

function pathSearcher::FindPath()
{
	local currentTurnPoint = fromTile;
	if (AIMap.GetTileX(currentTurnPoint) <= AIMap.GetTileX(toTile))
	{
		while (AIMap.GetTileX(currentTurnPoint) <= AIMap.GetTileX(toTile))
		{
			local path = BuildPath(fromTile, toTile, currentTurnPoint);
			if (CheckPath(path))
			{
				return path;
			}
			if (AIMap.GetTileX(currentTurnPoint) < AIMap.GetTileX(toTile))
			{
				currentTurnPoint = utilities.GetNextTileX(currentTurnPoint);
			}
		}
	}
	else
	{
		while (AIMap.GetTileX(currentTurnPoint) >= AIMap.GetTileX(toTile))
		{
			local path = BuildPath(fromTile, toTile, currentTurnPoint);
			if (CheckPath(path))
			{
				return path;
			}
			if (AIMap.GetTileX(currentTurnPoint) > AIMap.GetTileX(toTile))
			{
				currentTurnPoint = utilities.GetPreviousTileX(currentTurnPoint);
			}
		}
	}
	currentTurnPoint = fromTile;
	if (startDirection == "N") startDirection = "S";
	if (startDirection == "S") startDirection = "N";
	firstSide = false;
	if (currentTurnPount.GetTileY() <= toTile.GetTileY())
	{
		while (AIMap.GetTileY(currentTurnPoint) <= AIMap.GetTileY(toTile))
		{
			local path = BuildPath(fromTile, toTile, currentTurnPoint);
			if (CheckPath(path))
			{
				return path;
			}
			if (AIMap.GetTileY(currentTurnPoint) < AIMap.GetTileY(toTile))
			{
				currentTurnPoint = utilities.GetNextTileY(currentTurnPoint);
			}
		}
	}
	else
	{
		while (AIMap.GetTileY(currentTurnPoint) >= AIMap.GetTileY(toTile))
		{
			local path = BuildPath(fromTile, toTile, currentTurnPoint);
			if (CheckPath(path))
			{
				return path;
			}
			if (AIMap.GetTileY(currentTurnPoint) > AIMap.GetTileY(toTile))
			{
				currentTurnPoint = utilities.GetPreviousTileY(currentTurnPoint);
			}
		}
	}
	return null;
}

function pathSearcher::BuildPath(turnPoint)
{
	local path = linkedList();
	local p = BuildStraightPath(fromTile, turnPoint);
	path.AppendList(p);
	local secondTurnPoint = null;
	if (fromTile == turnPoint)
	{
		if (firstSide)
		{
			secondTurnPoint = AIMap.GetTileIndex(AIMap.GetTileX(turnPoint), AIMap.GetTileY(toTile));
		}
		else
		{
			secondTurnPoint = AIMap.GetTileIndex(AIMap.GetTileX(toTile), AIMap.GetTileY(turnPoint));
		}
	}
	else
	{
		if (AIMap.GetTileX(turnPoint) == AIMap.GetTileX(fromTile))
		{
			secondTurnPoint = AIMap.GetTileIndex(AIMap.GetTileX(toTile), AIMap.GetTileY(turnPoint));
		}
		else
		{
			secondTurnPoint = AIMap.GetTileIndex(AIMap.GetTileX(turnPoint), AIMap.GetTileY(toTile));
		}
	}
	path.AppendList(BuildStraightPath(turnPoint, secondTurnPoint));
	path.AppendList(BuildStraightPath(secondTurnPoint, toTile));
	path.Add(toTile);
	return path;
}

function pathSearcher::BuildStraightPath(from, to)
{
	if (AIMap.GetTileX(from) != AIMap.GetTileX(to) && AIMap.GetTileY(from) != AIMap.GetTileY(to))
	{
		//return null if there is no straight line between fromTile & toTile
		return null;
	}
	local direction = null;
	//figure out which direction we need to travel
	if (utilities.IsDueNorthOf(to, from)) direction = "N";
	if (utilities.IsDueSouthOf(to, from)) direction = "S";
	if (utilities.IsDueEastOf(to, from)) direction = "E";
	if (utilities.IsDueWestOf(to, from)) direction = "W";
	//Build the path
	local path = linkedList();
	path.Add(from)
	local currentTile = from;
	while (currentTile != to)
	{
		local nextTile = null;
		if (direction == "N") nextTile = utilities.GetNextTileY(currentTile);
		if (direction == "S") nextTile = utilities.GetPreviousTileY(currentTile);
		if (direction == "E") nextTile = utilities.GetNextTileX(currentTile);
		if (direction == "W") nextTile = utilities.GetPreviousTileX(currentTile);
		path.Add(nextTile);
		currentTile = nextTile;
	}
	return path;
}

function pathSearcher::OutputPath(path)
{
	local currentTile = path.Start();
	while (!path.IsEnd())
	{
		currentTile = path.Next();
	}
}