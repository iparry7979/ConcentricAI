require ("network.nut")
require ("roadRoute.nut");

class roadNetwork extends network
{
	
}

function roadNetwork::Initialise(excludedTowns, centreTile)
{
	//base.Initialise();
	established = AIController.GetTick();
	lastExpansion = established;
	local route = roadRoute();
	//if (route.FindPathBetweenRandomTowns(excludedTowns))
	if (route.connectTownsAroundTile(excludedTowns, centreTile))
	{
		local acc = AIAccounting();
		local test = AITestMode();
		local x = route.BuildRoute();
		if (!route.BuildNodes(null, null, 0)) return false;
		if (!route.BuildDepot()) return false;
		if (route.GetNewVehicleValue() == null)
		{
			return false;
		}
		local totalCost = acc.GetCosts() + route.GetNewVehicleValue();
		local exec = AIExecMode();
		if (fPlanner.CanIBuildThisRoute(totalCost))
		{
			route.InitialiseRoute();
			if (!route.BuildNodes(null, null, 1)) return false;
			if (!route.BuildDepot()) return false;
			if (!route.AddService()) return false;
		}
		distanceSquareFromHQ = route.distanceFromHQ;
		AddRoute(route);	
	}
	return true;
}

function roadNetwork::Expand(excludedTowns)
{
	//temp code
	local r = routes[0];
	r.OutputPath();
	//end temp code
	if (AIController.GetTick() - lastExpansion < expansionWaitPeriod)
	{
		return false;
	}
	if (!canExpand)
	{
		return false;
	}
	local newRoute = roadRoute();
	local stations = GetAllStations();
	local towns = utilities.MapStationListToTownList(stations);
	local nodes = GetAllNodes();
	local financialFail = false;
	local success = false;
	for (local i = 0; i < nodes.len(); i++)
	{
		local t1 = nodes[i].town;
		newRoute.AddNode(nodes[i]);
		local potentialDestinations = AITownList();
		potentialDestinations.Valuate(AITown.GetPopulation);
		potentialDestinations.Sort(AIList.SORT_BY_VALUE, false);
		potentialDestinations.KeepAboveValue(300);
		potentialDestinations.RemoveList(excludedTowns);
		potentialDestinations.RemoveList(nodes[i].ExhaustedTownsAsList());
		if (newRoute.FindPathBetweenOneGivenTown(t1, potentialDestinations, 75, 25))
		{
			success = true;
			newRoute.nodes = [];
			local acc = AIAccounting();
			local test = AITestMode();
			newRoute.BuildRoute();
			local existingNode1 = GetNodeContainingTown(newRoute.startTown);
			local existingNode2 = GetNodeContainingTown(newRoute.endTown);
			if (!newRoute.BuildNodes(existingNode1, existingNode2, 0)) success = false;
			if (!newRoute.BuildDepot()) success = false;
			local totalCost = acc.GetCosts() + newRoute.GetNewVehicleValue();
			local exec = AIExecMode();
			if (!fPlanner.CanIBuildThisRoute(totalCost))
			{ 
				success = false;
				financialFail = true;
				AILog.Info("FinancialFail");
			}
			if (success)
			{
				newRoute.InitialiseRoute();
				if (!newRoute.BuildNodes(existingNode1, existingNode2, 1)) success = false;
				if (!newRoute.BuildDepot()) success = false;
				if (!newRoute.AddService()) success = false;
				lastExpansion = AIController.GetTick();
				AddRoute(newRoute);
				ConsolidateRoutes(newRoute);
				return success;
			}
			
		}
	}
	if (!financialFail)
	{
		canExpand = false;
		
	}
	return success;
}

