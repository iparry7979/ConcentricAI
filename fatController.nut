require ("network.nut");
require ("roadNetwork.nut");
require ("financialPlanner.nut");

class fatController
{
	networks = [];
	lastAction = 0;
	lastExpansion = 0;
	networkBuildWaitTime = 1000;
	anyActionWaitTime = 500;
	explorationHorizon = 0;
	fPlanner = null;
	centreTile = null;
	constructor()
	{
		this.networks = [];
		this.lastAction  = 0;
		this.lastExpansion = 0;
		local bwt = ConcentricAI.GetSetting("RouteWait");
		this.networkBuildWaitTime = bwt*18;
		local awt = ConcentricAI.GetSetting("ActionWait");
		this.anyActionWaitTime = awt*18;
		this.explorationHorizon = 0;
		this.fPlanner = financialPlanner(this);
	}
}

function fatController::Initialise()
{
	BuildHQ();
	local n1 = roadNetwork(fPlanner);
	local townsOnNetwork = GetAllTownsOnABusNetwork();
	if (n1.Initialise(townsOnNetwork, centreTile))
	{
		lastAction = AIController.GetTick();
		lastExpansion = lastAction;
		explorationHorizon = n1.distanceSquareFromHQ;
		AddNetwork(n1);
	}

}

function fatController::RunControlLoop()
{
	MaintainNetworks();
	
	if (!AnyActionWaitTimeElapsed())
	{
		return;
	}
	if (UpgradeNetworks())
	{
		lastAction = AIController.GetTick();
		return;
	}
	if (!NetworkBuildWaitTimeElapsed())
	{
		return;
	}
	if (ExpandNetworks())
	{
		lastAction = AIController.GetTick();
		lastExpansion = lastAction;
		return;
	}
	AILog.Info("Could not expand networks. Searching for new Networks.");
	SearchForNewNetworks();
	lastAction = AIController.GetTick();
	lastExpansion = lastAction;
}

function fatController::NetworkBuildWaitTimeElapsed()
{
	return AIController.GetTick() - lastExpansion > networkBuildWaitTime;
}

function fatController::AnyActionWaitTimeElapsed()
{
	return AIController.GetTick() - lastAction > anyActionWaitTime;
}

function fatController::MaintainNetworks()
{
	for (local i = 0; i < networks.len(); i++)
	{
		networks[i].Maintain();
	}
}

function fatController::UpgradeNetworks()
{
	local success = false;
	for (local i = 0; i < networks.len(); i++)
	{
		if (!success)
		{
			success = networks[i].Upgrade();
		}
	}
	return success;
}

function fatController::ExpandNetworks()
{
	local success = false;
	for (local i = 0; i < networks.len(); i++)
	{
		if (!success)
		{
			success = networks[i].Expand(GetAllTownsOnABusNetwork());
		}
	}
	if (success)
	{
		AILog.Info("New route built");
	}
	return success;
}

function fatController::SearchForNewNetworks()
{
	local currentTick = AIController.GetTick();
	if (currentTick - lastAction > networkBuildWaitTime)
	{
		local excludedTowns = GetAllTownsOnABusNetwork();
		AddTownsWithinHorizon(excludedTowns);
		local n = roadNetwork(fPlanner);
		if (n.Initialise(excludedTowns, centreTile))
		{
			lastAction = AIController.GetTick();
			AddNetwork(n);
		}
	}
}

function fatController::AddNetwork(n)
{
	utilities.AddItemToArray(networks, n);
}

function fatController::GetAllStations()
{
	local stationList = AIList();
	for (local i = 0; i < networks.len(); i++)
	{
		stationList.AddList(networks[i].GetAllStations());
	}
	return stationList;
}

function fatController::GetAllTownsOnABusNetwork()
{
	local stationList = GetAllStations();
	local busStationList = AIList();
	local currentStation = stationList.Begin();
	while (!stationList.IsEnd())
	{
		local stationID = AIStation.GetStationID(currentStation);
		if (AIStation.HasStationType(stationID, AIStation.STATION_BUS_STOP))
		{
			busStationList.AddItem(currentStation, 0);
		}
		currentStation = stationList.Next();
	}
	local townList = utilities.MapStationListToTownList(busStationList)
	return townList;
}

function fatController::AddTownsWithinHorizon(inList)
{
  local townList = AITownList();
  townList.Valuate(AITown.GetDistanceSquareToTile, centreTile);
  townList.KeepBelowValue(explorationHorizon);
  inList.AddList(townList);
}

function fatController::BuildHQ()
{
  local maxMapSizeX = AIMap.GetMapSizeX();
  local maxMapSizeY = AIMap.GetMapSizeY();
  local HQBuilt = false;
  while (!HQBuilt)
  {
    local x = AIBase.RandRange(maxMapSizeX);
    local y = AIBase.RandRange(maxMapSizeY);
	centreTile = AIMap.GetTileIndex(x,y);
    HQBuilt = AICompany.BuildCompanyHQ(centreTile);
  }	
}

function fatController::GetSaveTable()
{
	local networkTables = [];
	for (local i = 0; i < networks.len(); i++)
	{
		utilities.AddItemToArray(networkTables, networks[i].GetSaveTable());
	}
	local saveTable =
	{
		sNetworks = networkTables
		slastAction = lastAction
		sLastExpansion = lastExpansion
		sNetworkBuildWaitTime = networkBuildWaitTime
		sCentreTile = centreTile
		sAnyActionWaitTime = anyActionWaitTime
	}
	return saveTable;
}

function fatController::LoadFromTable(table)
{
	fPlanner = financialPlanner(this);
	if ("sNetworks" in table)
	{
		local networkTables = table.sNetworks;
		for (local i = 0; i < networkTables.len(); i++)
		{
			local currentNetwork = networkTables[i];
			local n = null;
			if ("sNetworkType" in currentNetwork)
			{
				if (currentNetwork.sNetworkType == 0)
				{
					n = roadNetwork(fPlanner);
				}
			}
			if (n != null)
			{
				n.LoadFromTable(currentNetwork);
				AddNetwork(n);
			}
		}
	}
	if ("sLastExpansion" in table) lastExpansion = table.sLastExpansion;
	if ("sLastAction" in table) lastAction = table.slastAction;
	if ("sNetworkBuildWaitTime" in table) networkBuildWaitTime = table.sNetworkBuildWaitTime;
	if ("sCentreTile" in table) centreTile = table.sCentreTile;
	if ("sAnyActionWaitTime" in table) anyActionWaitTime = table.sAnyActionWaitTime;
}
