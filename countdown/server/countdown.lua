local textColor = Color(255, 0, 0)
local activeCountdowns = false
local countdownTimer = Timer()
local secondsToGo = 4
local timeOfLastCount = 0
local tickSubscription

local timeouts = {}
local playerTimeout = 30

Events:Subscribe("PlayerChat", function (args)
	if args.text ~= "/countdown" then return true end
	
	if activeCountdowns then
		Chat:Send(args.player, "Countdown in progress.", textColor)
		return false
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
	secondsToGo = 4
	timeOfLastCount = countdownTimer:GetMilliseconds()
	
	for k,v in pairs(timeouts) do
		print(k, v)
	end
	
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

