class 'Countdown'

function Countdown:__init()
	-- Variables
	self.textColor = Color(255, 0, 0)
	self.activeCountdowns = false
	self.countdownTimer = Timer()
	self.secondsToGo = 4
	self.timeOfLastCount = 0
	self.tickSubscription = nil
	self.timeouts = {}
	
	-- Yout can edit these variables
	self.countdownMin = 3
	self.countdownMax = 5
	self.countdownDefault = self.countdownMin
	self.playerTimeout = 30
	
	-- Events
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
end

function Countdown:PlayerChat(args)
	local commands = {}
	for command in string.gmatch(args.text, "[^%s]+") do
		table.insert(commands, command)
	end
	
	if commands[1] ~= "/countdown" then return true end
	
	if self.activeCountdowns then
		Chat:Send(args.player, "Countdown in progress.", self.textColor)
		return false
	end
	
	if commands[2] ~= nil then
		local secondsCommandNumber = tonumber(commands[2])
		if secondsCommandNumber == nil then
			Chat:Send(args.player, "That is not a valid number.", self.textColor)
			return false
		elseif secondsCommandNumber < self.countdownMin or secondsCommandNumber > self.countdownMax then
			Chat:Send(args.player, "You can only specify a number from " .. self.countdownMin .. " to " .. self.countdownMax .. " seconds.", self.textColor)
			return false
		end
		self.secondsToGo = secondsCommandNumber
	else
		self.secondsToGo = self.countdownDefault
	end
	
	local seconds = self.countdownTimer:GetSeconds()
	
	local timeout = self.timeouts[args.player:GetId()]
	if timeout ~= nil then
		if seconds - timeout < self.playerTimeout then
			Chat:Send(args.player, "You can only countdown once every " .. self.playerTimeout .. " seconds.", self.textColor)
			return false
		end
	end
	
	self.timeouts[args.player:GetId()] = seconds
	self.activeCountdowns = true
	self.timeOfLastCount = 0
	
	self.tickSubscription = Events:Subscribe("PreTick", self, self.PreTick)
	
	return false
end

function Countdown:PreTick(args)
	local milliseconds = self.countdownTimer:GetMilliseconds()
	if milliseconds - self.timeOfLastCount >= 1000 then
		if self.secondsToGo < 0 then
			self.activeCountdowns = false
			if self.tickSubscription ~= nil then
				Events:Unsubscribe(self.tickSubscription)
			end
			return
		end
	
		self.timeOfLastCount = milliseconds
		
		if self.secondsToGo > 0 then
			Chat:Broadcast("Countdown: " .. tostring(self.secondsToGo), self.textColor)
		else
			Chat:Broadcast("Countdown: GO!", self.textColor)
			Events:Unsubscribe(self.tickSubscription)
			self.activeCountdowns = false
		end
		
		self.secondsToGo = self.secondsToGo - 1
	end
end

local countdown = Countdown()