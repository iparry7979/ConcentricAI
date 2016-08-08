require ("roadRoute.nut");
require ("linkedList.nut");

class network
{
	routes = [];
	established = 0;
	canExpand = true;
	lastExpansion = 0;
	expansionWaitPeriod = 1000;
	distanceSquareFromHQ = 0;
	fPlanner = null;
	nodes = linkedList();
	constructor(fp)
	{
		this.routes = [];
		this.established = 0;
		this.canExpand = true;
		this.lastExpansion = 0;
		this.expansionWaitPeriod = 1000;
		this.distanceSquareFromHQ = 0;
		this.fPlanner = fp;
	}
}

function network::Initialise()
{
	established = AIController.GetTick();
	lastExpansion = established;
}

function network::AddRoute(route)
{
	local currentSize = routes.len();
	routes.resize(currentSize + 1);
	routes[currentSize] = route;
}

function network::Upgrade()
{
	for (local i = 0; i < routes.len(); i++)
	{
		if (routes[i].NewServiceViable())
		{
			if (fPlanner.CanIMakeThisUpgrade(routes[i].GetNewVehicleValue()))
			{
				return routes[i].AddService();
			}
			
		}
	}
	local exec = AIExecMode();
	return false;
}

function network::Maintain()
{
	local newRoutesArray = [];
	for (local i = 0; i < routes.len(); i++)
	{
		routes[i].ReplaceOldVehicles();
		routes[i].CancelUnprofitableServices();
		routes[i].CancelExcessServices();
		routes[i].SellCancelledServices();
		routes[i].IntegrityCheck();
		if (!(routes[i].isObsolete && routes[i].HasNoServices()))
		{
			local currentSize = newRoutesArray.len();
			newRoutesArray.resize(currentSize + 1);
			newRoutesArray[currentSize] = routes[i];
		}
	}
	routes = newRoutesArray;
}

function network::GetAllStations()
{
	local stationsOnNetwork = AIList();
	for(local i = 0; i < routes.len(); i++)
	{
		local stationsOnRoute = routes[i].GetAllStations();
		for (local j = 0; j < stationsOnRoute.len(); j++)
		{
			if (!stationsOnNetwork.HasItem(stationsOnRoute[j]))
			{
				stationsOnNetwork.AddItem(stationsOnRoute[j], 0);
			}
		}
	}
	return stationsOnNetwork;
}

function network::GetAllNodes()
{
	local nodesOnNetwork = [];
	for(local i = 0; i < routes.len(); i++)
	{
		local nodesOnRoute = routes[i].nodes;
		for (local j = 0; j < nodesOnRoute.len(); j++)
		{
			local station = nodesOnRoute[j].station;
			local addNode = true;
			for (local k = 0; k < nodesOnNetwork.len(); k++)
			{
				if (nodesOnNetwork[k].station == station) addNode = false;
			}
			if (addNode)
			{
				utilities.AddItemToArray(nodesOnNetwork, nodesOnRoute[j]);
			}
		}
	}
	return nodesOnNetwork;
}

function network::Size()
{
	local stationList = GetAllStations();
	return stationList.Count();
}

function network::GetAllDepots()
{
	local depotsOnNetwork = AIList();
	for(local i = 0; i < routes.len(); i++)
	{
		local d = routes[i].depot;
		if (!depotsOnNetwork.HasItem(d))
		{
			depotsOnNetwork.AddItem(d, 0);
		}
	}
	return depotsOnNetwork;
}

function network::RouteExists(nodes, cargoTypeID)
{
	for (local i = 0; i < routes.len(); i++)
	{
		local r = routes[i];
		if (r.cargoTypeID == cargoTypeID)
		{
			local containedStationCount = 0;
			for (local j = 0; j < nodes.len(); j++)
			{
				if (r.ContainsNode(nodes[j]))
				{
					containedStationCount++;
				}
			}
			if (containedStationCount == nodes.len())
			{
				return true;
			}
		}
	}
	return false;
}

