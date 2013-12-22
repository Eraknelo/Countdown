Events:Subscribe("ModulesLoad", function ()
	Events:Fire("HelpAddItem",
	{
		name = "Countdown",
		text = 
			"To start a countdown, type /countdown\n" ..
			"Alternatively, you can write /countdown <time> to specify the duration."
	} )
end)
Events:Subscribe("ModuleUnload", function ()
	Events:Fire( "HelpRemoveItem", { name = "Countdown" })
end)