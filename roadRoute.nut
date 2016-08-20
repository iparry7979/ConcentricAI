import("pathfinder.road", "RoadPathFinder", 4);
require("utilities.nut");
require("roadStationBuilder.nut");
require("roadDepotBuilder.nut");
require("builder.nut");
require("route.nut");
require("networkNode.nut");

class roadRoute extends route
{
}
	
	/* Attempts to find a path between two random
	 * towns and returns true if a path is found
	 */
	
	function roadRoute::FindPathBetweenRandomTowns(excludedTowns)
	{
		local success = false;
	  local townList = AITownList();
	  townList.Valuate(AITown.GetPopulation);
	  townList.KeepAboveValue(500);
		townList.RemoveList(excludedTowns);
		foreach(t1, pop1 in townList)
		{
			if (!success)
			{
				local potentialDestinations = AITownList();
				potentialDestinations.RemoveList(excludedTowns);
				if (FindPathBetweenOneGivenTown(t1, potentialDestinations, 75, 25))
				{
					success = true;
				}
			}
		}
		return success;
	}
	
	function roadRoute::connectTownsAroundTile(excludedTowns, centreTile)
	{
		local success = false;
		local townList = AITownList();
	  	townList.Valuate(AITown.GetPopulation);
	  	townList.KeepAboveValue(300);
		townList.RemoveList(excludedTowns);
		townList.Valuate(AITown.GetDistanceSquareToTile, centreTile);
		townList.Sort(AIList.SORT_BY_VALUE, true);
		foreach(t1, pop1 in townList)
		{
			if (!success)
			{
				local potentialDestinations = AITownList();
				potentialDestinations.RemoveList(excludedTowns);
				//potentialDestinations.Valuate(AITown.GetDistanceManhattanToTile, AITown.GetLocation(t1));
				//potentialDestinations.Sort(AIList.SORT_BY_VALUE, true);
				if (FindPathBetweenOneGivenTown(t1, potentialDestinations, 75, 25))
				{
					local hq = AICompany.GetCompanyHQ(AICompany.COMPANY_SELF);
					distanceFromHQ = AITown.GetDistanceSquareToTile(t1, hq);
					success = true;
				}
			}
		}
		return success;
	}

	
	/* Attempts to find a path between one given
	 * town and one random town and returns true 
	 * if a path is found
	 */
	
	function roadRoute::FindPathBetweenOneGivenTown(t1, potentialDestinations, radius, iterations)
	{
	  AILog.Info("Finding Path" + AIController.GetTick());
	  potentialDestinations.Valuate(AITown.GetPopulation);
	  potentialDestinations.KeepAboveValue(200);
	  local t1Loc = AITown.GetLocation(t1);
	  potentialDestinations.Valuate(AITown.GetDistanceManhattanToTile, t1Loc);
	  potentialDestinations.KeepBelowValue(radius);
	  potentialDestinations.Sort(AIList.SORT_BY_VALUE, true);
		local success = false;
		foreach (t2, pop2 in potentialDestinations)
		{
			//local t2Loc = AITown.GetLocation(t2);
			//potentialDestinations.Valuate(AITown.GetDistanceManhattanToTile);
			//potentialDestinations.KeepBelowValue(100);
			
			if (!success)
			{
				if (t1 != t2)
				{
					if (FindPathBetweenTwoGivenTowns(t1, t2, iterations))
					{
						success = true;
					}
					else
					{
						if (nodes.len() > 0)
						{
							local n = nodes[0];
							if (n.town == t1)
							{
								n.IgnorePotentialTownConnection(t2);
							}
						}	
					}
				}
			}
		}
		return success;
	}
	
	/* Attempts to find a path between two given
	 * towns and returns true if a path is found
	 */
	
	function roadRoute::FindPathBetweenTwoGivenTowns(t1, t2, iterations)
	{
		AILog.Info("Finding Path between " + AITown.GetName(t1) + " and " + AITown.GetName(t2));
		cargoTypeID = 0;
		local success = false;
		path = false;
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
					local count = 0;
					while (path == false && count < iterations)
					{
						AILog.Info("Pathfinding Iteration " + count + " - Tick " + AIController.GetTick());
						count++; 
						path = pathfinder.FindPath(100);
						AIController.Sleep(1);
					}
					if (path != false)
					{
						success = true;
						startTown = t1;
						endTown = t2;
					}
				}		  
			}
		}
		return success;
	}
	
