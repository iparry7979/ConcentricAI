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
		route.BuildRoute();
		if (!route.BuildStations()) return false;
		if (!route.BuildDepot()) return false;
		local totalCost = acc.GetCosts() + route.GetNewVehicleValue();
		local exec = AIExecMode();
		if (fPlanner.CanIBuildThisRoute(totalCost))
		{
			route.InitialiseRoute();
			if (!route.BuildStations()) return false;
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
	local financialFail = false;
	local success = false;
	foreach (t1, pop1 in towns)
	{
		local potentialDestinations = AITownList();
		potentialDestinations.Valuate(AITown.GetPopulation);
		potentialDestinations.Sort(AIList.SORT_BY_VALUE, false);
		potentialDestinations.KeepAboveValue(300);
		potentialDestinations.RemoveList(excludedTowns);
		if (newRoute.FindPathBetweenOneGivenTown(t1, potentialDestinations, 75, 25))
		{
			success = true;
			local acc = AIAccounting();
			local test = AITestMode();
			newRoute.BuildRoute();
			if (!newRoute.BuildStations()) success = false;
			if (!newRoute.BuildDepot()) success = false;
			local totalCost = acc.GetCosts() + newRoute.GetNewVehicleValue();
			local exec = AIExecMode();
			if (!fPlanner.CanIBuildThisRoute(totalCost))
			{ 
				success = false;
				financialFail = true;
			}
			if (success)
			{
				newRoute.InitialiseRoute();
				if (!newRoute.BuildStations()) success = false;
				if (!newRoute.BuildDepot()) success = false;
				if (!newRoute.AddService()) success = false;
				lastExpansion = AIController.GetTick();
				AddRoute(newRoute);
				ConsolidateRoutes(newRoute);
				//AILog.Info("Expanding");
				return success;
			}
		}
	}
	//AILog.Info("Unable To Expand");
	if (!financialFail)
	{
		canExpand = false;
	}
	return success;
}