function network::ConsolidateRoutes(routeAdded)
{
	local nodesOnRoute = routeAdded.nodes;
	local nodesOnNetwork = GetAllNodes();
	local obsoleteRoute = null;
	for (local i = 0; i < routes.len(); i++)
	{
		if (routes[i].nodes.len() > 2)
		{
			obsoleteRoute = routes[i];
		}
	}
	for (local i = 0; i < nodesOnRoute.len(); i++)
	{
		for (local j = 0; j < nodesOnNetwork.len(); j++)
		{
			if (nodesOnRoute[i].station != nodesOnNetwork[j].station)
			{
				local newRouteNodes = [nodesOnRoute[i], nodesOnNetwork[j]];
				if (!RouteExists(newRouteNodes, 0))
				{
					local newRoute = roadRoute();
					newRoute.startTown = AITile.GetClosestTown(nodesOnRoute[i].station);
					newRoute.endTown = AITile.GetClosestTown(nodesOnNetwork[j].station);
					newRoute.nodes = newRouteNodes;
					newRoute.established = AIController.GetTick();
					newRoute.cargoTypeID = routeAdded.cargoTypeID;
					newRoute.depot = GetClosestDepot(nodesOnNetwork[j].station);
					AddRoute(newRoute);
					newRoute.AddService();
				}
			}
		}
	}
	if (routes.len() > 1)
	{
		local longRoute = roadRoute();
		longRoute.SetNodes(GetAllNodes());
		longRoute.established = AIController.GetTick();
		longRoute.cargoTypeID = routeAdded.cargoTypeID;
		longRoute.depot = GetClosestDepot(GetAllNodes()[0].station);
		AddRoute(longRoute);
		longRoute.AddService();
		if (obsoleteRoute != null)
		{
			obsoleteRoute.CancelAllServices();
		}
	}
	local s = Size();
	for (local i = 0; i < routes.len(); i++)
	{
		routes[i].SetMaxServices(s);
	}
}

function network::GetClosestDepot(tile)
{
	local depotList = GetAllDepots();
	depotList.Valuate(AITile.GetDistanceManhattanToTile, tile);
	depotList.Sort(AIList.SORT_BY_VALUE, true);
	return depotList.Begin();
}

function network::GetSaveTable()
{
	local routeTables = [];
	for (local i = 0; i < routes.len(); i++)
	{
		utilities.AddItemToArray(routeTables, routes[i].GetSaveTable());
	}
	local saveTable = 
	{
		sRoutes = routeTables
		sEstablished = established
		sCanExpand = canExpand
		sLastExpansion = lastExpansion
		sExpansionWaitPeriod = expansionWaitPeriod
		sDistanceSquareFromHQ = distanceSquareFromHQ
		sNetworkType = GetNetworkType()
	}
	return saveTable;
}

function network::LoadFromTable(table)
{
	if ("sRoutes" in table)
	{
		local routeTables = table.sRoutes;
		for (local i = 0; i < routeTables.len(); i++)
		{
			local currentRoute = routeTables[i];
			local r = null;
			if ("sRouteType" in currentRoute)
			{
				if (currentRoute.sRouteType == 0)
				{
					r = roadRoute();
				}
			}
			if (r != null)
			{
				r.LoadFromTable(currentRoute);
				AddRoute(r);
			}
		}
	}
	if ("sEstablished" in table) established = table.sEstablished;
	if ("sCanExpand" in table) canExpand = table.sCanExpand;
	if ("sLastExpansion" in table) lastExpansion = table.sLastExpansion;
	if ("sExpansionWaitPeriod" in table) expansionWaitPeriod = table.sExpansionWaitPeriod;
	if ("sDistanceSquareFromHQ" in table) distanceSquareFromHQ = table.sDistanceSquareFromHQ;
}

//This method should be overridden in subclass
function network::Expand()
{
	AILog.Warning("function Expand has not been overridden");
	return false;
}

function network::GetNetworkType()
{
	// 0 = bus, 1 = truck, 2 = train
	if (this instanceof roadNetwork)
	{
		return 0;
	}
	return -1;
}

function network::TestMaintenanceFunctions()
{
	routes[0].CancelAllServices();
	routes[0].SellCancelledServices();
}