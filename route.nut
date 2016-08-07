class route
{
	path = null; //path returned by A*
  startTown = null; //townID of startTown
  endTown = null;  //townID of endTown
	depot = null; //tile containing depot
	stations = []; //array of stations on route
	services = [];
	lastServiceAddedTick = 0; //the tick when the last service was added to route
	established = 0; //the tick the route was established
	cargoTypeID = null; //The cargo type carried on this route
	cancelledServices = [];
	maxServices = 25;
	distanceFromHQ = 0;
	isObsolete = false;
	lastIntegrityCheck = 0;
	integrityCheckInterval = 540;
	constructor()
	{
		path = null; //path returned by A*
		startTown = null; //townID of startTown
		endTown = null;  //townID of endTown
		depot = null; //tile containing depot
		stations = []; //array of stations on route
		services = [];
		lastServiceAddedTick = 0; //the tick when the last service was added to route
		established = 0; //the tick the route was established
		cargoTypeID = null; //The cargo type carried on this route
		cancelledServices = [];
		maxServices = 25;
		distanceFromHQ = 0;
		isObsolete = false;
	}
}

function route::GetServicesAsList()
{
	local rtn = AIList();
	for (local i = 0; i < services.len(); i++)
	{
		rtn.AddItem(services[i], 0);
	}
	return rtn;
}

function route::ContainsStation(station)
{
	for (local i = 0; i < stations.len(); i++)
	{
		if (stations[i] == station) return true;
	}
	return false;
}

function route::CancelService(service)
{
	AIVehicle.SendVehicleToDepot(service);
	local currentSize = cancelledServices.len();
	cancelledServices.resize(currentSize + 1);
	cancelledServices[currentSize] = service;
	local serviceIndex = utilities.FindArrayIndexForItem(services, service);
	services.remove(serviceIndex);
	if (services.len() == 0) isObsolete = true;
}

function route::SellCancelledServices()
{
	for (local i = 0; i < cancelledServices.len(); i++)
	{
		local s = cancelledServices[i];
		if (s != null)
		{
			if (AIVehicle.IsStoppedInDepot(s))
			{
				AIVehicle.SellVehicle(s);
			}
		}
	}
}

function route::CancelUnprofitableServices()
{
	//TODO: Wriite this method
	for (local i = 0; i < services.len(); i++)
	{
		local currentVehicle = services[i];
		local lastYearsProfit = AIVehicle.GetProfitLastYear(currentVehicle);
		local age = AIVehicle.GetAge(currentVehicle);
		if (age > 730 && lastYearsProfit < 0)
		{
			AILog.Info("Cancelling Service For Vehicle ID: " + currentVehicle + " Due To Lack Of Profit");
			CancelService(currentVehicle);
		}
	}
}

function route::CancelExcessServices()
{
	if (services.len() > maxServices)
	{
		local serviceList = GetServicesAsList();
		serviceList.Valuate(AIVehicle.GetAge);
		serviceList.Sort(AIList.SORT_BY_VALUE, false);
		local servicesToRemove = services.len() - maxServices;
		serviceList.KeepTop(servicesToRemove);
		local currentService = serviceList.Begin();
		while (!serviceList.IsEnd)
		{
			if (currentService != null)
			{
				CancelService(currentService);
			}
		}
	}
}

function route::ReplaceOldVehicles()
{
	for (local i = 0; i < services.len(); i++)
	{
		local currentVehicle = services[i];
		local ageLeft = AIVehicle.GetAgeLeft(currentVehicle);
		if (ageLeft < 730)
		{
			CancelService(currentVehicle);
			AddService();
		}
	}
}

function route::SetStations(stationList)
{
	
	local currentStation = stationList.Begin();
	while (!stationList.IsEnd())
	{
		local currentSize = stations.len();
		stations.resize(currentSize + 1);
		stations[currentSize] = currentStation;
		currentStation = stationList.Next();
	}
}

function route::CancelAllServices()
{
	while (services.len() >= 1)
	{
		CancelService(services[0]);
	}
	isObsolete = true;
}

function route::IntegrityCheck()
{
	if (AIController.GetTick() - lastIntegrityCheck > integrityCheckInterval)
	{
		BuildRoute();
		lastIntegrityCheck = AIController.GetTick();
	}
}

function route::GetSaveTable()
{
	local routeType = 0;
	if (this instanceof roadRoute)
	{
		routeType = 0;
	}
	local saveTable =
	{
		//sPath = path
		sStartTown = startTown
		sEndTown = endTown
		sDepot = depot
		sStations = stations
		sServices = services
		sLastServiceAddedTick = lastServiceAddedTick
		sEstablished = established
		sCargoTypeID = cargoTypeID
		sCancelledServices = cancelledServices
		sMaxServices = maxServices
		sIsObsolete = isObsolete
		sRouteType = routeType
		sLastIntegrityCheck = lastIntegrityCheck
		sIntegrityCheckInterval = integrityCheckInterval
		sDistanceFromHQ = distanceFromHQ
	}
	return saveTable;
}

function route::LoadFromTable(table)
{
	if ("sStartTown" in table) startTown = table.sStartTown;
	if ("sEndTown" in table) endTown = table.sEndTown;
	if ("sDepot" in table) depot = table.sDepot;
	if ("sStations" in table) stations = table.sStations;
	if ("sServices" in table) services = table.sServices;
	if ("sLastServiceAddedTick" in table) lastServiceAddedTick = table.sLastServiceAddedTick;
	if ("sEstablished" in table) established = table.sEstablished;
	if ("sCargoTypeID" in table) cargoTypeID = table.sCargoTypeID;
	if ("sCancelledServices" in table) cancelledServices = table.sCancelledServices;
	if ("sMaxServices" in table) maxServices = table.sMaxServices;
	if ("sIsObsolete" in table) isObsolete = table.sIsObsolete;
	if ("sLastIntegrityCheck" in table) lastIntegrityCheck = table.sLastIntegrityCheck;
	if ("sIntegrityCheckInterval" in table) integrityCheckInterval = table.sIntegrityCheckInterval;
	if ("sDistanceFromHQ" in table) distanceFromHQ = table.sDistanceFromHQ;
}

function route::ToString()
{
	local rtn = "Route: ";
	for (local i = 0; i < stations.len(); i++)
	{
		if (AITile.IsStationTile(stations[i]))
		{
			rtn = rtn + AIStation.GetStationID(stations[i]) + "; ";
		}
		else
		{
			rtn = rtn + "InvalidStation; ";
		}
	}
	
	return rtn;
}

function route::HasNoServices()
{
	return services.len() == 0 && cancelledServices.len() == 0;
}

function route::InitialiseRoute()
{
	established = AIController.GetTick();
	BuildRoute();
}

function route::BuildRoute()
{
	AILog.Warning("Function BuildRoute Has Not Been Overridden");
	return false;
}

function route::BuildStations()
{
	AILog.Warning("Function BuildStations Has Not Been Overridden");
	return false;
}

function route::BuildDepot()
{
	AILog.Warning("Function BuildDepot Has Not Been Overridden");
	return false;
}

function route::AddService()
{
	AILog.Warning("Function AddService Has Not Been Overridden");
	return false;
}

function route::NewServiceViable()
{
	AILog.Warning("Function NewServiceViable Has Not Been Overridden");
	return false;
}

function route::SetMaxServices(networkSize)
{
	AILog.Warning("Function SetMaxServices Has Not Been Overridden");
	return false;
}