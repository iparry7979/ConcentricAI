import("pathfinder.road", "RoadPathFinder", 3);
require("roadRoute.nut");
require("roadNetwork.nut");
require("fatController.nut");
require("pathSearcher.nut");
require("constants.nut");

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
  local firstNamesMale = constants.firstNameMale;
  local firstNamesFemale = constants.firstNameFemale;
  local lastNames = constants.lastName;
  local firstName = "";
  local g = AIBase.RandRange(2);
  if (g == 0)
  {
  	AICompany.SetPresidentGender(AICompany.GENDER_MALE);
  	local x = AIBase.RandRange(firstNamesMale.len());
  	firstName = firstNamesMale[x];
  }
  else
  {
  	AICompany.SetPresidentGender(AICompany.GENDER_FEMALE);
  	local x = AIBase.RandRange(firstNamesFemale.len());
  	firstName = firstNamesFemale[x];
  }
  local y = AIBase.RandRange(lastNames.len());
  local fullName = firstName + " " + lastNames[y];
  local presidentName = fullName;
  local companyName = "Concentric Transport";
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