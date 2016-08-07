import("pathfinder.road", "RoadPathFinder", 3);
require("roadRoute.nut");
require("roadNetwork.nut");
require("fatController.nut");
require("pathSearcher.nut");

class ConcentricAI extends AIController 
{
    fc = null;
	loadedGame = false;
 	//function Start();
}

function ConcentricAI::Start()
{
	//TestPathFinder();
	
	if (!loadedGame)
	{
		Initialise();
		fc = fatController();
		fc.Initialise();
	}
	while (true)
	{
		fc.RunControlLoop();
		this.Sleep(10);
	}
}

function ConcentricAI::Initialise()
{
  local companyName = "Concentric Transport";
  local presidentName = "Mike Maxwell";
  if (!AICompany.SetName(companyName))
  {
    local i = 2;
		while (!AICompany.SetName(companyName + i))
		{
			i = i + 1;
		}
  }
  AICompany.SetPresidentName(presidentName);
}

function ConcentricAI::Save()
{
	local sTable = fc.GetSaveTable();
	return fc.GetSaveTable();
}

function ConcentricAI::Load(version, data)
{
	fc = fatController();
	fc.LoadFromTable(data);
	loadedGame = true;
}

function ConcentricAI::TestPathCreate()
{
	local tile1 = utilities.GetRandomTile();
	local tile2 = utilities.GetRandomTile();
	local ps = pathSearcher(tile1, tile2);
	local path = ps.BuildPath(tile1);
	pathSearcher.OutputPath(path);
}

function ConcentricAI::FindPathBetweenTwoGivenTowns(t1, t2)
{
	local success = false;
	local path = false;
	if (!success)
	{
		if (t1 != t2)
		{
			local tile1 = AITown.GetLocation(t1);
			local tile2 = AITown.GetLocation(t2);
			if (AITile.GetDistanceManhattanToTile(tile1, tile2) < 100)
			{
				local pathfinder = RoadPathFinder();
				pathfinder.cost.turn = 2;
				AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);
				pathfinder.InitializePath([tile1], [tile2]);
				//while (!path)
				//{
				while (path == false)
				{
					path = pathfinder.FindPath(300);
					AIController.Sleep(1);
				}
				//}
				if (path != false)
				{
					success = true;
				}
			}		  
		}
	}
	return success;
}