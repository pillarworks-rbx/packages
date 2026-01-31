--!optimize 2
--!native

local framework = {}

framework.utils = {}
framework.environment = ""

local is_roblox = pcall(function(...)
	return game
end)

if is_roblox then
	framework.environment = "roblox"
else
	framework.environment = "luau"
end

export type singleton = {
	identifier: string?,
	priority: number?,

	init: (self: singleton) -> (),
	start: (self: singleton) -> (),
	stop: (self: singleton) -> (),

	[string]: any,
}

export type config = {
	lifecycles: { string },
	singletons: { singleton },

	dependencies: {
		task: {
			spawn: (fn: (...any) -> (), ...any) -> (),
		}?,
	}?,
}

type absolute_config = config & {
	internal: {
		lifecycle_set: { [string]: true },
	},
}

local function for_each_lifecycle(
	config: absolute_config,
	lifecycle: string,
	executor: (fn: (singleton) -> (), singleton: singleton) -> ()
)
	if not config.internal.lifecycle_set[lifecycle] then
		return
	end

	for _, singleton in ipairs(config.singletons) do
		local fn = singleton[lifecycle]

		if type(fn) ~= "function" then
			continue
		end

		executor(fn, singleton)
	end
end

function framework.utils.run_parallel_lifecycle(config: absolute_config, lifecycle: string)
	local task_lib = (config.dependencies and config.dependencies.task)

	if framework.environment == "roblox" and task_lib == nil then
		task_lib = task
	end

	if task_lib == nil then
		warn("task library not found! falling back to sequential execution...")

		framework.utils.run_lifecycle(config, lifecycle)

		return
	end

	for_each_lifecycle(config, lifecycle, function(fn, singleton)
		task_lib.spawn(function()
			local success, err = pcall(fn, singleton)

			if not success then
				local identifier = singleton.identifier

				if identifier then
					warn(`error running {lifecycle} for {identifier}: {err}`)
				else
					warn(`error running {lifecycle}: {err}`)
				end
			end
		end)
	end)
end

function framework.utils.run_lifecycle(config: absolute_config, lifecycle: string)
	for_each_lifecycle(config, lifecycle, function(fn, singleton)
		local success, err = pcall(fn, singleton)

		if not success then
			local identifier = singleton.identifier

			if identifier then
				warn(`error running {lifecycle} for {identifier}: {err}`)
			else
				warn(`error running {lifecycle}: {err}`)
			end
		end
	end)
end

function framework.run(config: config)
	local absolute_config: absolute_config = {
		singletons = config.singletons or {},
		lifecycles = config.lifecycles or {},

		dependencies = config.dependencies or {},

		internal = {
			lifecycle_set = {} :: { [string]: true },
		},
	}

	if #absolute_config.singletons > 0 then
		table.sort(absolute_config.singletons, function(a: singleton, b: singleton): boolean
			local a_priority = a.priority or 0
			local b_priority = b.priority or 0

			a_priority = math.clamp(a_priority, 0, math.huge)
			b_priority = math.clamp(b_priority, 0, math.huge)

			return a_priority > b_priority
		end)
	end

	if #absolute_config.lifecycles == 0 then
		warn("framework.run called with no lifecycles configured")
	else
		for _, lifecycle in ipairs(absolute_config.lifecycles) do
			absolute_config.internal.lifecycle_set[lifecycle] = true
		end
	end

	table.freeze(absolute_config)

	framework.utils.run_lifecycle(absolute_config, "init")
	framework.utils.run_parallel_lifecycle(absolute_config, "start")

	return absolute_config
end

function framework.stop(absolute_config: absolute_config)
	framework.utils.run_lifecycle(absolute_config, "stop")
end

return framework
