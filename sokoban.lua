local Sokoban = {}

local RNG = Random.new()

Sokoban.Directions = {
	["LEFT"] = Vector2.new(-1, 0),
	["RIGHT"] = Vector2.new(1, 0),
	["UP"] = Vector2.new(0, -1),
	["DOWN"] = Vector2.new(0, 1)
}

Sokoban.Player = {
	["Char"] = '🎃', ["X"] = nil, ["Y"] = nil
}

Sokoban.Player.__index = Sokoban.Player

Sokoban.Box = {
	["Char"] = '📦', ["X"] = nil, ["Y"] = nil
}

Sokoban.Box.__index = Sokoban.Box

Sokoban.BoxPoint = {
	["Char"] = '❌', ["X"] = nil, ["Y"] = nil
}

Sokoban.BoxPoint.__index = Sokoban.BoxPoint

Sokoban.Canvas = {
	["BackgroundChar"] = '◼',
	["Boxes"] = {},
	["BoxPoints"] = {},
	["CanvasWidth"] = 20,
	["CanvasHeight"] = 4,
	["MaxBoxes"] = 2,

	["Player"] = nil,

	["GameCanvas"] = ""
	--Max box points
}

Sokoban.Canvas.__index = Sokoban.Canvas

function Sokoban.Canvas:GenerateRandomBoxes()
	local BoxesNumber = RNG:NextInteger(1, self.MaxBoxes)
	for i = 1, BoxesNumber  do
		local Box = {}
		local BoxPoint =  {}
		setmetatable(Box, Sokoban.Box)
		setmetatable(BoxPoint, Sokoban.BoxPoint)

		table.insert(self.Boxes, Box)
		table.insert(self.BoxPoints, BoxPoint)
	end
end
function Sokoban.new()
	--Creates new random game
	local Player = {}
	setmetatable(Player, Sokoban.Player)
	local Box = {}
	setmetatable(Box, Sokoban.Box)
	local Canvas = {}
	setmetatable(Canvas, Sokoban.Canvas)

	Canvas.Player = Player
	return Canvas
end

function Sokoban.Canvas:Add(Char)
	self.GameCanvas ..= Char
end

function Sokoban.Canvas:GenerateRandomPosition(IsPlayer)
	while true do
		local RandomPos = nil
		if IsPlayer then
			RandomPos = Vector2.new(math.random(1, self.CanvasWidth), math.random(1, self.CanvasHeight))
		else
			RandomPos = Vector2.new(math.random(2, self.CanvasWidth - 1), math.random(2, self.CanvasHeight - 1))
		end
		for _, Box in pairs(self.Boxes) do
			if Box:GetPosition() == RandomPos then
				RandomPos = nil
				break
			end
		end
		for _, BoxPoint in pairs(self.BoxPoints) do
			if BoxPoint:GetPosition() == RandomPos then
				RandomPos = nil
				break
			end
		end
		if RandomPos == self.Player:GetPosition() then
			RandomPos = nil
		end
		if RandomPos ~= nil then
			return RandomPos
		end
		task.wait()
	end
end

function Sokoban.Canvas:GenerateCanvas()
	table.clear(self.Boxes)
	table.clear(self.BoxPoints)
	self:GenerateRandomBoxes()
	local RandomPosition = self:GenerateRandomPosition(true)
	self.Player:SetPosition(RandomPosition)
	print("for boxes")
	for _, Box in pairs(self.Boxes) do
		local RandomPosition = self:GenerateRandomPosition(false)
		Box:SetPosition(RandomPosition)
	end

	print("for box points")

	for _, BoxPoint in pairs(self.BoxPoints) do
		local RandomPosition = self:GenerateRandomPosition(false)
		BoxPoint:SetPosition(RandomPosition)
	end
end

function Sokoban.Canvas:GetCharAtPosition(Position)
	for _, Box in pairs(self.Boxes) do
		if Box:GetPosition() == Position then return Box.Char end
	end
	if self.Player:GetPosition() == Position then return self.Player.Char end
	for _, BoxPoint in pairs(self.BoxPoints) do
		if BoxPoint:GetPosition() == Position then return BoxPoint.Char end
	end
	return self.BackgroundChar
end

function Sokoban.Canvas:PlayerWon()
	local BoxesAtPoints = 0
	for _, Box in pairs(self.Boxes) do
		for _, BoxPoint in pairs(self.BoxPoints) do
			if Box:GetPosition() == BoxPoint:GetPosition() then
				BoxesAtPoints += 1
			end
		end
	end
	print(BoxesAtPoints)
	if BoxesAtPoints == #self.Boxes then
		return true
	end
	return false
end

