# region

- this module is a zoneplus alternative used in [pillarworks](https://github.com/pillarworks-rbx).
- this is a **client** module. this will not work on the server.
- all credits goes to [aymannkaadan](https://devforum.roblox.com/u/aymannkaadan) for the original module that you can find [here](https://devforum.roblox.com/t/regionmanger-lightweight-simple-alternative-to-zoneplus/3795554).
- this is a roblox-only module. it relies on roblox apis.

## usage
```lua
local region = require(path.to.region)
local created_region = region.new(workspace.Part, {
	enter = function(player)
		print(player.Name .. " entered the region")
	end,
	exit = function(player)
		print(player.Name .. " exited the region")
	end,
})

task.wait(5)

region.remove(created_region)
```