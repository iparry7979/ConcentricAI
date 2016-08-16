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
	AILog.Info("Station = " + station);
	AILog.Info("Town = " + AITown.GetName(town));
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