function roadRoute::BuildRoute()
{
	established = AIController.GetTick();
	local buildPath = path;
	while (buildPath != null) 
	{
    local par = buildPath.GetParent();
    if (par != null) 
	  {
      local last_node = buildPath.GetTile();
      if (AIMap.DistanceManhattan(buildPath.GetTile(), par.GetTile()) == 1 ) 
			{
        if (!AIRoad.BuildRoad(buildPath.GetTile(), par.GetTile())) 
				{
					/* An error occurred while building a piece of road. TODO: handle it. 
					 * Note that this could mean the road was already built. */
				}
			} 
			else 
			{
			/* Build a bridge or tunnel. */
				if (!AIBridge.IsBridgeTile(buildPath.GetTile()) && !AITunnel.IsTunnelTile(buildPath.GetTile())) 
				{
					/* If it was a road tile, demolish it first. Do this to work around expended roadbits. */
					if (AIRoad.IsRoadTile(buildPath.GetTile())) AITile.DemolishTile(buildPath.GetTile());
					if (AITunnel.GetOtherTunnelEnd(buildPath.GetTile()) == par.GetTile()) 
					{
						if (!AITunnel.BuildTunnel(AIVehicle.VT_ROAD, buildPath.GetTile())) 
						{
							/* An error occured while building a tunnel. TODO: handle it. */
						}
					} 
					else 
					{
						local bridge_list = AIBridgeList_Length(AIMap.DistanceManhattan(buildPath.GetTile(), par.GetTile()) + 1);
						bridge_list.Valuate(AIBridge.GetMaxSpeed);
						bridge_list.Sort(AIList.SORT_BY_VALUE, false);
						if (!AIBridge.BuildBridge(AIVehicle.VT_ROAD, bridge_list.Begin(), buildPath.GetTile(), par.GetTile())) 
						{
							/* An error occured while building a bridge. TODO: handle it. */
						}
					}
				}
			}
		}
	buildPath = par;
	}
}

/* Builds the stations at each end of the route
 * Returns false if unable 
   if nodes already exist for town they are passed in.
   Otherwise arguments will be null
   Mode can be 0 for test or 1 for exec*/
function roadRoute::BuildNodes(existingNode1, existingNode2, mode)
{
	local success = false;
	local node1 = null;
	local node2 = null;
	if (existingNode1 == null)
	{
		local tile1 = AITown.GetLocation(startTown);
		local station1 = roadStationBuilder();
		station1.townServiced = startTown;
		local startStation = station1.BuildNearTile(tile1, 1);
		if (startStation != null)
		{
			utilities.AddItemToArray(nodes, networkNode(startStation, startTown, 0));
		}
	}
	else
	{
		utilities.AddItemToArray(nodes, existingNode1);
	}
	if (existingNode2 == null)
	{
		local tile2 = AITown.GetLocation(endTown);
		local station2 = roadStationBuilder();
		station2.townServiced = endTown;
		local endStation = station2.BuildNearTile(tile2, 1);
		if (endStation != null)
		{
			utilities.AddItemToArray(nodes, networkNode(endStation, endTown, 0));
		}
	}
	else
	{
		utilities.AddItemToArray(nodes, existingNode2);
	}
	if (nodes.len() >= 2)
	{
		//nodes = [networkNode(startStation, startTown, 0), networkNode(endStation, endTown, 0)];
		if (mode == 0) nodes = []; // In test mode don't create the nodes yet
		success = true;
	}
	return success;
}

