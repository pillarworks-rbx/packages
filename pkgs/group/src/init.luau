--!optimize 2
--!native

export type disconnect = () -> ()
export type item = Instance | { [string]: any } | (() -> ()) | thread | RBXScriptConnection

local create

export type item_group = {
	add: (item_group, item: item) -> disconnect,
	clean: (item_group) -> (),
	extend: (item_group) -> item_group,

	items: { item },
	cleanup_handler: (item) -> (),
	children: { item },
}

local function group_add(self: item_group, item: any): disconnect
	local items = self.items

	table.insert(items, item)

	return function()
		local idx = table.find(items, item)

		if idx then
			table.remove(items, idx)
		end
	end
end

local function group_clean(self: item_group)
	local items = self.items
	local cleanup_handler = self.cleanup_handler
	local children = self.children

	for _, child: any in children do
		child:clean()
	end

	for _, item in items do
		cleanup_handler(item)
	end

	table.clear(items)
end

local function group_extend(self: item_group)
	local new = create()

	table.insert(self.children, new)

	return new
end

function create(): item_group
	return {
		items = {},
		children = {},

		cleanup_handler = function(item: any)
			if typeof(item) == "Instance" then
				item:Destroy()
			elseif typeof(item) == "table" then
				table.clear(item)
			elseif typeof(item) == "function" then
				item()
			elseif typeof(item) == "thread" then
				task.cancel(item)
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			end
		end,

		clean = group_clean,
		add = group_add,
		extend = group_extend,
	} :: item_group
end

return {
	create = create,
}
