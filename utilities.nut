class utilities
{
}

function utilities::GetNextTileX(tileIndex)
{
  local mapSizeX = AIMap.GetMapSizeX();
	local mapSizeY = AIMap.GetMapSizeY();
  local tileX = AIMap.GetTileX(tileIndex);
	local tileY = AIMap.GetTileY(tileIndex);
	if (tileX + 1 >= mapSizeX)
	{
	  return null;
	}
	return AIMap.GetTileIndex(tileX + 1, tileY);
}

function utilities::GetPreviousTileX(tileIndex)
{
  local mapSizeX = AIMap.GetMapSizeX();
	local mapSizeY = AIMap.GetMapSizeY();
  local tileX = AIMap.GetTileX(tileIndex);
	local tileY = AIMap.GetTileY(tileIndex);
	if (tileX - 1 < 0)
	{
	  return null;
	}
	return AIMap.GetTileIndex(tileX - 1, tileY);
}

function utilities::GetNextTileY(tileIndex)
{
  local mapSizeX = AIMap.GetMapSizeX();
	local mapSizeY = AIMap.GetMapSizeY();
  local tileX = AIMap.GetTileX(tileIndex);
	local tileY = AIMap.GetTileY(tileIndex);
	if (tileY + 1 >= mapSizeY)
	{
	  return null;
	}
	return AIMap.GetTileIndex(tileX, tileY + 1);
}

function utilities::GetPreviousTileY(tileIndex)
{
  local mapSizeX = AIMap.GetMapSizeX();
	local mapSizeY = AIMap.GetMapSizeY();
  local tileX = AIMap.GetTileX(tileIndex);
	local tileY = AIMap.GetTileY(tileIndex);
	if (tileY - 1 < 0)
	{
	  return null;
	}
	return AIMap.GetTileIndex(tileX, tileY - 1);
}

function utilities::GetTileRelativeToTile(tileIndex, xOffset, yOffset)
{
  local mapSizeX = AIMap.GetMapSizeX();
	local mapSizeY = AIMap.GetMapSizeY();
  local tileX = AIMap.GetTileX(tileIndex);
	local tileY = AIMap.GetTileY(tileIndex);
	tileX = tileX + xOffset;
	tileY = tileY + yOffset;
	local rtn = AIMap.GetTileIndex(tileX, tileY);
	if (!AIMap.IsValidTile(rtn))
	{
	  return null;
	}
	return rtn;
}

function utilities::OutputList(list)
{
	local currentItem = list.Begin();
	if (!list.IsEnd)
	{
		AILog.Info("Empty List");
	}
	while (!list.IsEnd())
	{
		AILog.Info(currentItem);
		currentItem = list.Next();
	}
}

function utilities::OutputArray(array)
{
	if (array.len() == 0)
	{
		AILog.Info("Empty Array");
	}
	for (local i = 0; i < array.len(); i++)
	{
		AILog.Info(array[i]);
	}
}

function utilities::MapStationListToTownList(stationList)
{
	local townList = AIList();
	local currentStation = stationList.Begin();
	while (!stationList.IsEnd())
	{
		local townID = AITile.GetClosestTown(currentStation);
		townList.AddItem(townID, 0);
		currentStation = stationList.Next();
	}
	townList.Valuate(AITown.GetPopulation);
	townList.Sort(AIList.SORT_BY_VALUE, false);
	return townList;
}

function utilities::FindArrayIndexForItem(array, item)
{
	if (array == null)
	{
		return -1;
	}
	for (local i = 0; i < array.len(); i++)
	{
		if (array[i] == item)
		{
			return i;
		}
	}
	return -1;
}

function utilities::AddItemToArray(array, item)
{
	local currentSize = array.len();
	array.resize(currentSize + 1);
	array[currentSize] = item;
}

function utilities::Minimum(a, b)
{
	if (a < b)
	{
		return a;
	}
	return b;	
}

function utilities::IsDueNorthOf(subjectTile, remoteTile)
{
	if (AIMap.GetTileX(subjectTile) != AIMap.GetTileX(remoteTile))
	{
		return false;
	}
	if (AIMap.GetTileY(subjectTile) > AIMap.GetTileY(remoteTile))
	{
		return true;
	}
	return false;
}

function utilities::IsDueSouthOf(subjectTile, remoteTile)
{
	if (AIMap.GetTileX(subjectTile) != AIMap.GetTileX(remoteTile))
	{
		return false;
	}
	if (AIMap.GetTileY(subjectTile) < AIMap.GetTileY(remoteTile))
	{
		return true;
	}
	return false;
}

function utilities::IsDueEastOf(subjectTile, remoteTile)
{
	if (AIMap.GetTileY(subjectTile) != AIMap.GetTileY(remoteTile))
	{
		return false;
	}
	if (AIMap.GetTileX(subjectTile) > AIMap.GetTileX(remoteTile))
	{
		return true;
	}
	return false;
}

function utilities::IsDueWestOf(subjectTile, remoteTile)
{
	if (AIMap.GetTileY(subjectTile) != AIMap.GetTileY(remoteTile))
	{
		return false;
	}
	if (AIMap.GetTileX(subjectTile) < AIMap.GetTileX(remoteTile))
	{
		return true;
	}
	return false;
}

function utilities::GetRandomTile()
{
	local maxMapSizeX = AIMap.GetMapSizeX();
  	local maxMapSizeY = AIMap.GetMapSizeY();
  	local x = AIBase.RandRange(maxMapSizeX);
    local y = AIBase.RandRange(maxMapSizeY);
    return AIMap.GetTileIndex(x, y);
}

function utilities::IsTownInList(townList, townName)
{
	foreach (t2, pop2 in townList)
	{
		local name = AITown.GetName(t2);
		if (name == townName)
		{
			return true;
		}
	}
	return false;
}



