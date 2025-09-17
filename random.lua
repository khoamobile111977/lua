

function randomfruit()
	local args = {
		"Cousin",
		"Buy"
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end
 
local args = {
	"Drop"
}
workspace:WaitForChild("Spring Fruit"):WaitForChild("EatRemote"):InvokeServer(unpack(args))

workspace["Spring Fruit"]["Fruit "]
WorldPivot


local fruit= {
	"Rocket Fruit", "Spin Fruit", "Blade Fruit", "Spring Fruit", "Bomb Fruit", "Smoke Fruit", "Spike Fruit", 
	"Flame Fruit",
	"Ice Fruit",
	"Sand Fruit",
	"Dark Fruit",
	"Eagle Fruit",
	"Diamond Fruit",
	"Light Fruit",
	"Rubber Fruit",
	"Ghost Fruit",
	"Magme Fruit",
	"Quake Fruit",
	"Buddha Fruit",
	"Love Fruit",
	"Creation Fruit",
	"Spider Fruit",
	"Sound Fruit",
	"Phoenix Fruit",
	"Portal Fruit",
	"Lightning Fruit",
	"Pain Fruit",
	"Blizzard Fruit",
	"Gravity Fruit",
	"Mammoth Fruit",
	"T-Rex Fruit",
	"Dough Fruit",
	"Shadow Fruit",
	"Venom Fruit",
	"Control Fruit",
	"Gas Fruit",
	"Spirit Fruit",
	"Leopard Fruit",
	"Yeti Fruit",
	"Kitsune Fruit",
	"Dragon Fruit"
}


local args = {
	{
		NPC = "Dojo Trainer",
		Command = "ClaimQuest"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer(unpack(args))
