require ("builder.nut");

class roadStationBuilder extends builder
{
	
}

/*function roadStationBuilder::BuildStationNearTile(tile1, 1)
{
  base.BuildStationNearTile(tile1, 1);
}*/

function roadStationBuilder::Build(tile)
{
	local success = false;
	if (AIRoad.IsRoadTile(tile))
	{
		local frontTile = utilities.GetPreviousTileX(tile);
		if (frontTile != null)
		{
			success = AIRoad.BuildDriveThroughRoadStation(tile, frontTile, AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
			if (success)
			{
				return tile;
			}
		}
		local frontTile = utilities.GetPreviousTileY(tile);
		if (frontTile != null)
		{
			success = AIRoad.BuildDriveThroughRoadStation(tile, frontTile, AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
			if (success)
			{
				return tile;
			}
		}
	}
	return null;
}

function roadStationBuilder::stationExists(tile)
{
	
}