function Sokoban.Canvas:Update() -- Canvas updater
	if self:PlayerWon() then
		print("won")
		self:GenerateCanvas()
	end
	self.GameCanvas = ""
	for y = 1, self.CanvasHeight do
		for x = 1, self.CanvasWidth do
			local CanvasPosition = Vector2.new(x, y)
			self.GameCanvas ..= self:GetCharAtPosition(CanvasPosition)

		end
	end
end

function Sokoban.Canvas:HandlePlayerCollisions(Direction)
	local PlayerPosition = self.Player:GetPosition()
	print(PlayerPosition)
	print(PlayerPosition + Direction)
	print("-------------------------------------")
	print((PlayerPosition + Direction).X)
	if (PlayerPosition + Direction).X < 1 or (PlayerPosition + Direction).X > self.CanvasWidth then
		print("Out of bounds X Player")
		return false
	end
	if (PlayerPosition + Direction).Y < 1 or (PlayerPosition + Direction).Y > self.CanvasHeight then
		print("Out of bounds Y Player")
		return false
	end
	for _, Box in pairs(self.Boxes) do
		local BoxToPush = Box:GetPosition()
		if (PlayerPosition + Direction) == BoxToPush then
			for _, Box_Check in pairs(self.Boxes) do
				if Box_Check ~= BoxToPush and BoxToPush + Direction == Box_Check:GetPosition() then
					return false
				end
			end
			if (BoxToPush + Direction).X < 2 or (BoxToPush + Direction).X > self.CanvasWidth - 1 then
				print("Out of bounds X Box")
				return false
			end
			if (BoxToPush + Direction).Y < 2 or (BoxToPush + Direction).Y > self.CanvasHeight - 1 then
				print("Out of bounds Y Box")
				return false
			end
			Box:SetPosition(BoxToPush + Direction)
		end
	end
	self.Player:SetPosition(PlayerPosition + Direction)
end

function Sokoban.Canvas:MovePlayer(Direction)
	local CanMove = self:HandlePlayerCollisions(Direction)
	if CanMove == false then
		print("couldnt move")
	end
end

function Sokoban.Player:GetPosition() -- Gets position of the player
	return Vector2.new(self.X, self.Y)
end

function Sokoban.Box:GetPosition() -- Gets position of the box
	return Vector2.new(self.X, self.Y)
end

function Sokoban.BoxPoint:GetPosition() -- Gets position of the box point
	return Vector2.new(self.X, self.Y)
end

function Sokoban.Player:SetPosition(Position)
	self.X = Position.X
	self.Y = Position.Y
end

function Sokoban.Box:SetPosition(Position)
	self.X = Position.X
	self.Y = Position.Y
end

function Sokoban.BoxPoint:SetPosition(Position)
	self.X = Position.X
	self.Y = Position.Y
end


local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

function SetBoothText(Text)
	for _, Remote in pairs(Remotes:GetChildren()) do
		pcall(function()
			Remote:FireServer(Text, "booth")
		end)
	end
end

local SokobanGame = Sokoban.new()
SokobanGame:GenerateCanvas()
SokobanGame:Update()

local GameRunning = true

local PlayerControlKeys = {
	["w"] = Sokoban.Directions.UP,
	["a"] = Sokoban.Directions.LEFT,
	["s"] = Sokoban.Directions.DOWN,
	["d"] = Sokoban.Directions.RIGHT,
}

function GetControlByMessage(Message)
	return PlayerControlKeys[Message:lower()]
end
local Controls = {}
table.insert(Controls, UIS.InputBegan:Connect(function(Input, gameProc)
	if Input.KeyCode == Enum.KeyCode.M and not gameProc then
		GameRunning = false
	end
end))


for _, Player in pairs(game.Players:GetPlayers()) do
	table.insert(Controls, Player.Chatted:Connect(function(Message)
		local Control = GetControlByMessage(Message)
		if Control == nil then return end
		SokobanGame:MovePlayer(Control)
	end))
end

game.Players.PlayerAdded:Connect(function(Player)
	table.insert(Controls, Player.Chatted:Connect(function(Message)
		local Control = GetControlByMessage(Message)
		if Control == nil then return end
		SokobanGame:MovePlayer(Control)
	end))
end)
task.wait(1)
task.spawn(function()
	while GameRunning == true do
		game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("WELCOME TO SOKOBAN IN ROBLOX! YOUR GOAL IS TO GET ALL OF THE BOXES AT THE RANDOMLY PLACES X'S TYPE W, A, S OR D IN CHAT TO CONTROL THE GAME","All")
		SokobanGame:Update()
		SetBoothText(SokobanGame.GameCanvas)
		task.wait()
	end	
	for _, Control in pairs(Controls) do
		Control:Disconnect()
	end
end)