/* Builds the road depot somewhere along the route
 */
 
function roadRoute::BuildDepot()
{
	local depotBuilder = roadDepotBuilder();
	local buildPath = path;
	depot = depotBuilder.BuildAlongPath(buildPath);
	if (depot == null) return false;
	return true;
}

/* Adds another service to the route */

function roadRoute::AddService()
{
  local engineList = AIEngineList(AIVehicle.VT_ROAD);
	engineList.Valuate(AIEngine.GetDesignDate);
	engineList.Sort(AIList.SORT_BY_VALUE, false);
	local engine = null;
	foreach(e, dd in engineList)
	{
		if (AIEngine.IsValidEngine(e))
		{
			local cargoType = AIEngine.GetCargoType(e);
			if (cargoType == cargoTypeID)
			{
				if (engine == null) engine = e;
			}
		}
	}
	if (engine == null)
	{
		return false;
	}
	local vehicleID = AIVehicle.BuildVehicle(depot, engine);
	//TODO: Deal with testmode case
	if (!AIVehicle.IsValidVehicle(vehicleID))
	{
		return false;
	}
	local stns = GetAllStations();
	for (local i = 0; i < stns.len(); i++)
	{
		if (!AIOrder.InsertOrder(vehicleID, i, stns[i], AIOrder.OF_NON_STOP_INTERMEDIATE))
		{
			return false;
		}
	}
	lastServiceAddedTick = AIController.GetTick();
	local servicesLength = services.len();
	services.resize(servicesLength + 1);
	services[servicesLength] = vehicleID;
	AIVehicle.StartStopVehicle(vehicleID);
	AILog.Info("Adding new bus service - Vehicle ID: " + vehicleID);
	return true;
}

function roadRoute::GetNewVehicleValue()
{
	local engineList = AIEngineList(AIVehicle.VT_ROAD);
	engineList.Valuate(AIEngine.GetDesignDate);
	engineList.Sort(AIList.SORT_BY_VALUE, false);
	local engine = null;
	foreach(e, dd in engineList)
	{
		if (AIEngine.IsValidEngine(e))
		{
			local cargoType = AIEngine.GetCargoType(e);
			if (cargoType == cargoTypeID)
			{
				if (engine == null) engine = e;
			}
		}
	}
	if (engine == null)
	{
		return null;
	}
	return AIEngine.GetPrice(engine);
}

function roadRoute::NewServiceViable()
{
	if (isObsolete) return false;
	if (services.len() == 0) return true;
	local waitPeriod = 500;
	local acceptableRatio = 1;
	if (services.len() >= maxServices)
	{
		return false;
	}
	if (cargoTypeID == 0)
	{
		acceptableRatio = 0.75;
	}
	else
	{
		acceptableRatio = 0.5;
	}
	local currentTick = AIController.GetTick();
	if (currentTick - lastServiceAddedTick > waitPeriod)
	{
		local acceptableValueCount = 0;
		local stns = GetAllStations();
		for (local i = 0; i < stns.len(); i++)
		{
			local cargoWaiting = AIStation.GetCargoWaiting(AIStation.GetStationID(stns[i]), cargoTypeID);
			local totalCapacity = 0;
			for (local j = 0; j < services.len(); j++)
			{
				totalCapacity += AIVehicle.GetCapacity(services[j], cargoTypeID);
			}
			local averageVehicleLoad = totalCapacity / services.len();
			local excess = cargoWaiting - totalCapacity;
			if (excess > averageVehicleLoad)
			{
				acceptableValueCount += 1;
			}
		}
		if (acceptableValueCount > 0)
		{
			if (acceptableValueCount.tofloat() / stns.len().tofloat() > acceptableRatio)
			{
				return true;
			}
		}
	}
	return false;
}

function roadRoute::SetMaxServices(networkSize)
{
	local maximumSize = 30 / (networkSize - 1);
	if (maximumSize < 1)
	{
		maximumSize = 1;
	}
	maxServices = maximumSize;
}

