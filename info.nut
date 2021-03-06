class ConcentricAI extends AIInfo {
  function GetAuthor()      { return "Ian Parry"; }
  function GetName()        { return "ConcentricAI"; }
  function GetDescription() { return "An AI designed to beat Sando in any given scenario"; }
  function GetVersion()     { return 1; }
  function GetDate()        { return "2016-01-01"; }
  function CreateInstance() { return "ConcentricAI"; }
  function GetShortName()   { return "CNCT"; }
  function GetAPIVersion()  { return "1.0"; }
  
  function GetSettings()
  {
  	AddSetting(
  	  {
  	  	name = "RouteWait",
  	  	description = "Days to wait between building routes",
  	  	min_value = 1,
  	  	max_value = 5000,
  	  	easy_value = 80,
  	  	medium_value = 150,
  	  	hard_value = 80,
  	  	custom_value = 200,
  	  	flags = 0
  	  });
  	AddSetting(
  	  {
  	  	name = "ActionWait",
  	  	description = "Days to wait between purchasing new vehicles",
  	  	min_value = 1,
  	  	max_value = 365,
  	  	easy_value = 30,
  	  	medium_value = 15,
  	  	hard_value = 5,
  	  	custom_value = 15,
  	  	flags = 0
  	  });
  	AddSetting(
  	  {
  	  	name = "MinTownSize",
  	  	description = "Minimum required town size to justify passenger station",
  	  	min_value = 1,
  	  	max_value = 1000000000,
  	  	easy_value = 250,
  	  	medium_value = 250,
  	  	hard_value = 250,
  	  	custom_value = 250,
  	  	flags = 0
  	  });  
  }
}

RegisterAI(ConcentricAI());