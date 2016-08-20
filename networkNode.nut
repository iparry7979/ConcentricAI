class networkNode
{
	station = 0;
	town = 0;
	industry = 0;
	exhaustedTowns = [];
	exhaustedIndustries = [];
	canExpand = true;
	
	constructor(stn, twn, ind)
	{
		station = stn;
		town = twn;
		industry = ind;
		exhaustedTowns = [];
		exhaustedIndustries = [];
		canExpand = true;
	}
}

function networkNode::IgnorePotentialTownConnection(town)
{
	utilities.AddItemToArray(exhaustedTowns, town);
}

function networkNode::IgnorePotentialIndustryConnection(industry)
{
	utilities.AddItemToArray(exhaustedIndustries, industry);
}

function networkNode::ToString()
{
	AILog.Info("New Node");
	AILog.Info("	Station = " + station);
	AILog.Info("	Town = " + AITown.GetName(town));
	AILog.Info("	Exhausted Towns:");
	for (local i = 0; i < exhaustedTowns.len(); i++)
	{
		AILog.Info(		exhaustedTowns[i]);
	}
}

function networkNode::ExhaustedTownsAsList()
{
	local rtn = AIList();
	for (local i = 0; i < exhaustedTowns.len(); i++)
	{
		rtn.AddItem(exhaustedTowns[i], 0);
	}
	return rtn;
}

function networkNode::GetSaveTable()
{
	local saveTable =
	{
		sStation = station
		sTown = town
		sIndustry = industry
		sExhaustedTowns = exhaustedTowns
		sExhaustedIndustries = exhaustedIndustries
		sCanExpand = canExpand
	}
	return saveTable;
}

function networkNode::LoadFromTable(table)
{
	if ("sStation" in table) station = table.sStation;
	if ("sTown" in table) town = table.sTown;
	if ("sIndustry" in table) industry = table.sIndustry;
	if ("sExhaustedTowns" in table) exhaustedTowns = table.sExhaustedTowns;
	if ("sExhaustedIndustries" in table) exhaustedIndustries = table.sExhaustedIndustries;
	if ("sCanExpand" in table) canExpand = table.sCanExpand
}

