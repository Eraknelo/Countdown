local textColor = Color(255, 0, 0)
local activeCountdowns = false
local countdownTimer = Timer()
local secondsToGo = 4
local timeOfLastCount = 0
local tickSubscription

local timeouts = {}
local playerTimeout = 30

Events:Subscribe("PlayerChat", function (args)
	local commands = {}
	for command in string.gmatch(args.text, "[^%s]+") do
		table.insert(commands, command)
	end
	
	if commands[1] ~= "/countdown" then return true end
	
	if activeCountdowns then
		Chat:Send(args.player, "Countdown in progress.", textColor)
		return false
	end
	
	if commands[2] ~= nil then
		local secondsCommandNumber = tonumber(commands[2])
		if secondsCommandNumber == nil then
			Chat:Send(args.player, "That is not a valid number.", textColor)
			return false
		elseif secondsCommandNumber < 3 or secondsCommandNumber > 5 then
			Chat:Send(args.player, "You can only specify a number from 3 to 5 seconds.", textColor)
			return false
		end
		secondsToGo = secondsCommandNumber + 1
	else
		secondsToGo = 4
	end
	
	local seconds = countdownTimer:GetSeconds()
	
	local timeout = timeouts[args.player:GetId()]
	if timeout ~= nil then
		if seconds - timeout < playerTimeout then
			Chat:Send(args.player, "You can only countdown once every " .. playerTimeout .. " seconds.", textColor)
			return false
		end
	end
	
	timeouts[args.player:GetId()] = seconds
	activeCountdowns = true
	timeOfLastCount = countdownTimer:GetMilliseconds()
	
	tickSubscription = Events:Subscribe("PreTick", function (args)
		local milliseconds = countdownTimer:GetMilliseconds()
		if milliseconds - timeOfLastCount >= 1000 then
			secondsToGo = secondsToGo - 1
			if secondsToGo < 0 then
				activeCountdowns = false
				return
			end
		
			timeOfLastCount = milliseconds
			
			if secondsToGo > 0 then
				Chat:Broadcast("Countdown: " .. tostring(secondsToGo), textColor)
			else
				Chat:Broadcast("Countdown: GO!", textColor)
				Events:Unsubscribe(tickSubscription)
				activeCountdowns = false
			end
		end
	end)
	
	return false
end)

