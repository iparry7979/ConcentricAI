require("builder.nut");

class roadDepotBuilder extends builder
{

}

/* Builds road depot next to the given road
 * tile if possible. Returns TileIndex of
 * depot or null if fails.
 */
function roadDepotBuilder::Build(roadTile)
{
	if (roadTile == null)
	{
		return null;
	}
	local minHeight = AITile.GetMinHeight(roadTile);
	local maxHeight = AITile.GetMaxHeight(roadTile);
	if (minHeight != maxHeight)
	{
		return null;
	}
	if (utilities.GetPreviousTileX(roadTile) != null)
	{
		if (AIRoad.BuildRoadDepot(utilities.GetPreviousTileX(roadTile), roadTile))
		{
			AIRoad.BuildRoad(utilities.GetPreviousTileX(roadTile), roadTile);
			return utilities.GetPreviousTileX(roadTile);
		}
	}
	if (utilities.GetNextTileX(roadTile) != null)
	{
		if (AIRoad.BuildRoadDepot(utilities.GetNextTileX(roadTile), roadTile))
		{
			AIRoad.BuildRoad(utilities.GetNextTileX(roadTile), roadTile);
			return utilities.GetNextTileX(roadTile);
		}
	}
	if (utilities.GetPreviousTileY(roadTile) != null)
	{
		if (AIRoad.BuildRoadDepot(utilities.GetPreviousTileY(roadTile), roadTile))
		{
			AIRoad.BuildRoad(utilities.GetPreviousTileY(roadTile), roadTile);
			return utilities.GetPreviousTileY(roadTile);
		}
	}
	if (utilities.GetNextTileY(roadTile) != null)
	{
		if (AIRoad.BuildRoadDepot(utilities.GetNextTileY(roadTile), roadTile))
		{
			AIRoad.BuildRoad(utilities.GetNextTileY(roadTile), roadTile);
			return utilities.GetNextTileY(roadTile);
		}
	}
	return null;
}