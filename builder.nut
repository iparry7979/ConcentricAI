/* Builder Class is designed as an abstract class. It should not be
instantiated. Classes extending this class should override the Build
Method. */

require("utilities.nut");

class builder
{
  site = null; //The tile at which to build
	length = 0; //the X-dimension of the item to build
	width = 0; //The Y-Dimension of the item to build
	townServiced = null; //The town this station is servicing if applicable
	industryServiced = null; //The industry this station is servicing if applicable
}

/* Build the item within maxDistance squares of tile 
 * Traverses increaing concentric squares around the tile looking for
 * an appropriate build site until a build site is found or the
 * maximum distance is reached.
*/
function builder::BuildNearTile(tile, maxDistance)
{
	//TODO: refactor to allow start corner to be off map
	local existingStation = GetExistingStationNearTile(tile, maxDistance);
	if (existingStation != null)
	{
		return existingStation;
	}
	for (local i = 0; i <= maxDistance; i++)
	{
		/* Start in the top left corner of the square */
		local startCorner = utilities.GetTileRelativeToTile(tile, -i, -i);
		/* Traverse the top of the square */
		if (startCorner != null)
		{
			for (local j = 0; j <= 2 * i; j++)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, j, 0);
				if (tileToCheck != null)
				{
					if (Build(tileToCheck) != null) return tileToCheck;
				}
			}
			/* Traverse the right side of the square */
			for (local j = 1; j <= 2 * i; j++)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, 2 * i, j);
				if (tileToCheck != null)
				{					
					if (Build(tileToCheck) != null) return tileToCheck;
				}
			}
			/* Traverse the bottom of the square */
			for (local j = (2 * i) - 1; j >= 0; j--)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, j, 2 * i);
				if (tileToCheck != null)
				{					
					if (Build(tileToCheck) != null) return tileToCheck;
				}
			}
			/* Traverse the left side of the square */
			for (local j = (2 * i) - 1; j >= 1; j--)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, 0, j);
				if (tileToCheck != null)
				{					
					if (Build(tileToCheck) != null) return tileToCheck;
				}
			}
		}
	}
	return null;
}

function builder::GetExistingStationNearTile(tile, maxDistance)
{
	for (local i = 0; i <= maxDistance; i++)
	{
		/* Start in the top left corner of the square */
		local startCorner = utilities.GetTileRelativeToTile(tile, -i, -i);
		/* Traverse the top of the square */
		if (startCorner != null)
		{
			for (local j = 0; j <= 2 * i; j++)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, j, 0);
				if (tileToCheck != null)
				{
					if (AITile.IsStationTile(tileToCheck))
					{
						local stationID = AIStation.GetStationID(tileToCheck);
						if (AIStation.HasStationType(stationID, AIStation.STATION_BUS_STOP))
						{
							return tileToCheck;
						}
					}
				}
			}
			/* Traverse the right side of the square */
			for (local j = 1; j <= 2 * i; j++)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, 2 * i, j);
				if (tileToCheck != null)
				{					
					if (AITile.IsStationTile(tileToCheck))
					{
						local stationID = AIStation.GetStationID(tileToCheck);
						if (AIStation.HasStationType(stationID, AIStation.STATION_BUS_STOP))
						{
							return tileToCheck;
						}
					}
				}
			}
			/* Traverse the bottom of the square */
			for (local j = (2 * i) - 1; j >= 0; j--)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, j, 2 * i);
				if (tileToCheck != null)
				{					
					if (AITile.IsStationTile(tileToCheck))
					{
						local stationID = AIStation.GetStationID(tileToCheck);
						if (AIStation.HasStationType(stationID, AIStation.STATION_BUS_STOP))
						{
							return tileToCheck;
						}
					}
				}
			}
			/* Traverse the left side of the square */
			for (local j = (2 * i) - 1; j >= 1; j--)
			{
				local tileToCheck = utilities.GetTileRelativeToTile(startCorner, 0, j);
				if (tileToCheck != null)
				{					
					if (AITile.IsStationTile(tileToCheck))
					{
						local stationID = AIStation.GetStationID(tileToCheck);
						if (AIStation.HasStationType(stationID, AIStation.STATION_BUS_STOP))
						{
							return tileToCheck;
						}
					}
				}
			}
		}
	}
	return null;
}

function builder::BuildAlongPath(path)
{
	while (path != null)
	{
		local tile = path.GetTile();
		local resultTile = Build(tile);
		if (resultTile != null)
		{
			return resultTile;
		}
		local par = path.GetParent();
		path = par;
	}
	return false;
}

/* Function should be overridden by sub classes */
function builder::Build(tile)
{
	AILog.Warning("The Build Function has not been overridden");
	return false;
}