//require ("fatController.nut");

class financialPlanner
{
	controller = null;
	
	constructor(cont)
	{
		this.controller = cont;
	}
}

function financialPlanner::CanIBuildThisRoute(cost)
{
	local maxAllowed = 0;
	if (IsFirstRoute())
	{
		maxAllowed = 0.8 * GetAvailableFunds().tofloat();
	}
	else
	{
		maxAllowed = 0.3 * GetAvailableFunds().tofloat();
	}
	return cost < maxAllowed;
}

function financialPlanner::CanIMakeThisUpgrade(cost)
{
	return cost < GetAvailableFunds();
}

function financialPlanner::IsFirstRoute()
{
	return controller.networks.len() == 0;
}

function financialPlanner::GetAvailableFunds()
{
	return AICompany.GetBankBalance(AICompany.COMPANY_SELF);
}