--!optimize 2
--!native

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local framework = {}

framework.utils = {}

export type singleton = {
	identifier: string?,

	init: (self: singleton) -> (),
	start: (self: singleton) -> (),
	stop: (self: singleton) -> (),

	[string]: any,
}

export type config = {
	lifecycles: { string },
	singletons: { singleton } | { [string]: singleton },

	dependencies: {
		task: typeof(task)?,
	}?,
}

function framework.utils.run_lifecycle(config: config, lifecycle: string, parallel: boolean?)
	if parallel == nil then
		parallel = false
	end

	if not table.find(config.lifecycles, lifecycle) then
		return
	end

	for _, singleton: singleton in pairs(config.singletons) do
		if not singleton[lifecycle] then
			continue
		end

		local success, err = pcall(function()
			if parallel then
				local dependencies = config["dependencies"] or {}
				local task_lib = dependencies["task"] or task

				task_lib.spawn(singleton[lifecycle], singleton)
			else
				singleton[lifecycle](singleton)
			end
		end)

		if not success then
			local identifier = singleton.identifier

			if identifier then
				warn(`error running {lifecycle} for {identifier}: {err}`)
			else
				warn(`error running {lifecycle}: {err}`)
			end
		end
	end
end

function framework.run(config: config)
	framework.utils.run_lifecycle(config, "init", false)
	framework.utils.run_lifecycle(config, "start", true)

	if RunService:IsServer() then
		game:BindToClose(function()
			framework.utils.run_lifecycle(config, "stop", true)
		end)
	else
		local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
		local character = player.Character or player.CharacterAdded:Wait()

		local humanoid = character:WaitForChild("Humanoid")
		local connection: RBXScriptConnection?

		connection = humanoid.Died:Connect(function()
			framework.utils.run_lifecycle(config, "stop", true)

			if connection and typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
				connection = nil
			end
		end)
	end
end

return framework
