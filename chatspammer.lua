local running = true
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(Input, gameProcessed)
	if Input.KeyCode == Enum.KeyCode.M and not gameProcessed then
		running = false
	end
end)
while running == true do
	game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("WELCOME TO SOKOBAN IN ROBLOX! YOUR GOAL IS TO GET ALL OF THE BOXES AT THE RANDOMLY PLACES X'S TYPE W, A, S OR D IN CHAT TO CONTROL THE GAME","All")
end
